FROM scratch
# Labels for RedHat Openshift Platform
LABEL com.redhat.delivery.backport=false
LABEL com.redhat.delivery.operator.bundle=true
LABEL com.redhat.openshift.versions=v4.11
LABEL org.opencontainers.image.description="Redkey Operator OLM Bundle"

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=redkey-operator
LABEL operators.operatorframework.io.bundle.channels.v1=alpha,beta,stable
LABEL operators.operatorframework.io.bundle.channel.default.v1=stable
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-v1.42.3
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=go.kubebuilder.io/v4

# Labels for testing.
LABEL operators.operatorframework.io.test.mediatype.v1=scorecard+v1
LABEL operators.operatorframework.io.test.config.v1=tests/scorecard/

# Copy files to locations specified by labels.
COPY /manifests /manifests/
COPY /metadata /metadata/
COPY /tests/scorecard /tests/scorecard/
