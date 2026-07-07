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


Types of Services:
NodePort
ClusterIP
    Service creates the virtual IP inside the cluster
LoadBalancer

#### NodePort
Service recives the traffic on its service port and forward it to pod's port which is called targetport

Exposes the Service on each Node's IP at a static port (the NodePort). To make the node port available, Kubernetes sets up a cluster IP address

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

#### ClusterIP (Default)
Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default that is used if you don't explicitly specify a type for a Service.

#### LoadBalancer
Exposes the Service externally using an external load balancer. 

#### ExternalName
