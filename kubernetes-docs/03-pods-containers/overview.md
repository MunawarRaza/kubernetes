## What is Pod
Pods are the smallest deployable units of computing that you can create and manage in Kubernetes.
A Pod is a group of one or more containers, with shared storage and network resources, and a specification for how to run the container

## Pod templates
PodTemplates are specifications for creating Pods
e.g

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```
When the Pod template for a workload resource is changed, the controller creates new Pods based on the updated template instead of updating or patching the existing Pods.

## Pod lifecycle
Pod follows a defined lifecycle

Below are the possible phases of Pod

Pending --> Running (if at least one container is starts ok) --> Succeeded/Failed/Unknown

### Pending

The Pod has been accepted by the Kubernetes cluster, but one or more of the containers has not been set up and made ready to run

### Running
The Pod has been bound to a node, and all of the containers have been created. At least one container is still running, or is in the process of starting or restarting.

### Succeeded
All containers in the Pod have terminated in success, and will not be restarted

### Failed
All containers in the Pod have terminated, and at least one container has terminated in failure. That is, the container either exited with non-zero status or was terminated by the system, and is not set for automatic restarting

### Unknown
For some reason the state of the Pod could not be obtained. This phase typically occurs due to an error in communicating with the node where the Pod should be running.

### CrashLoopBackOff
When a pod is failing to start repeatedly

### Terminated
When a pod is being deleted

Pods are 
- created
- assigned a unique ID (UID)
- scheduled to run on nodes where they remain until termination (according to restart policy) or deletion.
- If Node dies, pods running on that node are marked for deletion


## Pod lifetime
At the same time pod is running, kubelet is able to restart the container inside the pod to handle some kind of faults.

## Container states
There are three possible container states
1. Waiting
2. Running
3. Terminated

### Waiting
A container in the Waiting state is still running the operations it requires in order to complete start up: for example, pulling the container image from a container image registry, or applying Secret data.

### Running 
The Running status indicates that a container is executing without issues. If there was a postStart hook configured, it has already executed and finished

### Terminated
Terminate manually or failed for some reason.

If a container has a preStop hook configured, this hook runs before the container enters the Terminated state


## Container probes
A probe is a diagnostic performed periodically by the kubelet on a container. To perform a diagnostic, the kubelet either executes code within the container, or makes a network request.

### Mechanisms 
There are four different ways to check a container using a probe.

#### exec
Executes a specified command inside the container. The diagnostic is considered successful if the command exits with a status code of 0.

##### grpc
Performs a remote procedure call using gRPC. The target should implement gRPC health checks. The diagnostic is considered successful if the status of the response is SERVING.

#### httpGet
Performs an HTTP GET request against the Pod's IP address on a specified port and path. The diagnostic is considered successful if the response has a status code greater than or equal to 200 and less than 400.

#### tcpSocket
Performs a TCP check against the Pod's IP address on a specified port. The diagnostic is considered successful if the port is open. If the remote system (the container) closes the connection immediately after it opens, this counts as healthy.

### Probe outcome

- Success: The container passed the diagnostic.

- Failure: The container failed the diagnostic.

- Unknown: The diagnostic failed (no action should be taken, and the kubelet will make further checks).

### Types of probe

#### livenessProbe
Indicates whether the container is running. If the liveness probe fails, the kubelet kills the container, and the container is subjected to its restart policy.

#### readinessProbe
Indicates whether the container is ready to respond to requests. If the readiness probe fails, the EndpointSlice controller removes the Pod's IP address from the EndpointSlices of all Services that match the Pod.

#### startupProbe
Indicates whether the application within the container is started. All other probes are disabled if a startup probe is provided, until it succeeds. If the startup probe fails, the kubelet kills the container, and the container is subjected to its restart policy.


any kubernetes yml file contains the following fields

apiVersion:
kind:
    kind    | version
    =================
    Pod         | v1
    Service     | v1
    ReplicaSet  | apps/v1
    Deployment  | apps/v1

metadata:

spec: