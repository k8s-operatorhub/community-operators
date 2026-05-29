# OperatorHub.io bundle image for forge-operator 1.0.0.
#
# Build context is this directory (operators/forge-operator/1.0.0/),
# so the COPY paths are relative to the bundle layout siblings.
FROM scratch

LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=forge-operator
LABEL operators.operatorframework.io.bundle.channels.v1=alpha
LABEL operators.operatorframework.io.bundle.channel.default.v1=alpha

COPY manifests /manifests/
COPY metadata  /metadata/
