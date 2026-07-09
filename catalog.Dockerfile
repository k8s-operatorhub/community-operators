# FBC-native catalog image for quay.io/operatorhubio/catalog.
#
# Operators that opt into the FBC workflow (fbc.enabled: true in ci.yaml)
# contribute rendered catalog.yaml files under catalogs/latest/<operator>/.
# This Dockerfile builds a single, OPM-native catalog image from that tree.
#
# Build:
#   opm generate dockerfile catalogs/latest
#   docker build -f catalog.Dockerfile -t quay.io/operatorhubio/catalog:latest .
#
# Usage as a CatalogSource:
#   image: quay.io/operatorhubio/catalog:latest

# The base image provides /bin/opm and /bin/grpc_health_probe.
FROM quay.io/operator-framework/opm:latest

ENTRYPOINT ["/bin/opm"]
CMD ["serve", "/configs", "--cache-dir=/tmp/cache"]

# Copy rendered FBC catalog tree into /configs and pre-populate the serve cache.
ADD catalogs/latest /configs
RUN ["/bin/opm", "serve", "/configs", "--cache-dir=/tmp/cache", "--cache-only"]

LABEL operators.operatorframework.io.index.configs.v1=/configs
