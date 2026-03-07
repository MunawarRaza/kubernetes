# Kubernetes Architecture

## Node

A node is a machine – physical or virtual – on which kubernetesis installed.

## Cluster
A cluster is a set of nodes grouped together.

## Types of Nodes in Cluster
There are tow types of nodes
1. Master Node / Control Plan
2. Worker Node

### Master Node or Control Plane
The master is a node with Kubernetes installed in it, and is configured as a Master. The master watches over the nodes in the cluster and is responsible for the actual orchestration of containers on the worker nodes. Master node is called Control Plane

### Worker Node
A node where kubernetes components are installed and being managed by Master Node. On this Node, Master Node launches the Pods/Containers.

## Componenets of Kubernetes
When you install Kubernetes on a System, you are actually installing the following components. Some of them installed on Master and some on Worker Nodes.

### Master Node Componenets
The control plane's components make global decisions about the cluster (for example, scheduling)

Note: Master or Control Plane Components can be installed on any machine of the cluster. However, for simplicity, setup scripts typically start all control plane components on the same machine, and do not run user containers on this machine

* A Kube API Server. 
* An ETCD service.
* Schedulers
* Kube Controllers Manager
* Cloud Controller Manager

#### Kuber API Server
The API server acts as the front-end for kubernetes that exposes the Kubernetes API. The users, management devices, Command line interfaces all talk to the API server to interact with the kubernetes cluster. The kube-apiserver is designed to scale horizontally, that is, it scales by deploying more instances
1. Authenticate User
2. Validate Request
3. Retrive Data
4. Update ETCD


#### ETCD

ETCD is a distributed reliable key-value store used by kubernetesto to store all data used to manage the cluster

#### Schedulers

The scheduler is responsible for distributing work or pods across multiple nodes. It looks for newly created pod and assigns them to Nodes. The controllers makes decisions to bring up new pods in such cases.
It only decides which pods going where. It did not create pod

Note:

Factors taken into account for scheduling decisions include: individual and collective resource (cpu, memory, hard disk etc) requirements, hardware/software/policy constraints, affinity and anti-affinity specifications, data locality, inter-workload interference, and deadlines

#### kube-controller-manager

It runs multiple controller processes (like node, pod, and service controllers) in one binary to continuously monitor the cluster's actual state and ensure it matches the desired state defined by the user. 

e.g

It constantly checks if the current state (e.g. 2 pods are running) matches the desired state (e.g., 3 pods requested).  If a container crashes, a node dies, or a service is deleted, the controller manager detects this discrepancy and takes immediate action to fix it.

There are many different types of controllers. Some examples of them are:

* Node controller: 
  - Responsible for noticing and responding when nodes go down.
  - Node Monitor Period = 5s
  - Node Monitor Grace Period = 40s
  - POD eviction timeout = 5m

* Replication Controller:
    - Ensures the desired number of pod replicas are running at all times.
* Deployment Controller:
* Namespace Controller
* Endpoint Controller


#### cloud-controller-manager


### Worker Node Componenets

Node components run on every node, maintaining running pods and providing the Kubernetes runtime environment

Worker Node Components:
* kubelet
* kube proxy
* Container runtime

#### kubelet
An agent that runs on each node in the cluster. It makes sure that containers are running in a Pod.

Kubelet's tasks:
- Register the node with API Server using one of: the hostname, a flag to override the hostname, specific logic for cloud provider
- The kubelet takes a set of PodSpecs that are provided through various mechanisms (primarily through the apiserver) and ensures that the containers described in those PodSpecs are running and healthy.

There are three ways that a container manifest can be provided to the Kubelet
1. PodSpecs provided by API Server
2. File: Path is passed as a flag in command line
3. Http Endpoint: HTTP endpoint passed as a parameter on the command line

#### kube-proxy (optional) 

kube-proxy is a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept.

Service: Service can't join the pod network. This is virtual component that is listed in kubernetes memory. It is nothing like pod.

Kube proxy looks for new services. When new service is created, kube proxy creates the appropriate rules on each node to forward traffic to those services to backend pods. It does with iptables rules. It creates the IPtables where rule is defined like forward traffic to service IP and from there to pod ip

#### Container Runtime
A fundamental component that empowers Kubernetes to run containers effectively. It is responsible for managing the execution and lifecycle of containers within the Kubernetes environment.

## How worker Node is registered with kubernetes

There are two main ways to have Nodes added to the API server:

1. The kubelet on a node self-registers to the control plane
2. You (or another human user) manually add a Node object via JSON file.

When we try to register the worker node with API Server, Kubernetes checks  that a kubelet has registered to the API server that matches the `metadata.name` field of the Node. If the node is healthy (i.e. all necessary services are running), then it is eligible to run a Pod. Otherwise, that node is ignored for any cluster activity until it becomes healthy.

## Node Status
A Node's status contains the following information:

- Addresses
- Conditions
- Capacity and Allocatable
- Info

### Addresses
  - Hostname
  - External ip address: 

      Typically the IP address of the node that is externally routable (available from outside the cluster).
  - Internal IP Address:

    Typically the IP address of the node that is routable only within the cluster.
### Conditions
The conditions field describes the status of all Running nodes
- Ready --> True / False / Unknown (if the node controller has not heard from the node in the last node-monitor-grace-period (default is 50 seconds))
- DiskPressure --> True / False
- MemoryPressure --> True / False
- PIDPressure --> True / False
- NetworkUnavailable --> True / False

You can check condition of registered node with following command:
```
kubectl describe node node_name
```

### Capacity and Allocatable
Describes the resources available on the node: CPU, memory, and the maximum number of pods that can be scheduled onto the node.

### Info
Describes general information about the node, such as 
- OS Image
- Operating System
- Architecture
- kernel version
- Kubernetes version (kubelet and kube-proxy version),
- container runtime details, and which operating system the node uses.

## Heartbeats
Heartbeats, sent by Kubernetes nodes, help your cluster determine the availability of each node, and to take action when failures are detected.

### Forms of Heartbeats
For nodes there are two forms of heartbeats:
- updates to the .status of a Node
- Lease objects within the kube-node-lease namespace. Each Node has an associated Lease object.

## Node Controller
The node controller is a Kubernetes control plane component that manages various aspects of nodes.

### Node Controller Tasks

- It assignes a CIDR block to the node when it is registered
- Keep the Node's list up to date
- Monitoring the Node's health
- If Node becomes unreachable, node controller sets the Ready condition to Unknown
- If Node is unreachable, API-initiated evication is triggered to get the resources from all Pods

## Communication between Nodes and the Control Plane

Node always communicate with apiserver. So communication happens between kubelet and apiserver

### Node to Control Plane communication
When node joins with kubelet command, Public root certificates is transfered to the worker node from master node. When 
The API server is configured to listen for remote connections on a secure HTTPS port

### Control plane to node

There are two primary communication paths from the control plane (the API server) to the nodes.
1. API server to the kubelet process
2. API server to any node, pod, or service through the API server's proxy functionality

#### API server to kubelet
The connections from the API server to the kubelet are used for:
- Fetching logs for pods.
- Attaching (usually through kubectl) to running pods.
- Providing the kubelet's port-forwarding functionality.

These connections terminate at the kubelet's HTTPS endpoint. By default, the API server does not verify the kubelet's serving certificate, which makes the connection subject to man-in-the-middle attacks and unsafe to run over untrusted and/or public networks.

#### API server to nodes, pods, and services
The connections from the API server to a node, pod, or service default to plain HTTP connections and are therefore neither authenticated nor encrypted. They can be run over a secure HTTPS connection by prefixing https: to the node, pod, or service name in the API URL, but they will not validate the certificate provided by the HTTPS endpoint nor provide client credentials.

#### SSH tunnels (depricated)
Kubernetes supports SSH tunnels to protect the control plane to nodes communication paths. In this configuration, the API server initiates an SSH tunnel to each node in the cluster (connecting to the SSH server listening on port 22) and passes all traffic destined for a kubelet, node, pod, or service through the tunnel. 

#### Konnectivity service