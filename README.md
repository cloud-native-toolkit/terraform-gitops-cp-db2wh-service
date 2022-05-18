# CP4D - DB2 Warehourse Gitops terraform module

### DB2WH Pre-Req

- Make sure the CP4D Instance is deployed successfully
- Make sure the global pull secret is applied and worker nodes are replaced.

## Module dependencies

This module makes use of the output from other modules:

- GitOps - github.com/cloud-native-toolkit/terraform-tools-gitops.git
- Namespace - github.com/cloud-native-toolkit/terraform-gitops-namespace.git
- gitops_ibm_catalogs - github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs.git
- gitops_cp_foundation - github.com/cloud-native-toolkit/terraform-gitops-cp-foundational-services.git
- gitops_cp4d_operator - github.com/cloud-native-toolkit/terraform-gitops-cp4d-operator.git
- gitops-cp4d-instance - github.com/cloud-native-toolkit/terraform-gitops-cp4d-instance.git

## Db2 Warehouse on Cloud Pak for Data

IBM Db2 Warehouse is an analytics data warehouse that features in-memory data processing and in-database analytics. It is client-managed and optimized for fast and flexible deployment, with automated scaling that supports analytics workloads. 

Namespace used in this module

- operator_namespace: cpd-operators
  CP4D Platform operator, DB2WH Operator will be installed on cpd-operators

- common_services_namespace: ibm-common-services
   CP4D foundational services, Operand Deployment Lifecycle manager Operator and IBM zen service will be installed on the ibm-common-service namespace. 

- cpd_namespace: gitops-cp4d-instance
  DB2WH instance will be installed on gitops-cp4d-instance

# Cloud Pak for Data, Db2WH Subscription and Db2WHService instance gitops module

Module to provision a gitops repo with the resources necessary to provision a Cloud Pak for data,ibm-db2WH-cp4d-operator Subscription and Db2WHService instance on a cluster. In order to provision Subscription and the instance, the following steps are performed:

1. Add the db2wh Subscription chart to the gitops repo (charts/ibm-cpd-db2wh-subscription)
2. Add the Db2whService instance chart to the gitops repo (charts/ibm-cpd-db2wh-instance)

Unit tests is expected to be executed on a cluster that already has CP4D-instance and its dependencies installed and configured.
  

## Suggested companion modules

The module itself requires some information from the cluster and needs a namespace to be created. The following companion modules can help provide the required information:

- Gitops: github.com/cloud-native-toolkit/terraform-tools-gitops
- Gitops Bootstrap: github.com/cloud-native-toolkit/terraform-util-gitops-bootstrap
- Namespace: github.com/ibm-garage-cloud/terraform-cluster-namespace
- Pull Secret: github.com/cloud-native-toolkit/terraform-gitops-pull-secret
- Cert: github.com/cloud-native-toolkit/terraform-util-sealed-secret-cert
- Cluster: github.com/cloud-native-toolkit/terraform-ocp-login

### DB2WH Service check

Run this CLI and check if the DB2WHService completed.

oc project gitops-cp4d-instance

oc get Db2whService db2wh-cr -o jsonpath='{.status.db2whStatus} {"\n"}'

### DB2WH Service (instance) removal - Finalizer

Run this CLI and remove the finalizer value from the YAML as sometimes DB2WH service getting stuck.

```oc edit db2whservice db2wh-cr -n gitops-cp4d-instance```

## Supported platforms

OCP 4.8

## References:

- [DB2 Warehouse Knowledge Center](https://www.ibm.com/docs/en/cloud-paks/cp-data/4.0?topic=services-db2-warehouse)