#!/bin/bash

#
# Transform helm chart to gitops folder
#
# helm template open5gs/open5gs-5gcore-helm --output-dir rhacm-gitops
#

OUTPUT_DIR=.
REPO=open5gs
CHART=open5gs-5gcore-helm

mkdir -p temp_out

helm template "${REPO}/${CHART}" --output-dir temp_out

cat << EOF > kustomization.yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

commonLabels:
  demo: open5gs

resources:
EOF

for file in $(ls temp_out/${CHART}/templates);
do
  newfile=$(basename $file)
  echo $file
  cat temp_out/${CHART}/templates/${file} | perl -pe 's#\r\n#\n#g' > $file
  echo "- ${file}" >> kustomization.yaml
done

rm -fr temp_out
