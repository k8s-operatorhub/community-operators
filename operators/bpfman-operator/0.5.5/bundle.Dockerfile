FROM registry.access.redhat.com/ubi9/ubi-minimal:latest as builder-runner
RUN microdnf install -y skopeo jq python3 python3-pip
RUN pip3 install --upgrade pip && pip3 install ruamel.yaml==0.17.9

# Use a new stage to enable caching of the package installations for local development
FROM builder-runner as builder

#Copy files to locations specified by labels.
COPY bundle/manifests /manifests/
COPY bundle/metadata /metadata/
COPY bundle/tests/scorecard /tests/scorecard/
COPY hack/update_bundle.sh .
COPY hack/update_configmap.sh .
RUN ./update_bundle.sh
RUN ./update_configmap.sh

FROM scratch

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=bpfman-operator
LABEL operators.operatorframework.io.bundle.channels.v1=alpha
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-v1.26.0
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=go.kubebuilder.io/v3

# Labels for testing.
LABEL operators.operatorframework.io.test.mediatype.v1=scorecard+v1
LABEL operators.operatorframework.io.test.config.v1=tests/scorecard/

# Labels for konflux to release the images
LABEL name="bpfman-operator" \
      com.redhat.component="bpfman-operator" \
      io.k8s.display-name="Bpfman Operator" \
      description="The bpfman-operator manage bpfman ebpf programs on every node." \
      distribution-scope=public \
      io.k8s.description="The bpfman-operator manage bpfman programs on every node. ." \
      io.openshift.tags="bpfman-operator" \
      version="0.5.5" \
      release="0.5.5" \
      url="https://github.com/bpfman/bpfman-operator" \
      vendor="Red Hat, Inc." \
      summary="Bpfman Operator"

# Copy files to locations specified by labels.
COPY --from=builder /manifests /manifests/
COPY --from=builder /metadata /metadata/
COPY bundle/tests/scorecard /tests/scorecard/
