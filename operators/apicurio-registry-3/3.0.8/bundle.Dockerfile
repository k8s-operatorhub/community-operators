FROM scratch

LABEL com.redhat.openshift.versions=v4.12

LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=apicurio-registry-3
LABEL operators.operatorframework.io.bundle.channels.v1=3.x
LABEL operators.operatorframework.io.bundle.channel.default.v1=3.x

COPY target/bundle/apicurio-registry-3/3.0.8/manifests /manifests/
COPY target/bundle/apicurio-registry-3/3.0.8/metadata /metadata/
