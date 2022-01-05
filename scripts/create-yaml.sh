#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

NAME="$1"
DEST_DIR="$2"

mkdir -p $DEST_DIR

## Add logic here to put the yaml resource content in DEST_DIR

find "${DEST_DIR}" -name "*"

#installation based on logic here: https://github.com/IBM/cp4d-deployment


cat > "${DEST_DIR}/ibm_operator_catalog_source.yaml" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-operator-catalog
  namespace: openshift-marketplace
spec:
  displayName: "IBM Operator Catalog"
  publisher: IBM
  sourceType: grpc
  image: icr.io/cpopen/ibm-operator-catalog:latest
  imagePullPolicy: IfNotPresent
  updateStrategy:
    registryPoll:
      interval: 45m
EOL

cat > "${DEST_DIR}/cpd_operator.yaml" << EOL
apiVersion: v1
kind: Namespace
metadata:
  name: $OPERATOR_NAMESPACE
---
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: operatorgroup
  namespace: $OPERATOR_NAMESPACE
spec:
  targetNamespaces:
  - $OPERATOR_NAMESPACE
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cpd-operator
  namespace: $OPERATOR_NAMESPACE
spec:
  channel: $CPD_PLATFORM_CHANNEL
  installPlanApproval: Automatic
  name: cpd-platform-operator
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOL

cat > "${DEST_DIR}/db2wh_sub.yaml" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-db2wh-cp4d-operator-catalog-subscription
  namespace: $OPERATOR_NAMESPACE
spec:
  channel: $DB2_WAREHOUSE_CHANNEL
  installPlanApproval: Automatic
  name: ibm-db2wh-cp4d-operator
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOL


cat > "${DEST_DIR}/db2wh_cr.yaml" << EOL
apiVersion: databases.cpd.ibm.com/v1
kind: Db2whService
metadata:
  name: db2wh-cr
  namespace: $CPD_NAMESPACE
spec:
  storageClass: $STORAGE_CLASS
  license:
    accept: true
    license: "Enterprise"
EOL
