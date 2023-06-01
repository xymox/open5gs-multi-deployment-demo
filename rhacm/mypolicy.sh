apiVersion: policy.open-cluster-management.io/v1
kind: Policy
metadata:
  name: policy-enable-sctp-for-5g
  annotations:
    policy.open-cluster-management.io/standards: NIST SP 800-53
    policy.open-cluster-management.io/categories: CM Configuration Management 
    policy.open-cluster-management.io/controls: CM-2 Baseline Configuration
spec:
  remediationAction: enforce
  disabled: false
  policy-templates:
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        metadata:
          name: policy-open5gs-application
        spec:
          remediationAction: enforce
          severity: low
          namespaceSelector:
            exclude: ["kube-*","openshift-*"]
            include: ["*"]
          object-templates:
            - complianceType: musthave
              objectDefinition:
                apiVersion: app.k8s.io/v1beta1
                kind: Application
                metadata:
                  name: open5gs-demo-acm
                  namespace: open5gs-demo-acm
                spec:
                  componentKinds:
                  - group: apps.open-cluster-management.io
                    kind: Subscription
                  descriptor: {}
                  selector:
                    matchExpressions:
                    - key: app
                      operator: In
                      values:
                      - open5gs-demo-acm-gitops
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        metadata:
          name: policy-open5gs-channel
        spec:
          remediationAction: enforce
          severity: low
          namespaceSelector:
            exclude: ["kube-*","openshift-*"]
            include: ["*"]
          object-templates:
            - complianceType: musthave
              objectDefinition:
                apiVersion: apps.open-cluster-management.io/v1
                kind: Channel
                metadata:
                  annotations:
                    apps.open-cluster-management.io/reconcile-rate: medium
                  name: open5gs-demo-acm-gitops-channel
                  namespace: open5gs-demo-acm
                spec:
                  type: GitHub
                  pathname: https://github.com/xymox/open5gs-multi-deployment-demo.git
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        metadata:
          name: policy-open5gs-kustomization
        spec:
          remediationAction: enforce
          severity: low
          namespaceSelector:
            exclude: ["kube-*","openshift-*"]
            include: ["*"]
          object-templates:
            - complianceType: musthave
              objectDefinition:
                ---
                apiVersion: kustomize.config.k8s.io/v1beta1
                kind: Kustomization
                
                # commonAnnotations:
                #   demo: open5gs
                
                commonLabels:
                  demo: open5gs
                
                resources:
                - application.yaml
                - channel.yaml
                - namespace.yaml
                - placementrule.yaml
                - subscription.yaml
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        metadata:
          name: policy-open5gs-namespace
        spec:
          remediationAction: enforce
          severity: low
          namespaceSelector:
            exclude: ["kube-*","openshift-*"]
            include: ["*"]
          object-templates:
            - complianceType: musthave
              objectDefinition:
                ---
                apiVersion: v1
                kind: Namespace
                metadata:
                  name: open5gs-demo-acm
                  labels:
                    openshift.io/cluster-monitoring: "true"
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        metadata:
          name: policy-open5gs-placementrule
        spec:
          remediationAction: enforce
          severity: low
          namespaceSelector:
            exclude: ["kube-*","openshift-*"]
            include: ["*"]
          object-templates:
            - complianceType: musthave
              objectDefinition:
                apiVersion: apps.open-cluster-management.io/v1
                kind: PlacementRule
                metadata:
                  labels:
                    app: open5gs-demo-acm
                  name: open5gs-demo-acm-placement
                  namespace: open5gs-demo-acm
                spec:
                  clusterSelector:
                    matchExpressions:
                      - {key: 5g, operator: In, values: ["true", "maybe"]}
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        metadata:
          name: policy-open5gs-subscription
        spec:
          remediationAction: enforce
          severity: low
          namespaceSelector:
            exclude: ["kube-*","openshift-*"]
            include: ["*"]
          object-templates:
            - complianceType: musthave
              objectDefinition:
                apiVersion: apps.open-cluster-management.io/v1
                kind: Subscription
                metadata:
                  annotations:
                  labels:
                    app: open5gs-demo-acm-gitops
                    app.kubernetes.io/part-of: open5gs-demo-acm
                    apps.open-cluster-management.io/reconcile-rate: medium
                    apps.open-cluster-management.io/github-path: gitops
                    apps.open-cluster-management.io/github-branch: main
                  name: open5gs-demo-acm-gitops-subscription
                  namespace: open5gs-demo-acm
                spec:
                  hooksecretref:
                    name: aap-cred-2
                  channel: open5gs-demo-acm/open5gs-demo-acm-gitops-channel
                  name: open5gs-5gcore-helm
                  placement:
                    placementRef:
                      kind: PlacementRule
                      name: open5gs-demo-acm-placement
