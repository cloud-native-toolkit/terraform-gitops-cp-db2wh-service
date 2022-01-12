module "dev_cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-ocp-vpc.git"

  resource_group_name = var.resource_group_name
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  name                = var.cluster_name
  worker_count        = 0
  ocp_version         = "4.6"
  exists              = var.cluster_exists
  name_prefix         = var.name_prefix
  vpc_name            = var.vpc_cluster
  vpc_subnets         = []
  vpc_subnet_count    = 0
  cos_id              = ""
  login               = "true"
}

resource null_resource print_resources {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Resource group: ${var.resource_group_name}'"
  }
  provisioner "local-exec" {
    command = "echo 'Total Workers: ${module.dev_cluster.total_worker_count}'"
  }
  provisioner "local-exec" {
    command = "echo 'Workers: ${jsonencode(module.dev_cluster.workers)}'"
  }
}