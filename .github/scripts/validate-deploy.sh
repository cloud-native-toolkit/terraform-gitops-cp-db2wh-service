#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
BRANCH="main"
SERVER_NAME="default"
TYPE="base"
LAYER="2-services"

COMPONENT_NAME="my-module"

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

MAX_COUNT=30

if [[ ! -f "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
  exit 1
fi

echo "Printing argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
cat "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"

if [[ ! -f "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml" ]]; then
  echo "Application values not found - payload/2-services/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
  exit 1
fi

echo "Printing payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
cat "payload/${LAYER}namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq $MAX_COUNT ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq $MAX_COUNT ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi

count=0
until kubectl get CatalogSource "ibm-db2uoperator-catalog" -n "openshift-marketplace" || [[ $count -eq $MAX_COUNT ]]; do
  echo "Waiting for CatalogSourceibm-db2uoperator-catalog in openshift-marketplace"
  count=$((count + 1))
  sleep 30
done

if [[ $count -eq $MAX_COUNT ]]; then
  echo "Timed out waiting for subscription/ibm-db2wh-cp4d-operator-catalog-subscription in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

count=0
until kubectl get subscription "ibm-db2wh-cp4d-operator-catalog-subscription" -n "${NAMESPACE}" || [[ $count -eq $MAX_COUNT ]]; do
  echo "Waiting for subscription/ibm-db2wh-cp4d-operator-catalog-subscription in ${NAMESPACE}"
  count=$((count + 1))
  sleep 30
done

if [[ $count -eq $MAX_COUNT ]]; then
  echo "Timed out waiting for subscription/ibm-db2wh-cp4d-operator-catalog-subscription in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

count=0
until kubectl get db2whservice "db2wh-cr" -n "${NAMESPACE}" || [[ $count -eq $MAX_COUNT ]]; do
  echo "Waiting for db2whservice/db2wh-cr in ${NAMESPACE}"
  count=$((count + 1))
  sleep 30
done

if [[ $count -eq $MAX_COUNT ]]; then
  echo "Timed out waiting for db2whservice/db2wh-cr in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

cd ..
rm -rf .testrepo
