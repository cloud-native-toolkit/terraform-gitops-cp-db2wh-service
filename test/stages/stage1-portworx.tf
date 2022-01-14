module "portworx_module" {
  source               = "github.com/cloud-native-toolkit/terraform-portworx.git"
  resource_group_name  = var.resource_group_name
  region               = var.region
  ibmcloud_api_key     = var.ibmcloud_api_key
  cluster_name         = module.dev_cluster.name
  name_prefix          = var.name_prefix
  workers              = module.dev_cluster.workers
  worker_count         = var.workers
  create_external_etcd = false
  install_storage      = true
}

