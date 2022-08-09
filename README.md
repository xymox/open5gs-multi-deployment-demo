# open5gs-multi-deployment-demo

## Open5gs multi deployment demo

open5gs-multi-deployment-demo (this project): https://github.com/xymox/open5gs-multi-deployment-demo/


## Run UE

ueransim-k8s

## Build open5gs new images

open5gs-ubi8-buildimage


# Setup

## Configure subscription-admin role to use split namespaces

```bash
oc patch clusterrolebinding open-cluster-management:subscription-admin \
  --type='json' \
  -p='[
  {
    "op": "add",
    "path": "/subjects/-",
    "value": {
      "apiGroup": "rbac.authorization.k8s.io",
      "kind": "User",
      "name": "phuet"
    }
  }
]'
```
