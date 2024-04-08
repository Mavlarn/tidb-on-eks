variable "name" {
  description = "Name of the VPC and EKS Cluster"
  default     = "mt-tidb-on-eks"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_version" {
  description = "EKS Cluster version"
  default     = "1.29"
  type        = string
}

variable "operator_version" {
  description = "TiDB operator version"
  default     = "v1.6.0-alpha.12"
}

variable "tidb_cluster_version" {
  default = "v7.5.1"
}

# Please note that this is only for manually created VPCs, deploying multiple EKS
# clusters in one VPC is NOT supported now.
variable "create_vpc" {
  description = "Create a new VPC or not, if true the vpc_id/subnet_ids must be set correctly, otherwise the vpc_cidr/private_subnets/public_subnets must be set correctly"
  default     = true
}

variable "vpc_cidr" {
  description = "VPC cidr, must be set correctly if create_vpc is true"
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  description = "VPC id, must be set correctly if create_vpc is false"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "subnet id list, must be set correctly if create_vpc is false"
  type        = list(string)
  default     = []
}

variable "bastion_ingress_cidr" {
  description = "IP cidr that allowed to access bastion ec2 instance"
  default     = ["0.0.0.0/0"] # Note: Please restrict your ingress to only necessary IPs. Opening to 0.0.0.0/0 can lead to security vulnerabilities.
}

variable "create_bastion" {
  description = "Create bastion ec2 instance to access TiDB cluster"
  default     = true
}

variable "bastion_instance_type" {
  description = "bastion ec2 instance type"
  default     = "t2.micro"
}

variable "default_cluster_pd_instance_type" {
  default = "m5.xlarge"
}

variable "default_cluster_pd_count" {
  default = 3
}

variable "default_cluster_tikv_instance_type" {
  default = "c5d.4xlarge"
}

variable "default_cluster_tikv_count" {
  default = 3
}

variable "default_cluster_tidb_instance_type" {
  default = "c5.4xlarge"
}

variable "default_cluster_tidb_count" {
  default = 3
}

variable "default_cluster_tiflash_instance_type" {
  default = "i3.4xlarge"
}

variable "default_cluster_tiflash_count" {
  default = 2
}

variable "default_cluster_ticdc_instance_type" {
  default = "c5.2xlarge"
}

variable "default_cluster_ticdc_count" {
  default = 2
}

variable "default_cluster_monitor_instance_type" {
  default = "c5.2xlarge"
}