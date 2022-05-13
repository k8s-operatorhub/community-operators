# Kubernetes Community Operators
[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)

## About this repository

This repo is the canonical source for Kubernetes Operators that appear on [OperatorHub.io](https://operatorhub.io).
The solutions merged on this repository are distributed via the [OLM][olm] index catalog [quay.io/operatorhubio/catalog][quay.io].
Users can install [OLM][olm] in any Kubernetes or vendor such as Openshift to consume this content by adding a new CatalogSource for the index image `quay.io/operatorhubio/catalog`. [(more info)][catalog]

**NOTE** If you are looking to distribute solutions on Openshift/OKD catalog then, you also should publish them 
into the repository [Community Operators](https://github.com/redhat-openshift-ecosystem/community-operators-prod).

## Documentation

Full documentation is generated via [mkdoc](https://www.mkdocs.org/) and is located at [https://k8s-operatorhub.github.io/community-operators/](https://k8s-operatorhub.github.io/community-operators/)

## IMPORTANT NOTICE

**IMPORTANT** Kubernetes has been deprecating API(s) which will be removed and no longer available in `1.22` and in the Openshift version `4.9`. Note that your project will be unable to use them on `OCP 4.9/K8s 1.22` and then, it is strongly recommended to check [Deprecated API Migration Guide from v1.22][k8s-deprecated-guide] and ensure that your projects have them migrated and are not using any deprecated API.

## Reporting Bugs

Use the issue tracker in this repository to report bugs.

[k8s-deprecated-guide]: https://kubernetes.io/docs/reference/using-api/deprecation-guide/#v1-22
[olm]: https://github.com/operator-framework/operator-lifecycle-manager
[quay.io]: https://quay.io/repository/operatorhubio/catalog?tag=latest&tab=tags
[catalog]: https://k8s-operatorhub.github.io/community-operators/testing-operators/#1-create-the-catalogsource