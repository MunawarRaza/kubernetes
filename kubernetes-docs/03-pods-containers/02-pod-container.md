## What is Container

## Container states

## Types of containers in pod
1. Init container
2. Sidecar container
3. Ephemeral container
4. App container


### Init Container
Init Container is specialized container that run before app container started in a Pod. Init container can contain utilities or setup scripts not present in an app image

Init containers are exactly like regular containers, except:
- Init containers always run to completion.
- Each init container must complete successfully before the next one starts.

### Used for:
- DB migrations
- config setup
- dependency checks

If a Pod's init container fails, the kubelet repeatedly restarts that init container until it succeeds. However, if the Pod has a restartPolicy of Never, and an init container fails during startup of that Pod, Kubernetes treats the overall Pod as failed.

### Difference Between init and regular container
Like regular container, init container supports all the  fields and features of app containers, including resource limits, volumes, and security settings except `lifecycle`, `livenessProbe`, `readinessProbe`, or `startupProbe` fields.

If there are multiple init containers, kubelet runs each init container sequentially. Each init container must succeed before the next can run.


### Sidecar Container
Sidecar containers are the secondary containers that run along with the main application container within the same Pod. These containers are used to enhance or to extend the functionality of the primary app container by providing additional services, or functionality such as logging, monitoring, security, or data synchronization, without directly altering the primary application code.

Sidecar containers remain running after Pod startup. These can be started, stopped, or restarted without affecting the main application container and other init containers.

Sidecar containers share the same network and storage namespaces with the primary container. This co-location allows them to interact closely and share resources.

Sidecar containers support probe fields

### Used for
- logging agent
- proxy
- monitoring

### Ephemeral Container
A special type of container that runs temporarily in an existing Pod to accomplish user-initiated actions such as troubleshooting.

You cannot add a container to a Pod once it has been created.
Sometimes it's necessary to inspect the state of an existing Pod, however, for example to troubleshoot a hard-to-reproduce bug. In these cases you can run an ephemeral container in an existing Pod to inspect its state and run arbitrary commands

- Ephemeral containers may not have ports, so fields such as ports, livenessProbe, readinessProbe are disallowed.
- Pod resource allocations are immutable, so setting resources is disallowed.

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

