# About the Sail Operator

The Sail Operator is able to install and manage the lifecycle of the Istio 
control plane in an OpenShift cluster.


## Prerequisites

You have deployed a cluster on OpenShift Container Platform 4.13 or later.

You are logged in to the OpenShift Container Platform web console as a user with 
the `cluster-admin` role.

You have access to the OpenShift CLI (oc).


## Installing the Sail Operator

1. Navigate to the OperatorHub.

1. Click **Operator** -> **Operator Hub**.

1. Search for "sail".

1. Locate the Sail Operator, and click to select it.

1. When the prompt that discusses the community operator appears, click **Continue**.

1. Verify the Sail Operator is version 0.1, and click **Install**.

1. Use the default installation settings presented, and click **Install** to continue.

1. Click **Operators** -> **Installed Operators** to verify that the Sail Operator 
is installed. `Succeeded` should appear in the **Status** column.


## Deploying Istio

To deploy Istio, you must create two resources: `Istio` and `IstioCNI`. The 
`Istio` resource deploys and configures the Istio Control Plane, whereas the 
`IstioCNI` resource deploys and configures the Istio CNI plugin. You should 
create these resources in separate projects. 


### Creating the istio-system and istio-cni Projects

1. In the OpenShift Container Platform web console, click **Home** -> **Projects**. 

1. Click **Create Project**.

1. At the prompt, you must enter a name for the project in the **Name** field. 
For example, `istio-system`. The Operator deploys Istio to the project you 
specify. The other fields provide supplementary information and are optional.

1. Click **Create**.

Repeat the process to create a project named `istio-cni`.


### Creating the Istio resource

1. In the OpenShift Container Platform web console, click **Operators** -> **Installed Operators**. 
1. Select the `istio-system` project from the **Namespace** drop-down menu.
1. Click the Sail Operator.
1. Click **Istio**.
1. Click **Create Istio**.
1. Click **Create**. This action deploys the Istio control plane.
1. When `State: Healthy` appears in the `Status` column, Istio is successfully deployed.


### Creating the IstioCNI resource

1. In the OpenShift Container Platform web console, click **Operators** -> **Installed Operators**. 
1. Click the Sail Operator.
1. Click **IstioCNI**.
1. Click **Create IstioCNI**.
1. Ensure that the name is `default`.
1. Select the `istio-cni` project from the **Namespace** drop-down menu.
1. Click **Create**. This action deploys the Istio CNI plugin.
1. When `State: Healthy` appears in the `Status` column, the Istio CNI plugin is successfully deployed.


### Selecting the Istio and IstioCNI versions

The `version` field of the `Istio` and `IstioCNI` resource defines which version 
of each component should be deployed. This can be set using the `Istio Version` 
drop down menu when creating a new `Istio` with the OpenShift Container Platform 
web console. For a list of available versions, see the [versions.yaml](/versions.yaml) file
or use the command:

  ```sh
  $ kubectl explain istio.spec.version
  ```

### Customizing Istio configuration

The `spec.values` field of the `Istio` and `IstioCNI` resource can be used to 
customize Istio and Istio CNI plugin configuration using Istio's `Helm` 
configuration values. When you create this resource using the OpenShift 
Container Platform web console, it is pre-populated with configuration settings 
to enable Istio to run on OpenShift.

To view or modify the `Istio` resource from the OpenShift Container Platform web console:

1. Click **Operators** -> **Installed Operators**.
1. Click **Istio** in the **Provided APIs** column.
1. Click `Istio` instance, "istio-sample" by default, in the **Name** column.
1. Click **YAML** to view the `Istio` configuration and make modifications.

An example configuration:

```
apiVersion: sailoperator.io/v1alpha1
kind: Istio
metadata:
  name: example
spec:
  version: v1.20.0
  values:
    global:
      mtls:
        enabled: true
      trustDomainAliases:
      - example.net
    meshConfig:
      trustDomain: example.com
      trustDomainAliases:
      - example.net
```

For a list of available configuration for the `spec.values` field, run the 
following command:

  ```sh
  $ kubectl explain istio.spec.values
  ```

For the `IstioCNI` resource, replace `istio` with `istiocni` in the command above.

Alternatively, refer to [Istio's artifacthub chart documentation](https://artifacthub.io/packages/search?org=istio&sort=relevance&page=1) for:

- [Base parameters](https://artifacthub.io/packages/helm/istio-official/base?modal=values)
- [Istiod parameters](https://artifacthub.io/packages/helm/istio-official/istiod?modal=values)
- [Gateway parameters](https://artifacthub.io/packages/helm/istio-official/gateway?modal=values)
- [CNI parameters](https://artifacthub.io/packages/helm/istio-official/cni?modal=values)
- [ZTunnel parameters](https://artifacthub.io/packages/helm/istio-official/ztunnel?modal=values)


## Installing the istioctl tool

The `istioctl` tool is a configuration command line utility that allows service 
operators to debug and diagnose Istio service mesh deployments.


### Prerequisites

Use an `istioctl` version that is the same version as the Istio control plane 
for the Service Mesh deployment. See [Istio Releases](https://github.com/istio/istio/releases) for a list of valid 
releases, including Beta releases.


### Procedure

1. Confirm if you have `istioctl` installed, and if so which version, by running 
the following command at the terminal:

    ```sh
    $ istioctl version
    ```

1. Confirm the version of Istio you are using by running the following command 
at the terminal:

    ```sh
    $ oc -n istio-system get istio
    ```

1. Install `istioctl` by running the following command at the terminal: 

    ```sh
    $ curl -sL https://istio.io/downloadIstioctl | ISTIO_VERSION=<version> sh -
    ```
    Replace `<version>` with the version of Istio you are using.

1. Put the `istioctl` directory on path by running the following command at the terminal:
  
    ```sh
    $ export PATH=$HOME/.istioctl/bin:$PATH
    ```

1. Confirm that the `istioctl` client version and the Istio control plane 
version now match (or are within one version) by running the following command
at the terminal:
  
    ```sh
    $ istioctl version
    ```


*Note*: `istioctl install` is not supported. The Sail Operator installs Istio.

## Installing the Bookinfo Application

You can use the `bookinfo` example application to explore service mesh features. 
Using the `bookinfo` application, you can easily confirm that requests from a 
web browser pass through the mesh and reach the application.

The `bookinfo` application displays information about a book, similar to a 
single catalog entry of an online book store. The application displays a page 
that describes the book, lists book details (ISBN, number of pages, and other 
information), and book reviews.

The `bookinfo` application is exposed through the mesh, and the mesh configuration 
determines how the microservices comprising the application are used to serve 
requests. The review information comes from one of three services: `reviews-v1`, 
`reviews-v2` or `reviews-v3`. If you deploy the `bookinfo` application without 
defining the `reviews` virtual service, then the mesh uses a round-robin rule to 
route requests to a service.

By deploying the `reviews` virtual service, you can specify a different behavior. 
For example, you can specify that if a user logs into the `bookinfo` application, 
then the mesh routes requests to the `reviews-v2` service, and the application 
displays reviews with black stars. If a user does not log into the `bookinfo` 
application, then the mesh routes requests to the `reviews-v3` service, and the 
application displays reviews with red stars.

For more information, see [Bookinfo Application](https://istio.io/latest/docs/examples/bookinfo/) in the upstream Istio documentation.

After following the instructions for [Deploying the application](https://istio.io/latest/docs/examples/bookinfo/#start-the-application-services), **you 
will need to create and configure a gateway** for the `bookinfo` application to 
be accessible outside the cluster.


## Creating and Configuring Gateways

The Sail Operator does not deploy Ingress or Egress Gateways. Gateways are not 
part of the control plane. As a security best-practice, Ingress and Egress 
Gateways should be deployed in a different namespace than the namespace that 
contains the control plane.

You can deploy gateways using either the Gateway API or Gateway Injection methods. 


### Option 1: Istio Gateway Injection

Gateway Injection uses the same mechanisms as Istio sidecar injection to create 
a gateway from a `Deployment` resource that is paired with a `Service` resource 
that can be made accessible from outside the cluster. For more information, see 
[Installing Gateways](https://preliminary.istio.io/latest/docs/setup/additional-setup/gateway/#deploying-a-gateway).

To configure gateway injection with the `bookinfo` application, we have provided 
a [sample gateway configuration](../chart/samples/ingress-gateway.yaml?raw=1) that should be applied in the namespace 
where the application is installed:

1. Create the `istio-ingressgateway` deployment and service:

    ```sh
    $ oc apply -f -n <app-namespace> ingress-gateway.yaml
    ```

2. Configure the `bookinfo` application with the new gateway:

    ```sh
    $ oc apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/networking/bookinfo-gateway.yaml
    ```

3. On OpenShift, you can use a [Route](https://docs.openshift.com/container-platform/4.13/networking/routes/route-configuration.html) to expose the gateway externally: 

    ```sh
    $ oc expose service istio-ingressgateway
    ```

4. Finally, obtain the gateway host name and the URL of the product page:

    ```sh
    $ HOST=$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}')
    $ echo http://$HOST/productpage
    ```

Verify that the `productpage` is accessible from a web browser. 


### Option 2: Kubernetes Gateway API

Istio includes support for Kubernetes [Gateway API](https://gateway-api.sigs.k8s.io/) and intends to make it 
the default API for [traffic management in the future](https://istio.io/latest/blog/2022/gateway-api-beta/). For more 
information, see Istio's [Kubernetes Gateway API](https://istio.io/latest/docs/tasks/traffic-management/ingress/gateway-api/) page.

As of Kubernetes 1.28 and OpenShift 4.14, the Kubernetes Gateway API CRDs are 
not available by default and must be enabled to be used. This can be done with 
the command:

```sh
$ oc get crd gateways.gateway.networking.k8s.io &> /dev/null ||  { oc kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.0.0" | oc apply -f -; }
```

To configure `bookinfo` with a gateway using `Gateway API`:

1. Create and configure a gateway using a `Gateway` and `HTTPRoute` resource:

    ```sh
    $ oc apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/gateway-api/bookinfo-gateway.yaml
    ```

2. Retrieve the host, port and gateway URL:

    ```sh
    $ export INGRESS_HOST=$(oc get gtw bookinfo-gateway -o jsonpath='{.status.addresses[0].value}')
    $ export INGRESS_PORT=$(oc get gtw bookinfo-gateway -o jsonpath='{.spec.listeners[?(@.name=="http")].port}')
    $ export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
    ```

3. Obtain the `productpage` URL and check that you can visit it from a browser:

   ```sh
    $ echo "http://${GATEWAY_URL}/productpage"
    ```


## Istio Addons Integrations

Istio can be integrated with other software to provide additional functionality 
(More information can be found in: https://istio.io/latest/docs/ops/integrations/). 
The following addons are for demonstration or development purposes only and 
should not be used in production environments:


### Prometheus

`Prometheus` is an open-source systems monitoring and alerting toolkit. You can 
use `Prometheus` with the Sail Operator to keep an eye on how healthy Istio and 
the apps in the service mesh are, for more information, see [Prometheus](https://istio.io/latest/docs/ops/integrations/prometheus/). 

To install Prometheus, perform the following steps:

1. Deploy `Prometheus`:

    ```sh
    $ oc apply -f https://raw.githubusercontent.com/istio/istio/master/samples/addons/prometheus.yaml
    ```
2. Access to `Prometheus`console:

    * Expose the `Prometheus` service externally:
    
    ```sh
    $ oc expose service prometheus -n istio-system
    ```
    * Get the route of the service and open the URL in the web browser
    
    ```sh
    $ oc get route prometheus -o jsonpath='{.spec.host}' -n istio-system
    ```


### Grafana

`Grafana` is an open-source platform for monitoring and observability. You can 
use `Grafana` with the Sail Operator to configure dashboards for istio, see 
[Grafana](https://istio.io/latest/docs/ops/integrations/grafana/) for more information. 

To install Grafana, perform the following steps:

1. Deploy `Grafana`:
    
    ```sh
    $ oc apply -f https://raw.githubusercontent.com/istio/istio/master/samples/addons/grafana.yaml
    ```

2. Access to `Grafana`console:

    * Expose the `Grafana` service externally
    
    ```sh
    $ oc expose service grafana -n istio-system
    ```
    * Get the route of the service and open the URL in the web browser
    
    ```sh
    $ oc get route grafana -o jsonpath='{.spec.host}' -n istio-system
    ```


### Jaeger

`Jaeger` is an open-source end-to-end distributed tracing system. You can use 
`Jaeger` with the Sail Operator to monitor and troubleshoot transactions in 
complex distributed systems, see [Jaeger](https://istio.io/latest/docs/ops/integrations/jaeger/) for more information. 

To install Jaeger, perform the following steps:

1. Deploy `Jaeger`:
    
    ```sh
    $ oc apply -f https://raw.githubusercontent.com/istio/istio/master/samples/addons/jaeger.yaml
    ```
2. Access to `Jaeger` console:

    * Expose the `Jaeger` service externally:

        ```sh
        $ oc expose svc/tracing -n istio-system
        ```

    * Get the route of the service and open the URL in the web browser

        ```sh
        $ oc get route tracing -o jsonpath='{.spec.host}' -n istio-system
        ```
*Note*: if you want to see some traces you can refresh several times the product 
page of bookinfo app to start generating traces.


### Kiali

`Kiali` is an open-source project that provides a graphical user interface to 
visualize the service mesh topology, see [Kiali](https://istio.io/latest/docs/ops/integrations/kiali/) for more information. 

To install Kiali, perform the following steps:

1. Deploy `Kiali`:
    
    ```sh
    $ oc apply -f https://raw.githubusercontent.com/istio/istio/master/samples/addons/kiali.yaml
    ```

2. Access to `Kiali` console:

    * Expose the `Kiali` service externally:

        ```sh
        $ oc expose service kiali -n istio-system
        ```

    * Get the route of the service and open the URL in the web browser

        ```sh
        $ oc get route kiali -o jsonpath='{.spec.host}' -n istio-system
        ```


## Undeploying Istio and the Sail Operator

### Deleting Istio
1. In the OpenShift Container Platform web console, click **Operators** -> **Installed Operators**.
1. Click **Istio** in the **Provided APIs** column.
1. Click the Options menu, and select **Delete Istio**. 
1. At the prompt to confirm the action, click **Delete**.

### Deleting IstioCNI
1. In the OpenShift Container Platform web console, click **Operators** -> **Installed Operators**.
1. Click **IstioCNI** in the **Provided APIs** column.
1. Click the Options menu, and select **Delete IstioCNI**. 
1. At the prompt to confirm the action, click **Delete**.

### Deleting the Sail Operator
1. In the OpenShift Container Platform web console, click **Operators** -> **Installed Operators**.
1. Locate the Sail Operator. Click the Options menu, and select **Uninstall Operator**. 
1. At the prompt to confirm the action, click **Uninstall**.
 
### Deleting the Projects
1. In the OpenShift Container Platform web console, click  **Home** -> **Projects**.
1. Locate the name of the project and click the Options menu.
1. Click **Delete Project**.
1. At the prompt to confirm the action, enter the name of the project.
1. Click **Delete**.
