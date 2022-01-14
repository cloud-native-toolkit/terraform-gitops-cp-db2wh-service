module "dev_cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ocp-login.git"

  server_url = var.server_url
  login_user = "apikey"
  login_password = var.ibmcloud_api_key
  login_token = ""
}

module "pwx_cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-ocp-vpc.git"

  resource_group_name = var.resource_group_name
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  name                = var.cluster_name
  worker_count        = var.workers
  ocp_version         = "4.6"
  exists              = var.cluster_exists
  name_prefix         = var.name_prefix
  vpc_name            = var.vpc_cluster
  vpc_subnets         = []
  vpc_subnet_count    = 1
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
    command = "echo 'Total Workers: ${module.pwx_cluster.total_worker_count}'"
  }
  provisioner "local-exec" {
    command = "echo 'Workers: ${jsonencode(module.pwx_cluster.workers)}'"
  }
}