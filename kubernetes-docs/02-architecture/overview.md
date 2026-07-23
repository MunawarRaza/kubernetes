# Kubernetes Architecture

## Node

A node is a machine – physical or virtual – on which kubernetesis installed.

## Cluster
A cluster is a set of nodes grouped together.

## Types of Nodes in K8s Cluster
There are tow types of nodes
1. Master Node / Control Plan
2. Worker Node

## Master Node or Control Plane
The master is a node with Kubernetes installed in it, and is configured as a Master. The master watches over the nodes in the cluster and is responsible for the actual orchestration of containers on the worker nodes. Master node is called Control Plane

## Worker Node
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

It:
1. Authenticate User
2. Validate Request
3. Retrive Data
4. Update ETCD

<b>Installing Methods of kube-api-server</b>

There are 2 methods to deploy the kubeapi-server 
1. Manully with Binary
2. Kubeadm

<b>Manual Deployment</b>

If we deploy with binary
- Download the binary from the kubernetes page
- Extract it
- Configure /etc/systemd/system/kube-apiserver.service
- Start with systemd service

<b>View api-server-options - if inatalled manually</b>
```
cat /etc/systemd/system/kube-apiserver.service
```

<b>View api-server-options - if inatalled with kubeadm</b>
```
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```


#### ETCD

ETCD is a distributed reliable key-value store used by kubernetesto to store all data used to manage the cluster.


<b>Installing Methods of ETCD</b>

There are 2 methods to deploy the ETCD
1. Manully with Binary
2. Kubeadm

<b>Manual Deployment</b>

If we deploy with binary
- Download the binary from the kubernetes page
- Extract it
- Configure /etc/systemd/system/etcd.service
- Start with systemd service

<b>View ETCD - if inatalled manually</b>
```
cat /etc/systemd/system/etcd.service
```

<b>View etcd-options - if inatalled with kubeadm</b>
```
cat /etc/kubernetes/manifests/etcd.yaml
```

To list the all keys 
```
kubect exec pod etcd-master -n kube-system etcdctl get / --prefix --keys-only
```

Kubernetes stores the data in specific directory
```
/registry
    - minions
    - pods
    - replicasets
    - deployments
    - roles
    - secrets
```

<b> Etcd in HA </b>

if we have etcd in multiple instances then we have to configure the etcd.service in such a way that everyone knows each other. below parameter is used
etcd.service
```
--initial-cluster controller-0=https://{controller0_IP}:2280,controller-1=https://{controller1_ip}:2280 \\
```

#### Schedulers
The scheduler is responsible only to decide which pod will be going to which node. It does not create the pod. Kublet creates the pod.

Scheduler try to find the best node for the pod based on the different obeservations
Scheduler go through the 2 phases

1. Filter Nodes
  - It tries to filter the nodes which do not fit for the newly upcoming pod and remove them from the list
2. Ranks Nodes
  - It uses the priority functions to assign score from 0-10. The scheduler calculates the ammount of resources that would be free after the placing the pod on them.

Note:

Factors taken into account for scheduling decisions include: individual and collective resource (cpu, memory, hard disk etc) requirements, hardware/software/policy constraints, affinity and anti-affinity specifications, data locality, inter-workload interference, and deadlines

<b>Installing Methods of kube-scheduler</b>

There are 2 methods to deploy the kube-scheduler
1. Manully with Binary
2. Kubeadm

<b>Manual Deployment</b>

If we deploy with binary
- Download the binary from the kubernetes page
- Extract it
- Configure /etc/systemd/system/kube-scheduler.service
- Start with systemd service

<b>View kube-scheduler options - if inatalled manually</b>
```
cat /etc/systemd/system/kube-scheduler.service
```

<b>View kube-scheduler-options - if inatalled with kubeadm</b>
```
cat /etc/kubernetes/manifests/kube-scheduler.yaml
```


#### kube-controller-manager

It runs multiple controller processes (like node, pod, and service controllers) in one binary to continuously monitor the cluster's actual state and ensure it matches the desired state defined by the user. 

It just like a department where multiple teams are sitting and each team has specific responsibilites who monitor and manage their rutine tasks and take iimediate action to fix if they found any discrepance 


There are many different types of controllers. Some examples of them are:

* Node controller: 
  - It assignes a CIDR block to the node when it is registered
  - Keep the Node's list up to date
  - Monitoring the Node's health
  - If Node becomes unreachable, node controller sets the Ready condition to Unknown
  - If Node is unreachable, API-initiated evication is triggered to get the resources from all Pods
  - Responsible for noticing the state of the node.
  - If any new node is on boarding / any going down etc
  - Node Monitor Period = 5s 
    - monitor each node after 5s
  - Node Monitor Grace Period = 40s 
    - wait for 40s before mark it unreachable
  - POD eviction timeout = 5m 
    - if a node is unreachable, it got 5m to come backup, if does't comeback, node controller removes the pod from it and assigns them to healthy node

* Replication Controller:
    - monitors the replication and ensures the desired number of pod are running at all times.
* Deployment Controller:
* Namespace Controller
* Endpoint Controller
* Cronjob Controller
* Service Account Controller
* PV-Binding Controller

<b>Installing Methods of kube-controller-manager</b>

There are 2 methods to deploy the controller-manager
1. Manully with Binary
2. Kubeadm

<b>Manual Deployment</b>

If we deploy with binary
- Download the binary from the kubernetes page
- Extract it
- Configure /etc/systemd/system/kube-controller-manager.service
- Start with systemd service

<b>View kube-controller-manager options - if inatalled manually</b>
```
cat /etc/systemd/system/kube-controller-manager.service
```

<b>View kube-controller-manager-options - if inatalled with kubeadm</b>
```
cat /etc/kubernetes/manifests/kube-controller-manager.yaml
```

#### cloud-controller-manager


### Worker Node Componenets

Node components run on every node, maintaining running pods and providing the Kubernetes runtime environment

Worker Node Components:
* kubelet
* kube proxy
* Container runtime

#### kubelet
An agent that runs on each node in the cluster. It makes sure that containers are running in a Pod.

It listens the instructions from kube api server and create / destroy the containers based on the instructions. It also send back the report to kube api server if anything happens to containers on its node.

Kubelet's tasks:
- Register the node with API Server using one of: the hostname, a flag to override the hostname, specific logic for cloud provider
- The kubelet takes a set of PodSpecs that are provided through various mechanisms (primarily through the apiserver) and ensures that the containers described in those PodSpecs are running and healthy.

There are three ways that a container manifest can be provided to the Kubelet
1. PodSpecs provided by API Server
2. File: Path is passed as a flag in command line
3. Http Endpoint: HTTP endpoint passed as a parameter on the command line


<b>Installing Methods of kubelet</b>

This component is not installed with kubeadm, it only install manually

<b>Manual Deployment</b>

If we deploy with binary
- Download the binary from the kubernetes page
- Extract it
- Configure /etc/systemd/system/kubelet.service
- Start with systemd service

<b>View kubelet options</b>
```
cat /usr/lib/systemd/system/kubelet.service
ps -aux |grep kubelet
```

#### kube-proxy

In kubernetes every pod can reach to everyother pod. This can only happen with pod networking solution in the cluster

kube-proxy is a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept.

Consider kube-proxy as the traffic manager. Let's explain here.
First we have to understand the service in kubernetes. 

<b>Service: </b> A Kubernetes Service is a stable network endpoint that provides access to a group of pods. It finds those pods using label selectors and automatically load-balances traffic among them. This is virtual component that is listed in kubernetes memory. It is nothing like pod. Service registers the pods whose lables are matching with service configurations.

Kube-proxy keeps the IPs of service and pods behind that service.

Suppose we have frontend pod and multiple pods of backend. Frontend has to communicate with backend but pod is ephemeral and can be destroyed at anytime. If a pod destroyed and recreated, then its IP will be changed and this time frontend will not be able to communicate with backend pod. To solve this problem service comes into the picture, Service is the virtual component who has a stable IP and Name. Service can be accessible via its IP or Name. All the backends pod will be behind this service. Now frontend does not need to communicate directly to the pod. Frontend sends the request to service and kube-proxy intercept that request, DNAT(Destination Network Address Translation) means change the destination IP from service to pod and decides on which pod this request should go.

Imagine calling a company's customer support number.
```
You
 |
 | Call 1111
 |
Customer Support Number
 |
Operator
 |
-----------------------
|         |           |
Agent1   Agent2     Agent3
```

- The customer support number is the Service (ClusterIP).
- The operator is kube-proxy.
- The agents are the Pods.

You always dial the same number. The operator decides which agent answers your call. If one agent is unavailable, another answers, and you don't need to know who it is.

<b>How does kube-proxy know the new IP of service/pod? </b>

<b>Step 1: A new Pod is created</b>

```
Pod created
      |
      v
Scheduler assigns it to a node
      |
      v
kubelet starts the Pod
      |
      v
CNI assigns Pod IP

For Example:
Pod-4
IP = 10.244.1.8
Labels:
app=frontend
```
<b>Step 2: API Server stores the Pod</b>

The kubelet updates the Pod status (including its IP) through the API Server. The API Server stores the Pod object in etcd.

<b>Step 3: EndpointSlice Controller notices the new Pod</b>

The EndpointSlice Controller (running inside `kube-controller-manager`) watches:

- Pods
- Services

It sees:
- A new Pod exists.
- The Pod `label app=frontend` matches the Service selector.

So it updates the EndpointSlice.

```
EndpointSlice

Old
----
10.244.0.2
10.244.0.3

↓

New
----
10.244.0.2
10.244.0.3
10.244.1.8
```
This updated EndpointSlice is written back to the `API Server`, which stores it in `etcd`.

<b>Step 4: kube-proxy is watching the API Server</b>

kube-proxy has a watch open to the API Server. It immediately receives the updated EndpointSlice.
```
API Server
      |
      | Watch Event
      |
kube-proxy
```

<b>Step 5: kube-proxy updates networking rules</b>

kube-proxy updates `iptables/IPVS/nftables` to include the new Pod IP.

Now traffic can be sent to:
```
10.244.0.2
10.244.0.3
10.244.1.8
```

<b>Complete Flow</b>

```
Pod Created
      |
      v
CNI assigns Pod IP
      |
      v
kubelet updates Pod Status
      |
      v
API Server
      |
      v
etcd

      ↑
EndpointSlice Controller watches Pods & Services
      |
Updates EndpointSlice
      |
      v
API Server
      |
      v
etcd

      ↑
kube-proxy watches EndpointSlices
      |
Updates iptables/IPVS rules
      |
Traffic starts reaching new Pod
```

When a new Pod is created and receives an IP address from the CNI, the kubelet reports the Pod status (including the IP) to the API Server. The EndpointSlice Controller watches Pods and Services, updates the corresponding EndpointSlice resource with the new Pod IP, and stores it via the API Server in etcd. kube-proxy watches the API Server for EndpointSlice changes and updates the node's networking rules accordingly.


<b> Install the kube-proxy Manually </b>
1. Download the Binary from the k8s page
2. Extract it
3. Configure and run as a service kube-proxy.service

kubeadm deploy this in each node as a daemonset


#### Container Runtime
A fundamental component that empowers Kubernetes to run containers effectively. It is responsible for managing the execution and lifecycle of containers within the Kubernetes environment.

---

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

<b>1- Addresses</b>

  - Hostname
  - External ip address: 
    - Typically the IP address of the node that is externally routable (available from outside the cluster).
  - Internal IP Address
    - Typically the IP address of the node that is routable only within the cluster.

<b>2- Conditions</b>

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

<b>3- Capacity and Allocatable</b>

Describes the resources available on the node: CPU, memory, and the maximum number of pods that can be scheduled onto the node.

<b>4- Info</b>

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

---

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