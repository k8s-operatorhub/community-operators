FROM scratch
LABEL com.redhat.openshift.versions="v4.5-v4.7"
LABEL com.redhat.delivery.backport=true
LABEL com.redhat.delivery.operator.bundle=true

LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=mongodb-atlas-kubernetes
LABEL operators.operatorframework.io.bundle.channels.v1=beta
LABEL operators.operatorframework.io.bundle.channel.default.v1=beta
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-v1.4.2
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=go.kubebuilder.io/v3
LABEL operators.operatorframework.io.test.config.v1=tests/scorecard/
LABEL operators.operatorframework.io.test.mediatype.v1=scorecard+v1

COPY manifests /manifests/
COPY metadata /metadata/
COPY tests/scorecard /tests/scorecard/
