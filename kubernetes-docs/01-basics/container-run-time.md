## What is container run time

The fundamental software responsible for executing and managing the lifecycle of containers on a host operating system. It takes a container image and translates it into a running process, managing resources and ensuring isolation using features like namespaces and cgroups. 

It is responsible for pulling image, start, stop, delete, and monitor the containers

Container run time is the software that is responsible for containers. 

## High Level Flow

* Client requests from containerd to create a container
* Containerd lays out the container's filesystem, and creates the necessary config information
* Containerd invokes the runtime over an API to create/start/stop the container

## Container run time break down

There are three stages of container run time
* High Level
* Shim
* Low Level


### High Level runtime (The Manager 👨‍💼)
When we type docker run nginx or kubernetes says Start a Pod
High-level runtime:
* Understands the request
* Downloads the image from Docker Hub / registry
* Unpacks image layers
* Creates container metadata
* Prepares everything ( metadata )
    * Mounts
    * Network config
    * Resource limits
    * Environment variables
* containerd prepares OCI bundle which contains
   * config.json
   * rootfs
* Generate OCI spec (config.json)


### containerd-Shim

* Shim invokes runc to create/start/stop the container
* Once container starts
   * Docker/containerd should not stay attached
   * If Docker crashes → containers should keep running
* Watches:
    * Is container still running?
    * Did it exit?
    * What was exit code?
* Reports back when needed

shim is long-lived supervisor

### Low Level runtime (The Worker 👷)

Example: runc

#### What it does:
* Receives instructions from containerd-shim
* Talks directly to Linux kernel
* Actually starts the container as a process
* Create namespaces (isolation): 
    * PID
    * Network
    * Mount
    * Filesystem
* Uses:
    * cgroups → limit CPU, RAM, disk
    * namespaces
* Start the process

runc is short-lived executor

At this point container is alive



## Difference between dockershim and containerd-shim
### Containerd-shim
It is a small helper process created per container.
#### Containerd-shim jobs
* Hold the container’s:
    * STDIN / STDOUT / STDERR
* Collect exit status
* Report container state back to containerd
#### Containerd-shim flow
* containerd starts containerd-shim
* shim calls runc start
* runc exits
* shim stays alive with the container

📌 runc is short-lived

📌 shim is long-lived

### Dockershim
It was used in kubernetes so that kubernetes can talk to docker daemon via this dockershim.

#### Flow Before Kubernetes 1.24
Kubelete call to dockershim
dockershim calls to docker daemon
docker daemon calls to containerd
containerd calls to containerd-shim
containerd-shim calls to runc
runc calls to kernel


## Containerd and Runc are softwares?

Yes both are softwares and can be installed seperately.

### containerd
* A long-running daemon
* do the above mentioned works

### Runc

* A command line tool
* Talks directly to Linux kernel
* Creates namespaces, cgroups

runc is just a userspace program that:
- calls clone()
- sets namespaces
- configures cgroups
- mounts filesystems
- applies security policies

If we start container with run command, container will be started but image pull, networking setup will not be there.

If we just install containerd, we can not start the container. we just can pull the image, can create OCI image spec.

So both things are required to operate properly.



## what happens if container has restart policy.

### Docker world

```
container exits
   ↓
containerd-shim → containerd (exit info)
   ↓
containerd → Docker daemon
   ↓
Docker daemon checks restart policy
   ↓
Docker daemon tells containerd:
   "Start a new container"
   ↓
containerd → runc
```

### Kubernetes world

```
container exits
   ↓
containerd-shim → containerd
   ↓
containerd → kubelet (via CRI)
   ↓
kubelet checks RestartPolicy
   ↓
kubelet asks containerd to start a new container
   ↓
containerd → runc
```

## What will happen if containerd is stoped

If containerd is stopped and we executed the command like docker run nginx.

Docker daemon will receive the request and prepare everything. Container will be created since containerd is stopped, so container process will not be started. But we still can container is created with docker ps -a command.

### Simple Words
Containerd creates a directory. Inside that directory, it places two things:
* rootfs
* config.json (OCI Specifications)

## Container Runtime Interface (CRI)
Kubernetes uses the CRI to interact with container runtime
CRI is a gRPC API defined by Kubernetes.
- containerd
- CRI-O
- dockershim (deprecated)
- others implementing CRI

## How kubelet / docker daemon communicate with Container Runtime ?
kubelet communicates with the container runtime using the Container Runtime Interface (CRI).

Docker communicates with Runtime with docker's Rest APIs 


## How Container runtime communicates with RUNc
The container runtime launches runc via a shim process to manage the container lifecycle.

## How RUNc communicate with Kernel
runc configures Linux kernel features (namespaces, cgroups, capabilities, seccomp) using system calls.