## What is Ingress
Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

Here is a simple example where an Ingress sends all its traffic to one Service:

![alt text](https://github.com/MunawarRaza/kubernetes/blob/master/assests/ingress1.jpg)

## Ingress Benifits
- Expose service URL
- load balance traffic
- terminate SSL / TLS
- offer name-based virtual hosting

## Components of Ingress

1. Ingress Resources
2. Ingress Controller
3. Loadbalancer

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

#### ingressClassName
If there are other ingress controller like nginx, kong, traefik etc, then which ingress resource will be used for which ingress controler, to specify that we use ingressClassName.

If the ingressClassName is omitted, a default Ingress class should be defined

Ingress rules

- host (for example, foo.bar.com)
- A list of paths (for example, /testpath)
- A backend is a combination of Service and port names

#### defaultBackend
A defaultBackend is often configured in an Ingress controller to service any requests that do not match a path in the spec.

#### Resource backends
A Resource backend is an ObjectRef to another Kubernetes resource within the same namespace as the Ingress object.

#### Path types
Each path in an Ingress is required to have a corresponding path type. Paths that do not include an explicit pathType will fail validation. There are three supported path types:

- ImplementationSpecific

- Exact: 
  - Matches the URL path exactly and with case sensitivity.
- Prefix
  - Matches based on a URL path prefix split by /. Matching is case sensitive and done on a path element by element basis.

  #### Multiple matches
  In some cases, multiple paths within an Ingress will match a request. In those cases precedence will be given first to the longest matching path. If two paths are still equally matched, precedence will be given to paths with an exact path type over prefix path type.



### What is Ingress Controller
Ingress controller read the ingress resources. These Ingress controller are written by loadbalancer companies like nginx, traefik.

Flow: We write ingress resource file, Ingress controller read that file and create the loadbalancer on the basis of configurations we have written in ingress resource file.

An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

Exposing services other than HTTP and HTTPS to the internet typically uses a service of type Service.Type=NodePort or Service.Type=LoadBalancer.


