# See https://github.com/operator-framework/operator-registry/blob/master/docs/design/operator-bundle.md#Bundle-Dockerfile

FROM scratch

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=clever-operator
LABEL operators.operatorframework.io.bundle.channels.v1=alpha
LABEL operators.operatorframework.io.bundle.channel.default.v1=alpha

# Labels for testing.
LABEL operators.operatorframework.io.test.mediatype.v1=scorecard+v1
LABEL operators.operatorframework.io.test.config.v1=tests/scorecard/

# Label for OpenShift.
LABEL com.redhat.openshift.versions=v4.6-v4.9

# Copy files to locations specified by labels.
ADD manifests /manifests/
ADD metadata /metadata/
ADD tests/scorecard /tests/scorecard/

