# Resource Group Variables
variable "resource_group_name" {
  type        = string
  description = "Existing resource group where the IKS cluster will be provisioned."
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The api key for IBM Cloud access"
}

variable "region" {
  type        = string
  description = "Region for VLANs defined in private_vlan_number and public_vlan_number."
}

variable "server_url" {
  type        = string
}

variable "bootstrap_prefix" {
  type = string
  default = ""
}

variable "namespace" {
  type        = string
  description = "Namespace for tools"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = ""
}



variable "workers" {
  type        = number
  description = "Number of worker nodes"
  default     = 3
}

variable "subnets" {
  type        = number
  description = "Number of subnets"
  default     = 1
}


variable "cluster_type" {
  type        = string
  description = "The type of cluster that should be created (openshift or kubernetes)"
  default     = "openshift"
}

variable "cluster_exists" {
  type        = string
  description = "Flag indicating if the cluster already exists (true or false)"
  default     = "true"
}

variable "name_prefix" {
  type        = string
  description = "Prefix name that should be used for the cluster and services. If not provided then resource_group_name will be used"
  default     = ""
}

variable "vpc_cluster" {
  type        = bool
  description = "Flag indicating that this is a vpc cluster"
  default     = false
}

variable "git_token" {
  type        = string
  description = "Git token"
}

variable "git_host" {
  type    = string
  default = "github.com"
}

variable "git_type" {
  default = "github"
}

variable "git_org" {
  default = "cloud-native-toolkit-test"
}

variable "git_repo" {
  default = "git-module-test"
}

variable "gitops_namespace" {
  default = "openshift-gitops"
}

variable "git_username" {
}

variable "kubeseal_namespace" {
  default = "sealed-secrets"
}


variable "cp_entitlement_key" {
  default = ""
}

variable "cpd_common_services_namespace" {
  type        = string
  description = "Namespace for cpd commmon services"
  default = "ibm-common-services"
}


variable "cpd_operator_namespace" {
  type        = string
  description = "Namespace for cpd commmon services"
  default = "cpd-operators"
}

variable "cpd_namespace" {
  type        = string
  description = "CPD namespace"
  default = "gitops-cp4d-instance"
}