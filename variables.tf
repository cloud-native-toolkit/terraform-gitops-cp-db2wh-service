
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
  #default ="cpd-operators"
}

variable "cluster_ingress_hostname" {
  type        = string
  description = "Ingress hostname of the IKS cluster."
  default     = ""
}

variable "cluster_type" {
  type        = string
  description = "The cluster type (openshift or ocp3 or ocp4 or kubernetes)"
  default     = "ocp4"
}

variable "tls_secret_name" {
  type        = string
  description = "The name of the secret containing the tls certificate values"
  default     = ""
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "subscription_source_namespace" {
  type        = string
  description = "The namespace where the catalog has been deployed"
  default     = "openshift-marketplace"
}

variable "channel" {
  type        = string
  description = "The channel that should be used to deploy the operator"
  default     = "v1.0"
}

variable "operator_namespace" {
  type        = string
  description = "CPD operator namespace"
  default = "cpd-operators"
}

variable "cpd_namespace" {
  type        = string
  description = "CPD namespace"
  default = "gitops-cp4d-instance"
}

variable "common_services_namespace" {
  type        = string
  description = "Namespace where cpd is deployed"
  default     = "ibm-common-services"
}

variable "storage_class" {
  type        = string
  description = "Storage class for DB2WH instance"
  default     = "portworx-shared-gp3"
}

variable "db2_warehouse_version" {
  type        = string
  description = "DB2 Warehouse version"
  default     = "4.0.2"
}

variable "db2_warehouse_channel" {
  type        = string
  description = "DB2 Warehouse operator subscription channel"
  default     = "v1.0"
}

variable "license" {
  type        = string
  description = "License type"
  default     = "Enterprise"
}


