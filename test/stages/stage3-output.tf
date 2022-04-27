resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.db2wh.name
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