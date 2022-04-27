#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

NAME="$1"
DEST_DIR="$2"

mkdir -p $DEST_DIR

## Add logic here to put the yaml resource content in DEST_DIR

#installation based on logic here: https://github.com/IBM/cp4d-deployment

# https://www.ibm.com/docs/en/cloud-paks/cp-data/4.0?topic=ccs-creating-catalog-sources-that-automatically-pull-latest-images-from-entitled-registry
# Create Operator Catalog 

cat > "${DEST_DIR}/cp4d-operatorcatalog.yaml" <<EOF 
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
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

# Create DB2U Catalog 
cat > "${DEST_DIR}/cp4d-db2uoperator.yaml" <<EOF 
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-db2uoperator-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: docker.io/ibmcom/ibm-db2uoperator-catalog:latest
  imagePullPolicy: Always
  displayName: IBM Db2U Catalog
  publisher: IBM
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

#https://www.ibm.com/docs/en/cloud-paks/cp-data/4.0?topic=ccs-creating-catalog-sources-that-automatically-pull-latest-images-from-entitled-registry
# DB2U Catalog Source

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

# DB2W Operator - https://www.ibm.com/docs/en/cloud-paks/cp-data/4.0?topic=tasks-creating-operator-subscriptions#preinstall-operator-subscriptions__install-plan

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
  license:
    accept: true
    license: "Enterprise"
EOL

echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"

cat "${DEST_DIR}/values.yaml"

find "${DEST_DIR}" -name "*"