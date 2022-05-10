#!/usr/bin/env bash

NAME="$1"
DEST_DIR="$2"

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
# CHART_DIR=$(cd "${MODULE_DIR}/charts/ibm-db2wh"; pwd -P)

# added support for db2wh subscription / instance 
CHART_DIR=$(cd "${MODULE_DIR}/charts/${NAME}"; pwd -P)

echo "Name Print"
echo "${NAME}"

echo "SCRIPT_DIR"
echo "${SCRIPT_DIR}"

echo "MODULE_DIR"
echo "${MODULE_DIR}"

echo "DEST_DIR"
echo "${DEST_DIR}"

echo "Chart Dir"
echo "${CHART_DIR}"

mkdir -p $DEST_DIR

## Add logic here to put the yaml resource content in DEST_DIR

cp -R "${CHART_DIR}"/* "${DEST_DIR}"

echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"

cat "${DEST_DIR}/values.yaml"

find "${DEST_DIR}" -name "*"