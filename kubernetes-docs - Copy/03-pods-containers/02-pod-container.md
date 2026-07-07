## What is Container

## Difference between containerd and docker


<b>containerd:</b> Docker is not just a container runtime, it consists of multiple tools that are put togather like CLI, API, AUTH, BUILD (support building images), VOLUMES, SECURITY and runc (container runtime). The daemon that manages runc is called containerd

<b>CRI:</b>

CRI was introduced by kubernetes so that kubernetes can work with any container run time like rkt, cri

<b>OCI:</b> Open Container Initiative

It contains 
- imagespec
- runtimespec

<b>Imagespec</b> means the specification, how an image should be built

<b>Runtimespec</b> defines how any container runtime should be developed

<b>dockershim:</b> When CRI was introudced, to continnue work/support with docker, kubernetes introudced dockershim. With dockershim, kuernetes was integrated with Docker only and with CRI kubernetes can work with any other runtime.

## Container states

## Types of containers in pod
1. App container
2. Init container
3. Ephemeral container
4. Sidecar container

### 1. App Container
These are the primary containers that run your business logic. Each pod can have one or more containers that run togather and share the resources like networking, storage etc

- <b>Shared Network:</b> <i>Containers in the same pod share the same IP and Port</i>
- <b>Shared Storage:</b> <i>They can mount the same volumes.</i>
- <b>Shared Lifecycle:</b> <i>They are restarted togather if the pod restarts</i>

Example
```
apiVersion: v1
kind: Pod
metadata:
  name: app-container
spec:
  containers:
  - name: my-app
    image: nginx
    ports:
    - containerPort: 80
```
---
### Init Container
Init Container is specialized container that run before app container started in a Pod. 
#### Used For:
- Fetching configuration file
- Performing database schema migrations
- Waiting for dependencies to be ready

Init containers are exactly like regular containers, except:
- Init containers always run to completion.
- Each init container must complete successfully before the next one starts.

If a Pod's init container fails, the kubelet repeatedly restarts that init container until it succeeds. However, if the Pod has a restartPolicy of Never, and an init container fails during startup of that Pod, Kubernetes treats the overall Pod as failed.

#### Key Charecteristics
- <b>Sequencial Execution:</b> <i>Runs in order, one after the other.</i>
- <b>No Restart after Completion:</b> <i>They never restart once successful.</i>
- <b>Pod Fails if init Container fails:</b> <i>Ensure proper startup sequence.</i>
- <b>Supported fields:</b> <i>The supports all the  fields and features of app containers, including resource limits, volumes, and security settings except `lifecycle`, `livenessProbe`, `readinessProbe`, or `startupProbe` fields.</i>
---
### Sidecar Container
Sidecar containers are the secondary containers that run along with the main application container within the same Pod to provide supporting functionality.


Previously Sidecar containers were used to defined under `containers` field. In newer version sidecar container is defined under the `initContainers` field with `restartPolicy: Always`. If `restartPolicy` field is not defined then it will not be sidecar container, it will be considered as init container


Sidecar containers have their own independent lifecycles. They can be started, stopped, and restarted independently of app containers. This means you can update, scale, or maintain sidecar containers without affecting the primary application.

#### Used for
- <b>Logging Agent:</b> <i>Collects and ships logs.</i>
- <b>Data synchronization:</b> <i>Sync content from a remote source </i>
- <b>Monitoring:</b>
- <b>Security:</b>


Sidecar containers remain running after Pod startup. These can be started, stopped, or restarted without affecting the main application container and other init containers.

Example
```
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
spec:
  containers:
  - name: main-app
    image: my-app:latest
  - name: log-collector
    image: fluentd
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  volumes:
  - name: shared-logs
    emptyDir: {}
```

### Ephemeral Container
A special type of container that runs temporarily in an existing Pod to accomplish user-initiated actions such as troubleshooting.

You cannot add a container to a Pod once it has been created.
Sometimes it's necessary to inspect the state of an existing Pod, however, for example to troubleshoot a hard-to-reproduce bug. In these cases you can run an ephemeral container in an existing Pod to inspect its state and run arbitrary commands

- Ephemeral containers may not have ports, so fields such as ports, livenessProbe, readinessProbe are disallowed.
- Pod resource allocations are immutable, so setting resources is disallowed.

---
## Visual Overview
Imagine a pod as small workspace with multiple collaborators
- <b>Init Containers:</b> Prepare the workspace before anyone starts working
- <b>Application Containers:</b> The main workers doing the actual job
- <b>Sidecar Containers:</b> Helpers in the background (like logging assistants)
- <b>Ephemeral Containers:</b> Temporary visitors who come in just for inspection


## Types of Deployment of pod
1- imperative
2- declarative

### Imperative
In this we run pod with command. like
```
kubectl run nginx --image=nginx
```

### Delarative
In this we use yaml/json files. We write our instructions like our desired states, images, number of containers in .yaml .json file

