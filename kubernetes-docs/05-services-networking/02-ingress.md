## What is Ingress
Kubernetes Ingress builds on top of Kubernetes Services to provide load balancing at 7th Layer (application layer), mapping HTTP and HTTPS requests with particular domains or URLs to Kubernetes services. Ingress can also be used to terminate SSL / TLS before load balancing to the service

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

Here is a simple example where an Ingress sends all its traffic to one Service:

![alt text](https://github.com/MunawarRaza/kubernetes/blob/master/assets/ingress1.jpg)

<b>Ingress Benifits</b>
- Expose service URL
- load balance traffic
- terminate SSL / TLS
- offer name-based virtual hosting

<b>Flow</b>

```
                Internet
                    |
                    |
            203.0.113.10
                    |
          Ingress Controller
          (NGINX, Traefik, etc.)
          /          |          \
         /           |           \
        /            |            \
frontend-service  api-service  admin-service
```

Ingress route the traffic on the basis of
1. domain
    - Suppose we visit www.example.com, it routes our traffic to `frontend-service`
2. path
    - Suppose users visit `www.example.com/` Ingress sends traffic to `frontend-service`. If users visit `www.example.com/api` Ingress sends traffic to `api-service`

## Components of Ingress

1. Ingress Resources
2. Ingress Controller
3. IngressClassName
4. Loadbalancer

### Ingress Resources
This is the definition file which is written in yaml format to update/create the ingress loadbalancer.

Ingress Object

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
spec:
  ingressClassName: nginx-example
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-resource-backend
spec:
  defaultBackend:
    resource:
      apiGroup: k8s.example.com
      kind: StorageBucket
      name: static-assets
  rules:
    - http:
        paths:
          - path: /icons
            pathType: ImplementationSpecific
            backend:
              resource:
                apiGroup: k8s.example.com
                kind: StorageBucket
                name: icon-assets
```

The Ingress spec has all the information needed to configure a load balancer or proxy server. Most importantly, it contains a list of rules matched against all incoming requests. Ingress resource only supports rules for directing HTTP(S) traffic.

### ingressClassName
If there are other ingress controller like nginx, kong, traefik etc, then which ingress resource will be used for which ingress controler, to specify that we use ingressClassName.

We can say that incressClassName is used to link the ingress resource to incressController

If the ingressClassName is omitted, a default Ingress class should be defined

Ingress rules

- host (for example, foo.bar.com)
- A list of paths (for example, /testpath)
- A backend is a combination of Service and port names

<b> defaultBackend</b>

A defaultBackend is often configured in an Ingress controller to service any requests that do not match a path in the spec.

<b> Resource backends</b>

A Resource backend is an ObjectRef to another Kubernetes resource within the same namespace as the Ingress object.

<b> Path types </b>

Each path in an Ingress is required to have a corresponding path type. Paths that do not include an explicit pathType will fail validation. There are three supported path types:

- ImplementationSpecific

- Exact: 
  - Matches the URL path exactly and with case sensitivity.
- Prefix
  - Matches based on a URL path prefix split by /. Matching is case sensitive and done on a path element by element basis.

<b>Multiple matches</b>

  In some cases, multiple paths within an Ingress will match a request. In those cases precedence will be given first to the longest matching path. If two paths are still equally matched, precedence will be given to paths with an exact path type over prefix path type.



### What is Ingress Controller
Ingress controller read the ingress resources. These Ingress controller are written by loadbalancer companies like nginx, traefik.

Flow: We write ingress resource file, Ingress controller read that file and create the loadbalancer on the basis of configurations we have written in ingress resource file.

An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

Exposing services other than HTTP and HTTPS to the internet typically uses a service of type Service.Type=NodePort or Service.Type=LoadBalancer.

<b>Types of ingressController</b>

- NGINX Ingress Controller
- Traefik
- HAProxy
- Kong

## Types of Ingress solutions

1. In-cluster ingress - where ingress load balancing is performed by pods within the cluster itself.
2. External ingress - where ingress load balancing is implemented outside of the cluster by appliances or cloud provider capabilities.

<b>In-cluster ingress solutions</b>
In-cluster ingress solutions use software load balancers running in pods within the cluster itself. There are many
different ingress controllers to consider that follow this pattern, including for example the NGINX ingress controller.

```
                 Internet
                     |
                     |
           External LoadBalancer
             (or NodePort/BGP)
                     |
                     |
      +--------------------------------+
      |        Kubernetes Cluster       |
      |                                |
      |  Ingress Controller Pods       |
      |  (NGINX, Traefik, HAProxy)      |
      |             |                  |
      |      ------------------        |
      |      |        |       |        |
      |   frontend   api   admin       |
      |      |        |       |        |
      |     Pods     Pods    Pods      |
      +--------------------------------+
```

## What is Kubernetes Egress?