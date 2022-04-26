resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.mymodule.name
        branch      = module.mymodule.branch
        namespace   = module.mymodule.namespace
        server_name = module.mymodule.server_name
        layer       = module.mymodule.layer
        layer_dir   = module.mymodule.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_module.layer == "services" ? "2-services" : "3-applications")
        type        = module.mymodule.type
      })
    }
  }
}