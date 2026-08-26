FROM scratch

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.channel.default.v1=fast
LABEL operators.operatorframework.io.bundle.channels.v1=fast
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=keycloak-operator
LABEL operators.operatorframework.io.metrics.builder=qosdk-bundle-generator/6.6.3+5e1449d
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=quarkus.javaoperatorsdk.io/v1-alpha

# Copy files to locations specified by labels.
COPY manifests /manifests/
COPY metadata /metadata/
