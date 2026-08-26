FROM scratch

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=prometheus
LABEL operators.operatorframework.io.bundle.channels.v1=beta
LABEL operators.operatorframework.io.bundle.channel.default.v1=beta

# Copy files to locations specified by labels.
COPY manifests /manifests/
COPY metadata /metadata/
