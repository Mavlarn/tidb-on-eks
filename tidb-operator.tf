# TiDB Operator CRD
data "http" "tidb_operator_crds" {
  url = "https://raw.githubusercontent.com/pingcap/tidb-operator/${var.operator_version}/manifests/crd.yaml"
}

# split raw yaml into individual resources
data "kubectl_file_documents" "tidb_operator_crds" {
  content = data.http.tidb_operator_crds.response_body
}

# apply each resource from the yaml one by one
resource "kubectl_manifest" "tidb_operator_crds" {
  for_each   = data.kubectl_file_documents.tidb_operator_crds.manifests
  yaml_body  = each.value
  server_side_apply = true
  wait              = true
  wait_for_rollout  = true
}

#---------------------------------------
# TiDB Operator by helm
#---------------------------------------
module "tidb-operator" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1.1" #ensure to update this to the latest/desired version

  chart            = "tidb-operator"
  chart_version    = var.operator_version
  repository       = "http://charts.pingcap.org"
  description      = "Pincap TiDB Helm Chart deployment"
  namespace        = local.tidb_operator_namespace
  create_namespace = true
}

# TiDB CLuster by helm
resource "kubernetes_namespace" "tidb-cluster" {
  metadata {
    annotations = {
      name = "tidb-cluster"
    }
    name = "tidb-cluster"
  }
}

# Not using online files, using local files, and version as variables
# locals {
#   tidb_operator_cluster_resources = [
#     "https://raw.githubusercontent.com/pingcap/tidb-operator/${var.operator_version}/examples/aws/tidb-cluster.yaml",
#     "https://raw.githubusercontent.com/pingcap/tidb-operator/${var.operator_version}/examples/aws/tidb-monitor.yaml",
#     "https://raw.githubusercontent.com/pingcap/tidb-operator/${var.operator_version}/examples/aws/tidb-dashboard.yaml"
#   ]
# }
# data "http" "tidb_operator_cluster_resources" {
#   for_each  = toset(local.tidb_operator_cluster_resources)
#   url = each.value
# }

data "kubectl_path_documents" "tidb_operator_cluster_resources" {
  pattern = "tidb-cluster/tidb-*.yaml"
  vars = {
    tidb_version = var.tidb_cluster_version
    cluster_pd_count = var.default_cluster_pd_count
    cluster_tikv_count = var.default_cluster_tikv_count
    cluster_tidb_count = var.default_cluster_tidb_count
    cluster_tiflash_count = var.default_cluster_tiflash_count
    cluster_ticdc_count = var.default_cluster_ticdc_count
  }
  
}
resource "kubectl_manifest" "tidb_operator_cluster_resources" {
  for_each  = toset(data.kubectl_path_documents.tidb_operator_cluster_resources.documents)
  yaml_body = each.value
  override_namespace = local.tidb_cluster_namespace
}

#---------------------------------------------------------------
# Creating an s3 bucket for event logs
#---------------------------------------------------------------
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "${local.name}-tidb-"

  # For example only - please evaluate for your environment
  force_destroy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

