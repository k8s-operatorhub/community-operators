FROM scratch

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1: registry+v1
LABEL operators.operatorframework.io.bundle.metadata.v1: metadata/
LABEL operators.operatorframework.io.bundle.manifests.v1: manifests/
LABEL operators.operatorframework.io.bundle.package.v1: kubearmor-operator
LABEL operators.operatorframework.io.bundle.channels.v1: stable
LABEL operators.operatorframework.io.bundle.channel.default.v1: stable
LABEL operators.operatorframework.io.metrics.builder: operator-sdk-v1.31.0
LABEL operators.operatorframework.io.metrics.mediatype.v1: metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout: go.kubebuilder.io/v4
LABEL com.redhat.openshift.versions: v4.9

# Copy files to locations specified by labels.
COPY manifests /manifests/
COPY metadata /metadata/
