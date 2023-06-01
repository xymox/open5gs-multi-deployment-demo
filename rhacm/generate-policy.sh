#!/bin/sh

cat << EOF
apiVersion: policy.open-cluster-management.io/v1
kind: Policy
metadata:
  name: policy-deploy-open5gs-gitops-app
  annotations:
    policy.open-cluster-management.io/standards: NIST SP 800-53
    policy.open-cluster-management.io/categories: CM Configuration Management 
    policy.open-cluster-management.io/controls: CM-2 Baseline Configuration
spec:
  remediationAction: enforce
  disabled: false
  policy-templates:
EOF

for file in $(ls gitops | egrep -v 'tower|kustomization');
do
  rs=$(echo $file | sed -e 's/\.yaml$//')
  cat << EOF
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        metadata:
          name: policy-open5gs-gitops-app-${rs}
        spec:
          remediationAction: enforce
          severity: low
          namespaceSelector:
            exclude: ["kube-*","openshift-*"]
            include: ["*"]
          object-templates:
            - complianceType: musthave
              objectDefinition:
EOF
  cat gitops/${file} | egrep -v '^---' | perl -pe 's/^/                /'
done

cat << EOF
---
apiVersion: policy.open-cluster-management.io/v1
kind: PlacementBinding
metadata:
  name: policy-deploy-open5gs-gitops-app-placementbinding
placementRef:
  name: policy-deploy-open5gs-gitops-app-placementrule
  kind: PlacementRule
  apiGroup: apps.open-cluster-management.io
subjects:
- name: policy-deploy-open5gs-gitops-app
  kind: Policy
  apiGroup: policy.open-cluster-management.io
---
apiVersion: apps.open-cluster-management.io/v1
kind: PlacementRule
metadata:
  name: policy-deploy-open5gs-gitops-app-placementrule
spec:
  clusterConditions:
  - status: "True"
    type: ManagedClusterConditionAvailable
  clusterSelector:
    matchExpressions:
      - {key: 5g, operator: In, values: ["true", "maybe"]}
EOF
