FROM scratch

# Core 1.6.1 labels.
LABEL operators.operatorframework.io.bundle.channel.default.v1=alpha
LABEL operators.operatorframework.io.1.6.1.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.1.6.1.manifests.v1=manifests/
LABEL operators.operatorframework.io.1.6.1.metadata.v1=metadata/
LABEL operators.operatorframework.io.1.6.1.package.v1=dynatrace-operator
LABEL operators.operatorframework.io.1.6.1.channels.v1=alpha
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-v1.36.0
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=go.kubebuilder.io/v3

# Copy files to locations specified by labels.
COPY manifests /manifests/
COPY metadata /metadata/
