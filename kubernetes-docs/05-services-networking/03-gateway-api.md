## What is Gateway API
Gateway API is the alternate and advance of ingress controller.
It support
- Rate limitin
- WAP
- http
- cannery deployment
- DDOS

It is used to solve the problems of ingress controller

## How Gateway API Designed
Gateway API designed on basis on following principles
- Role-Oriented
  - Infrastructure Provider
  - Cluster Operator
  Application Developer
- Portable
- Expressive:  Gateway API kinds support functionality for common traffic routing use cases
  - header-based matching
  - traffic weighting
- Extensible: Gateway allows for custom resources to be linked at various layers of the API

## Resource model
1. Gateway Class
2. Gateway Resource
3. Http route resource
4. GRPCRoute

### Gateway Class
Defines a set of gateways with common configuration and managed by a controller that implements the class.

This defines as globaly not in namespace. Because one controller can manage multiple gateways. So we can define specific department should use specific gateway and so on.

Simple words, It defines Which controller implements the gateway. For example, This gateway controller will use to create this gateway. It something like a bridge between gateway controller and gateway

e.g “Use this vendor/controller to create gateways”

This is logical template for Gateway configurations and Features.
It holds provider specific parameters and default policies
This is referenced in Gateway

### Gateway Resource
Defines an instance of traffic handling infrastructure, such as cloud load balancer.
This is managed by cluster operator who is concerned with policies, network access, application permissions, etc.

- This is provisions the loadbalancer defined by its GatewayClass
- Configures listeners (port, protocl, hostname)

This is the actual loadbalancer / entry point

### Http Route Resource

This defines to which backend service or path, traffic will be routed
Defines HTTP-specific rules for mapping traffic from a Gateway listener to a representation of backend network endpoints. These endpoints are often represented as a Service.

Application developers are responsible for this section

- Defines routing rules for gateways
- support http, tcp, udp, grpc
- Forward traffic to backend service



### GRPCRoute
Defines gRPC-specific rules for mapping traffic from a Gateway listener to a representation of backend network endpoints. These endpoints are often represented as a Service.


Gateway Object
  GatewayClass
    the GatewayClass describes the gateway controller responsible for managing Gateways of this class. 
  HttpRoute

```
User request
   ↓
Gateway (entry point)
   ↓
HTTPRoute (routing rules)
   ↓
Service
   ↓
Pods
```

🔷 Real-world analogy

- GatewayClass = airport company (who operates it)
- Gateway = airport building (entry point)
- HTTPRoute = flight routing desk (who goes where)
- Service = final destination gate

![alt text](https://github.com/MunawarRaza/kubernetes/blob/master/assests/gateway-modularity.png)

## Setup of Gateway

### Step-1 Setup kubernetes cluster

### Step-2 Install Gateway API CRDs.
At this time CRDs are not part of native kubernetes installations

First, install the official Gateway API CRDs from the Kubernetes SIG Network project

This installs:
  - GatewayClass
  - Gateway
  - HTTPRoute
  - TCPRoute
  - ReferenceGrant
  - etc.

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

check 
kubectl get crds

### Step-3 Install Gateway Controller (Implementation)
Now install a controller that implements Gateway API.
Install any gateway conrtoller from the below list with helm

Examples:
  - NGINX Gateway Fabric
  - Traefik Labs Traefik Gateway
  - Project Contour
  - HAProxy Technologies

Create values.yaml file and put following content in it
```
service: 
  type: NodePort
```
Install using Helm:
helm install <release> <chart>
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --namespace nginx-gateway --create-namespace -f values.yaml --wait
or 
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --namespace nginx-gateway --create-namespace --version 2.4.0 --wait --set nginx.service.type=NodePort

check
kubectl get all -n nginx-gateway

### Step-4 Create GatewayClass

```
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
```

### Create Gateway
```
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: nginx-gateway
spec:
  gatewayClassName: nginx
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
```
Note: This should be in same namespace where gateway class exists

### Create HTTPRoute (or other Routes)
Note: This should be in same namespace where app exists

```
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello-app-route
  namespace: default # Namespace of your application
spec:
  parentRefs:
    - name: main-gateway
      namespace: nginx-gateway
  hostnames:
    - "demo.example.com" # Replace with your demo domain
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: my-service # Your application's service name
          port: 80 # Your application's service port
```









Install Gateway API CRDs (Cluster-wide – once)controller like nginx gateway febric, traefik
Install gateway controller with helm
install gateway class
install gateway
install route like httprout




Typical Resource Creation Order
For production-grade deployment:
Install Kubernetes cluster (masters + workers)
Install Gateway API CRDs (standard-install.yaml)
Install Gateway controller via Helm (NGINX GF)
Helm automatically creates Gateway controller Pods + Service
Create GatewayClass
Create Gateway
Uses the Helm-created Service internally
Deploy your microservices Pods (via Deployment / StatefulSet)
Create Service for each microservice (ClusterIP)
Create HTTPRoute / Ingress pointing to those Services
The Gateway service is created by Helm for the controller
The microservice services are created by you for each app