resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.db2wh.name
        inst_name   = module.db2wh.inst_name
        sub_chart   = module.db2wh.sub_chart
        sub_name   = module.db2wh.sub_name 
        operator_namespace = module.db2wh.operator_namespace
        cpd_namespace = module.db2wh.cpd_namespace
        branch      = module.db2wh.branch
        namespace   = module.db2wh.namespace
        server_name = module.db2wh.server_name
        layer       = module.db2wh.layer
        layer_dir   = module.db2wh.layer == "infrastructure" ? "1-infrastructure" : (module.db2wh.layer == "services" ? "2-services" : "3-applications")
        type        = module.db2wh.type
      })
    }
  }
}