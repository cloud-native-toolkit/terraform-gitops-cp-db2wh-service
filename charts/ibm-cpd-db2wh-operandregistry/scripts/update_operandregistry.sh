#!/bin/sh

ZEN_OPERATORS_NAMESPACE="${ZEN_OPERATORS_NAMESPACE}"
COMMON_SERVICES_NAMESPACE="${COMMON_SERVICES_NAMESPACE}"

#Need to validate if base CP4D got changed
#https://www.ibm.com/docs/en/cloud-paks/cp-data/4.0?topic=tasks-creating-operator-subscriptions#preinstall-operator-subscriptions__svc-subcriptions
SOURCE_NAME="ibm-db2uoperator-catalog"

echo "ZEN Operator namespace"
echo $ZEN_OPERATORS_NAMESPACE

echo "COMMON Operator namespace"
echo $COMMON_SERVICES_NAMESPACE

oc get operandregistry common-service -n ${COMMON_SERVICES_NAMESPACE} -o json > /temp/operandregistry.json

jq --arg ZEN_OPERATORS_NAMESPACE $ZEN_OPERATORS_NAMESPACE '(.spec.operators[] | select(.name == "ibm-db2u-operator")).namespace |= $ZEN_OPERATORS_NAMESPACE' /temp/operandregistry.json > /temp/operandregistry_new.json
echo "success 1"

oc apply -f /temp/operandregistry_new.json