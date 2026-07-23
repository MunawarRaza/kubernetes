## What is service
This is an object like pod
In Kubernetes, a Service is a method for exposing a network application that is running as one or more Pods in your cluster


## Defining a Service
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

🔴 Note

A Service can map any incoming port to a targetPort. By default and for convenience, the targetPort is set to the same value as the port field.

### Port definitions 
Port definitions in Pods have names, and you can reference these names in the targetPort attribute of a Service. For example, we can bind the targetPort of the Service to the Pod port in the following way:
```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app.kubernetes.io/name: proxy
  ports:
  - name: name-of-service-port
    protocol: TCP
    port: 80
    targetPort: http-web-svc

---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app.kubernetes.io/name: proxy
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
      - name: http-web-svc
        containerPort: 80
        
```


<b>Types of Services:</b>
- ClusterIP
- NodePort
- LoadBalancer

<b> ClusterIP (Default)</b>

The default service type is `ClusterIP`. This allows a service to be accessed within the cluster via a virtual IP address,
known as the service Cluster IP. The Cluster IP for a service is discoverable through Kubernetes DNS.

Here kube-proxy:
- intercept the request 
- DNAT 
- chose the pod to forward the traffic

<b> NodePort</b>

The most basic way to access a service from outside the cluster is to use a service of type `NodePort`. A Node Port is a port reserved on each node in the cluster through which the service can be accessed. 

Here kube-proxy:
- intercept the request 
- DNAT
  - in DNAT, Node's IP is mapped with Service POD's IP
- SNAT (Source NAT)
  - in SNAT, source/Client IP is mapped with Node IP and when pod receives the traffic, it sees source IP as the Node Port. This ensures the reply comes back through the same node.
- chose the pod to forward the traffic


Complete Flow:
```
                 Client
          203.0.113.20
                |
                |
                v
      Node-1 (192.168.1.101)
          NodePort 30080
                |
         kube-proxy intercepts
                |
       Chooses one backend Pod
                |
      DNAT: 192.168.1.101:30080
                ↓
        10.244.0.3:8080
                |
             Pod-2
                |
           Response
                |
      Reverse NAT on Node-1
                |
             Client
```

Definition:

```
ports:
  targetPort: 80
  port: 80
  nodePort: 30008
```

1. TargetPort

    Port of the Pod where the traffic will be routed

2. Service Port
    Port of service 

3. NodePort

    Port on the node which we use to access the webserver externally

    Range: 30000-32767
```
apiVersion: v1
kind: Service
metadata:
    name: my-service
spec:
  type: NodePort
  ports:
    - targetPort: 80
      port: 80
      nodePort: 30008
```

Note:
If pods are distributed on different Nodes, service is created for all the Nodes and we can access the application with IP of any Node and port we configured in our manifist file

<b>LoadBalancer</b>

Services of type LoadBalancer expose the service via an external network load balancer (NLB). The service can be accessed from outside of the cluster via a specific IP address on the network load balancer, which
by default will load balance evenly across the nodes using the service node port. 

<b>Advertising service IPs</b>
One alternative to using node ports or network load balancers is to advertise service IP addresses over BGP.

In this our office router knows our kubernetes cluster. In this we tells our office router that if anyone wants to access the our kubernetes cluster, just send the traffic to our k8s cluster ip.

BGP allows Kubernetes to advertise Service IPs (ClusterIPs or ExternalIPs) directly to the network routers. Instead of accessing applications through a NodePort or cloud LoadBalancer, routers learn the route to the Service IP and send traffic directly to the Kubernetes cluster. Calico provides this capability when used as the CNI, while MetalLB offers similar functionality for clusters using other CNIs such as Flannel or Cilium.

Complete Flow:
```
             Client
                |
                |
         Top-of-Rack Router
                |
     Learns via BGP that
     10.96.0.20 belongs
     to Kubernetes
                |
         Kubernetes Cluster
                |
           kube-proxy
                |
            Service
                |
              Pods
```
