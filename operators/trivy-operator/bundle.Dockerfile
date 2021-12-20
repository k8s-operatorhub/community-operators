FROM scratch

LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=trivy-operator
LABEL operators.operatorframework.io.bundle.channels.v1=alpha
COPY 0.0.1/manifests /manifests/
COPY 0.0.1/metadata /metadata/
