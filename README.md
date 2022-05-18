# CP4D - DB2 Warehourse Gitops terraform module

## Db2 Warehouse on Cloud Pak for Data

IBM Db2 Warehouse is an analytics data warehouse that features in-memory data processing and in-database analytics. It is client-managed and optimized for fast and flexible deployment, with automated scaling that supports analytics workloads. 

Namespace used in this module

- operator_namespace: cpd-operators
  CP4D Platform operator, DB2WH Operator will be installed on cpd-operators

- common_services_namespace: ibm-common-services
   CP4D foundational services, Operand Deployment Lifecycle manager Operator and IBM zen service will be installed on the ibm-common-service namespace. 

- cpd_namespace: gitops-cp4d-instance
  DB2WH instance will be installed on gitops-cp4d-instance
  
## Supported platforms

OCP 4.8

## Suggested companion modules

The module itself requires some information from the cluster and needs a namespace to be created. The following companion modules can help provide the required information:

- Gitops: github.com/cloud-native-toolkit/terraform-tools-gitops
- Gitops Bootstrap: github.com/cloud-native-toolkit/terraform-util-gitops-bootstrap
- Namespace: github.com/ibm-garage-cloud/terraform-cluster-namespace
- Pull Secret: github.com/cloud-native-toolkit/terraform-gitops-pull-secret
- Catalog: github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs
- Cert: github.com/cloud-native-toolkit/terraform-util-sealed-secret-cert
- Cluster: github.com/cloud-native-toolkit/terraform-ocp-login
- CertManager: github.com/cloud-native-toolkit/terraform-gitops-ocp-cert-manager

## Example usage

```hcl-terraform
module "mas_manage" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  entitlement_key = module.catalog.entitlement_key
  instanceid = "mas8"
  appid = "manage"

}
```

### DB2WH Pre-Req

- Make sure the CP4D Instance is deployed successfully
- Make sure the global pull secret is applied and worker nodes are replaced.

### DB2WH Service check

Run this CLI and check if the DB2WHService completed.

oc project gitops-cp4d-instance

oc get Db2whService db2wh-cr -o jsonpath='{.status.db2whStatus} {"\n"}'

### DB2WH Service (instance) removal - Finalizer

Run this CLI and remove the finalizer value from the YAML as sometimes DB2WH service got stuck

```oc edit db2whservice db2wh-cr -n gitops-cp4d-instance```

## References:

- [DB2 Warehouse Knowledge Center](https://www.ibm.com/docs/en/cloud-paks/cp-data/4.0?topic=services-db2-warehouse)