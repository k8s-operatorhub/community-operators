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
web console. For a list of available versions, see the [versions.yaml](/pkg/istioversion/versions.yaml) file
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
apiVersion: sailoperator.io/v1
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

For installation steps, refer to the following [link](../docs/common/install-istioctl-tool.md).

## Installing the Bookinfo Application

You can use the `bookinfo` example application to explore service mesh features. 
Using the `bookinfo` application, you can easily confirm that requests from a 
web browser pass through the mesh and reach the application.

For installation steps, refer to the following [link](../docs/common/install-bookinfo-app.md).


## Creating and Configuring Gateways

The Sail Operator does not deploy Ingress or Egress Gateways. Gateways are not 
part of the control plane. As a security best-practice, Ingress and Egress 
Gateways should be deployed in a different namespace than the namespace that 
contains the control plane.

You can deploy gateways using either the Gateway API or Gateway Injection methods. 

For installation steps, refer to the following [link](../docs/common/create-and-configure-gateways.md).


## Istio Addons Integrations

Istio can be integrated with other software to provide additional functionality 
(More information can be found in: https://istio.io/latest/docs/ops/integrations/). 
The following addons are for demonstration or development purposes only and 
should not be used in production environments:

For installation steps, refer to the following [link](../docs/common/istio-addons-integrations.md).


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
