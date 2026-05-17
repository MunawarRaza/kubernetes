## What is Pod
Pods are the smallest deployable units of computing that you can create and manage in Kubernetes.
A Pod is a group of one or more containers, with shared storage and network resources, and a specification for how to run the container

## Pod Group
By default, Kubernetes schedules every Pod individually. However, some tightly-coupled applications need a group of Pods to be scheduled simultaneously to function correctly.

> **Note:**  
>A Pod is not a process, but an environment for running container(s).

## Workload Resources
Following are the common workload resources that manages the pod
- Deployment
- StatefulSet
- DaemonSet

## Static Pods
Static Pods are managed directly by the kubelet daemon on a specific node, without the API server observing them. Whereas most Pods are managed by the control plane (for example, a Deployment), for static Pods, the kubelet directly supervises each static Pod (and restarts it if it fails).

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



## Pod update and replacement
Most of the metadata about a Pod is immutable. For example, you cannot change the `namespace`, `name`, `uid`, or `creationTimestamp` fields.

## Storage in Pods
A Pod can specify a set of shared storage volumes. All containers in the Pod can access the shared volumes, allowing those containers to share data.

## Pod networking
Each Pod is assigned a unique IP address for each address family. Every container in a Pod shares the network namespace, including the IP address and network ports. Inside a Pod (and only then), the containers that belong to the Pod can communicate with one another using localhost

## Pod security settings
To set security constraints on Pods and containers, you use the `securityContext` field in the Pod specification. This field gives you granular control over what a Pod or individual containers can do.

## Resource requests and limits
When you specify a Pod, you can optionally specify how much of each resource a container needs. The most common resources to specify are CPU and memory (RAM)

### Resource Request
When you specify the resource request for containers in a Pod, the kube-scheduler uses this information to decide which node to place the Pod on. 

### Resource Limit
When you specify a resource limit for a container, the kubelet enforces those limits so that the running container is not allowed to use more of that resource than the limit you set.


CPU limits are enforced by CPU throttling. When a container approaches its CPU limit, the kernel restricts its access to CPU. Memory limits are enforced by the kernel with out-of-memory (OOM) kills when a container exceeds its limit.

---

## Pod lifecycle
Pod follows a defined lifecycle

Below are the possible phases of Pod

Pending --> Running (if at least one container is starts ok) --> Succeeded/Failed/Unknown

### Pending

The Pod has been accepted by the Kubernetes cluster, but one or more of the containers has not been set up and made ready to run. This includes time a Pod spends waiting to be scheduled as well as the time spent downloading container images over the network.

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

### Scheduling
The process of selecting which node to use for the pod is called scheduling

### Binding
Assigning a Pod to a specific node is called binding

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

## How Pods handle problems with containers
Kubernetes manages container failures within Pods using a `restartPolicy` defined in the Pod spec. This policy determines how Kubernetes reacts to containers exiting due to errors or other reasons, which falls in the following sequence:
1. Initial crash: Kubernetes attempts an immediate restart based on the Pod restartPolicy
2. Repeated crashes: After the initial crash Kubernetes applies an exponential backoff delay for subsequent restarts, described in restartPolicy. This prevents rapid, repeated restart attempts from overloading the system.
3. CrashLoopBackOff state: This indicates that the backoff delay mechanism is currently in effect for a given container that is in a crash loop, failing and restarting repeatedly.
4. Backoff reset: If a container runs successfully for a certain duration (e.g., 10 minutes), Kubernetes resets the backoff delay, treating any new crash as the first one.

### Scenerio 1
If a Pod is scheduled to a node and that node then fails, the Pod is treated as unhealthy and Kubernetes eventually deletes the Pod. A Pod won't survive an eviction due to a lack of resources or Node maintenance.
### Scenerio 2
when a container enters the crash loop, Kubernetes applies the exponential backoff delay mentioned in the Container restart policy. This mechanism prevents a faulty container from overwhelming the system with continuous failed start attempts.

---
## Container restarts
When a container in the Pod stops, or experiences failure, Kubernetes can restart it.

Pod restart the container on the basis of `restartPolicy` policy.

`restartPolicy` has 3 values
1. Always
    - Automatically restarts the container after any termination.
2. OnFailure
    - Only restarts the container if it exits with an error (non-zero exit status).
3. Never
    - Does not automatically restart the terminated container.

> **Note:**  
>The restart behavior is particularly important when choosing between Deployments and Jobs:
>- Deployments typically use `restartPolicy: Always` (the only allowed value) to keep applications running continuously
>- Jobs commonly use `restartPolicy: OnFailure` or `restartPolicy: Never` to handle batch processing tasks appropriately
>- Sidecar containers are init containers that always restart regardless of the Pod's `restartPolicy` because they have their own container-level `restartPolicy: Always`

There are two levels to configure `restartPolicy`
1. Container level
2. Pod level

### Container level restartPolicy

If we configure the `restartPolicy` at container level, then policy will be applicable to only those containers not all. 

For Example

if there are 10 containers and we implement restartPolicy to only 5 containers then only that policy will be applicable for only those containers not for all.

> **Note:**  
>- Sidecar containers follow the restartPolicy at container level.
>- Sidecar container always has `restartPolicy: Always'

### Pod-level container restart policy

If we configure the `restartPolicy` at pod level, then policy will be applicable to all containers.

> **Note:**  
>App or regular containers follow the pod-level

#### Scenerio 1
While the main application container follows the Pod's restartPolicy: OnFailure, the sidecar container will restart regardless of its exit code because sidecar containers always have restartPolicy: Always at the container level.

### Container Restart Policy and Rule
If your cluster has the feature gate `ContainerRestartRules` enabled, you can specify `restartPolicy` and `restartPolicyRules` on individual containers to override the Pod restart policy. Container restart policy and rules applies to app containers in the Pod and to regular init containers.

Additionally, individual containers can specify `restartPolicyRules`. If the `restartPolicyRules` field is specified, then container `restartPolicy` <b>must</b> also be specified. The `restartPolicyRules` define a list of rules to apply on container exit. Each rule will consist of a <b>condition</b> and an <b>action</b>. The supported <b>condition</b> is `exitCodes`, which compares the exit code of the container with a list of given values. The supported <b>action</b> is Restart, which means the container will be restarted. The rules will be evaluated in order. On the first match, the action will be applied. If none of the rules’ conditions matched, Kubernetes fallback to container’s configured `restartPolicy`.


### Reduced container restart delay

---

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
Indicates whether the container is running. If the liveness probe fails, the kubelet kills the container, and the container is subjected to its restart policy. If a container does not provide a liveness probe, the default state is Success.

#### readinessProbe
Indicates whether the container is ready to respond to requests. If the readiness probe fails, the EndpointSlice controller removes the Pod's IP address from the EndpointSlices of all Services that match the Pod.

#### startupProbe
Indicates whether the application within the container is started. All other probes are disabled if a startup probe is provided, until it succeeds. If the startup probe fails, the kubelet kills the container, and the container is subjected to its restart policy.

#### When should you use a liveness probe?

If the process in your container is able to crash on its own whenever it encounters an issue or becomes unhealthy, you do not necessarily need a liveness probe; the kubelet will automatically perform the correct action in accordance with the Pod's restartPolicy.

If you'd like your container to be killed and restarted if a probe fails, then specify a liveness probe, and specify a restartPolicy of Always or OnFailure.

#### When should you use a readiness probe?
If you'd like to start sending traffic to a Pod only when a probe succeeds, specify a readiness probe. In this case, the readiness probe might be the same as the liveness probe, but the existence of the readiness probe in the spec means that the Pod will start without receiving any traffic and only start receiving traffic after the probe starts succeeding.

If you want your container to be able to take itself down for maintenance, you can specify a readiness probe that checks an endpoint specific to readiness that is different from the liveness probe.

If your app has a strict dependency on back-end services, you can implement both a liveness and a readiness probe. The liveness probe passes when the app itself is healthy, but the readiness probe additionally checks that each required back-end service is available. This helps you avoid directing traffic to Pods that can only respond with error messages.

If your container needs to work on loading large data, configuration files, or migrations during startup, you can use a startup probe. However, if you want to detect the difference between an app that has failed and an app that is still processing its startup data, you might prefer a readiness probe.

#### When should you use a startup probe?
Startup probes are useful for Pods that have containers that take a long time to come into service. Rather than set a long liveness interval, you can configure a separate configuration for probing the container as it starts up, allowing a time longer than the liveness interval would allow.

If your container usually starts in more than `initialDelaySeconds+failureThreshold×periodSeconds`, you should specify a startup probe that checks the same endpoint as the liveness probe. The default for periodSeconds is 10s. You should then set its failureThreshold high enough to allow the container to start, without changing the default values of the liveness probe. This helps to protect against deadlocks.

## Questions
### Basic understanding
- What is a Pod?
- Why does Kubernetes use Pods instead of containers directly?
- Can a Pod contain multiple containers?
- How do containers inside a pod communicate?
- What is the lifecycle of a Pod?
- What happens when a Pod crashes?
- Are Pods permanent?

### Scheduling & placement
- How does Kubernetes schedule a Pod?
- What is nodeSelector?
- What are affinity and anti-affinity?
- What are taints and tolerations?
- How to force a Pod to run on a specific node?

### Networking
- Does each Pod get its own IP?
- How do Pods communicate across nodes?
- What is Pod networking model?
- How to expose a Pod to outside world?

### Storage
- How to attach storage to a Pod?
- What is an emptyDir volume?
- What is a PersistentVolume?
- How do Pods share data between containers?

### Health checks

What is liveness probe?
What is readiness probe?
What is startup probe?
What happens when liveness fails?

### Security
- What is a ServiceAccount?
- How to run a Pod as non-root?
- What are security contexts?
- How to restrict container capabilities?

### Resource management

- What are CPU/memory requests?
- What are limits?
- What happens when Pod exceeds memory limit?
- What is OOMKilled?

### Debugging

- Why is my Pod in CrashLoopBackOff?
- Why is Pod stuck in Pending state?
- How to debug ImagePullBackOff?
- How to debug ContainerCreating?
### Troubleshooting checklist (real-world)
- kubectl get pods
- kubectl describe pod
- kubectl logs
- Check events
- Check image pull
- Check resource limits
- Check node status
- Check volumes
- Check probes
- Check network

### Daily routine pod operations
1. Check pod health
2. Debug failing pods
3. Restart pod
4. Port forward to pod
5. Copy files to/from pod
6. Watch pod in real time
7. Check pod resource usage
8. Delete stuck pod
9. View pod YAML



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