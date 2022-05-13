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

Some APIs versions are deprecated and are OR will no longer be served on the Kubernetes version 
`1.22/1.25/1.26` and consequently on vendors like Openshift `4.9/4.12/4.13`.

**What does it mean for you?**

Operator bundle versions using the removed APIs can not work successfully from the respective releases. 
Therefore, it is recommended to check if your solutions are failing in these scenarios to let its users be aware. 
Note that you can inform via the CSV the minimal (`spec.minKubeVersion`) and the max Kubernetes 
version (metadata.annotation `operatorhub.io/ui-metadata-max-k8s-version`) where your solution can 
successfully work. This information can be checked on the details of each release on [OperatorHub.io](https://operatorhub.io).

Please, make sure you check the following announcements:
- [How to deal with removal of v1beta1 CRD removals in Kubernetes 1.22](https://github.com/k8s-operatorhub/community-operators/discussions/468)
- [Kubernetes API removals on 1.25/1.26 might impact your Operator. How to deal with it?](https://github.com/k8s-operatorhub/community-operators/discussions/1194)

> **NOTE** _If you have been distributing solutions on Openshift you might be aware of the 
property `"olm.properties": '[{"type": "olm.maxOpenShiftVersion", "value": "<OCP version>"}]'` 
which can be used to block cluster admins upgrades when they have Operator versions installed that can **not** 
work well in OCP versions higher than the value informed. Nothing prevents you from using this property here, 
however, be aware that it is ignored on [OperatorHub.io](https://operatorhub.io) and that the index catalog built from 
this repository is not part of the Openshift catalog. So that, it can be useful only for those 
who are creating a new Source Catalog on Openshift using the index image: `quay.io/operatorhubio/catalog:latest`._ 

## Reporting Bugs

Use the issue tracker in this repository to report bugs.

[k8s-deprecated-guide]: https://kubernetes.io/docs/reference/using-api/deprecation-guide/#v1-22
[olm]: https://github.com/operator-framework/operator-lifecycle-manager
[quay.io]: https://quay.io/repository/operatorhubio/catalog?tag=latest&tab=tags
[catalog]: https://k8s-operatorhub.github.io/community-operators/testing-operators/#1-create-the-catalogsource