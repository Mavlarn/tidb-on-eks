provider "aws" {
  region = var.region
}

module "key-pair" {
  source = "./key-pair"

  region = var.region
  name   = "${var.name}-key"
  path   = "${path.cwd}/credentials/"
}

module "bastion" {
  source = "./bastion"
  create_bastion           = var.create_bastion
  region                   = var.region
  bastion_name             = "${var.name}-bastion"
  key_name                 = module.key-pair.key_name
  worker_security_group_id = module.eks.node_security_group_id
  subnet_id                = module.vpc.public_subnets[0]
  vpc_id                   = module.vpc.vpc_id
  enable_ssh_to_workers    = true
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubectl" {
  apply_retry_count      = 30
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

#---------------------------------------
# Karpenter
#---------------------------------------
# ECR only in us-east-1
provider "aws" {
  region = "us-east-1"
  alias = "virginia"
}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

locals {
  name   = var.name
  region = var.region

  tidb_operator_namespace = "tidb-admin"
  tidb_cluster_namespace = "tidb-cluster"
  
  subnets = module.vpc.private_subnets
  azs = length(data.aws_availability_zones.available.names) > 3 ? slice(data.aws_availability_zones.available.names, 0, 3) : data.aws_availability_zones.available.names

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/awslabs/data-on-eks"
  }
}
