#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

NAME="$1"
DEST_DIR="$2"

mkdir -p $DEST_DIR

## Add logic here to put the yaml resource content in DEST_DIR

find "${DEST_DIR}" -name "*"

#installation based on logic here: https://github.com/IBM/cp4d-deployment

cat > "${DEST_DIR}/db2wu_sub.yaml" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-db2uoperator-catalog-subscription
  namespace: $CS_NAMESPACE    # Pick the project that contains the Cloud Pak for Data operator
spec:
  channel: v1.1
  name: db2u-operator
  installPlanApproval: Automatic
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOL

cat > "${DEST_DIR}/db2wh_sub.yaml" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-db2wh-cp4d-operator-catalog-subscription
  namespace: $CS_NAMESPACE
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
  namespace: $INSTANCE_NAMESPACE
spec:
  storageClass: $STORAGE_CLASS
  license:
    accept: true
    license: "Enterprise"
EOL
