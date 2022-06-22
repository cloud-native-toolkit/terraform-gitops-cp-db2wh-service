#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

BIN_DIR=$(cat .bin_dir)

export PATH="${BIN_DIR}:${PATH}"

source "${SCRIPT_DIR}/validation-functions.sh"

if ! command -v oc 1> /dev/null 2> /dev/null; then
  echo "oc cli not found" >&2
  exit 1
fi

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

if ! command -v ibmcloud 1> /dev/null 2> /dev/null; then
  echo "ibmcloud cli not found" >&2
  exit 1
fi

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
COMPONENT_NAME=$(jq -r '.name // "my-module"' gitops-output.json)
SUBSCRIPTION_NAME=$(jq -r '.sub_name // "sub_name"' gitops-output.json)
OPERATOR_NAMESPACE=$(jq -r '.operator_namespace // "operator_namespace"' gitops-output.json)
CPD_NAMESPACE=$(jq -r '.cpd_namespace // "cpd_namespace"' gitops-output.json)
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
TYPE=$(jq -r '.type // "base"' gitops-output.json)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" values.yaml

check_k8s_namespace "${OPERATOR_NAMESPACE}"
#check_k8s_namespace "${CPD_NAMESPACE}"
#check_k8s_namespace "${NAMESPACE}"

CSV=$(kubectl get sub -n "${OPERATOR_NAMESPACE}" "${SUBSCRIPTION_NAME}" -o json | jq -r '.status.installedCSV')
echo "CSV ***** "${CSV}""

count=0
SUB_STATUS=0
while [[ $SUB_STATUS -ne 1 ]] && [[ $count -lt 30 ]]; do
  count=$((count + 1))
  sleep 30
  SUB_STATUS=$(kubectl get deployments -n "${OPERATOR_NAMESPACE}" -l olm.owner="${CSV}" -o json | jq -r '.items[0].status.availableReplicas')
  echo "SUB_STATUS ${SUB_STATUS} **** Waiting for subscription/${SUBSCRIPTION_NAME} in ${OPERATOR_NAMESPACE}"
done

if [[ $SUB_STATUS -ne 1 ]]; then
  echo "Timed out waiting for sub-status" >&2
  exit 1
fi

echo "DB2WH  Operator is READY"

echo "CPD_NAMESPACE ***** ${CPD_NAMESPACE}"
sleep 60
INSTANCE_STATUS=""

  while [ true ]; do
    INSTANCE_STATUS=$(kubectl get Db2whService db2wh-cr -n "${CPD_NAMESPACE}" -o jsonpath='{.status.db2whStatus} {"\n"}')
    echo "Waiting for instance "${INSTANCE_NAME}" to be ready. Current status : "${INSTANCE_STATUS}""
    if [ $INSTANCE_STATUS == "Completed" ]; then
      break
    elif [ $INSTANCE_STATUS == "" ]; then
      break
    fi
    sleep 30
  done

echo "DB2 Db2whService/db2wh-cr is ${INSTANCE_STATUS}"

check_k8s_resource "${CPD_NAMESPACE}" "secret" db2-credentials


echo "DB2 Operator uninstall"

#oc get Db2whService -n project-name

#oc delete csv ${CSV} -n ${OPERATOR_NAMESPACE}

oc delete Db2whService db2wh-cr -n ${CPD_NAMESPACE}

oc delete csv ${CSV} -n ${OPERATOR_NAMESPACE}


# Need to revisit and remove the finalizer from db2whservice


#oc get all -l "app.kubernetes.io/name in (preinstall, rbac, shared-components, zen-integration, zenhelper)" -n ${CPD_NAMESPACE}

cd ..
rm -rf .testrepo


