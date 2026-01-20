FROM scratch

#Add these labels
LABEL com.redhat.openshift.versions="v4.14-v4.20"
LABEL com.redhat.delivery.operator.bundle=true
LABEL com.redhat.delivery.backport=true


# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=hpe-csi-operator
LABEL operators.operatorframework.io.bundle.channels.v1=stable
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-v1.39.1
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=helm.sdk.operatorframework.io/v1

# Labels for testing.
LABEL operators.operatorframework.io.test.mediatype.v1=scorecard+v1
LABEL operators.operatorframework.io.test.config.v1=tests/scorecard/

# Copy files to locations specified by labels.
COPY bundle/manifests /manifests/
COPY bundle/metadata /metadata/
COPY bundle/tests/scorecard /tests/scorecard/
