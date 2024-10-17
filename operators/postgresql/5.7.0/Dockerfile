# Used to build the bundle image. This file is ignored by the community operator
# registries which work with bundle directories instead.
# https://operator-framework.github.io/community-operators/packaging-operator/

FROM scratch AS builder

COPY manifests/ /build/manifests/
COPY metadata/ /build/metadata/
COPY tests/ /build/tests


FROM scratch

# ANNOTATIONS is replaced with bundle.annotations.yaml
LABEL \
	operators.operatorframework.io.bundle.mediatype.v1="registry+v1" \
	operators.operatorframework.io.bundle.manifests.v1="manifests/" \
	operators.operatorframework.io.bundle.metadata.v1="metadata/" \
	operators.operatorframework.io.test.mediatype.v1="scorecard+v1" \
	operators.operatorframework.io.test.config.v1="tests/scorecard/" \
	operators.operatorframework.io.bundle.package.v1="postgresql" \
	operators.operatorframework.io.bundle.channels.v1="v5" \
	operators.operatorframework.io.bundle.channel.default.v1="v5" \
	com.redhat.delivery.operator.bundle=true \
	com.redhat.openshift.versions="v4.12" \
	org.opencontainers.image.authors="info@crunchydata.com" \
	org.opencontainers.image.url="https://crunchydata.com" \
	org.opencontainers.image.vendor="Crunchy Data"

COPY --from=builder /build/ /
