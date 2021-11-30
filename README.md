# Kubernetes Community Operators
[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)

## About this repository

This repo is the canonical source for Kubernetes Operators that appear on [OperatorHub.io](https://operatorhub.io).

## Documentation

Full documentation is generated via [mkdoc](https://www.mkdocs.org/) and is located at [https://k8s-operatorhub.github.io/community-operators/](https://k8s-operatorhub.github.io/community-operators/)

## IMPORTANT NOTICE

**IMPORTANT** Kubernetes has been deprecating API(s) which was removed and are no longer available in Kubernetes `1.22`+ 
and in the Openshift version `4.9`+. It is strongly recommended to check [Deprecated API Migration Guide from v1.22][k8s-deprecated-guide] 
and ensure that your projects have them migrated and are not using any removed API.

If you publish distributions that still using the removed APIs then, you **MUST** ensure that its CSV has the 
informative metadata annotation `operators.operatorframework.io/maxKubeVersion`. In this case, it ought to have the value `1.22`:

```yml
kind: ClusterServiceVersion
metadata:
  annotations:
     operators.operatorframework.io/maxKubeVersion: 1.21
  ...
```

**NOTE** This annotation has the purpose to inform your Operator consumers that the version is not workable on K8S clusters 
bigger than 1.21. Also, please use the spec `minKubeVersion` in the CSV to let your users know what is the minimal K8S 
version supported by your Operator. 

## Reporting Bugs

Use the issue tracker in this repository to report bugs.

[k8s-deprecated-guide]: https://kubernetes.io/docs/reference/using-api/deprecation-guide/#v1-22
