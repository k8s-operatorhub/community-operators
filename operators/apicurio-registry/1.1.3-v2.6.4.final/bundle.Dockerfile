FROM scratch

LABEL com.redhat.openshift.versions=v4.6

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=apicurio-registry
LABEL operators.operatorframework.io.bundle.channels.v1=2.x
LABEL operators.operatorframework.io.bundle.channel.default.v1=2.x
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-v1.13.0+git
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=go.kubebuilder.io/v3

# Labels for testing.
LABEL operators.operatorframework.io.test.mediatype.v1=scorecard+v1
LABEL operators.operatorframework.io.test.config.v1=tests/scorecard/

# Copy files to locations specified by labels.
COPY bundle/1.1.3-v2.6.4.final/manifests /manifests/
COPY bundle/1.1.3-v2.6.4.final/metadata /metadata/
COPY bundle/1.1.3-v2.6.4.final/tests/scorecard /tests/scorecard/
