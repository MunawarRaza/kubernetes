
## Imperative
In this we run/update/delete pod with command. like
```
kubectl run nginx --image=nginx
```

## Imperative Object configurations

## Delarative Object configurations
In this we use yaml/json files. We write our instructions like our desired states, images, number of containers in .yaml .json file

## Questions
- How to create pod
- How to list pod
- How to see the logs of pod
- How to execute command into a container inside the pod
- How to display the output of pod
- How to attach/deattach the labels of pod


### create pod using command
    kubectl run nginx --image=nginx
### list the created pods
    kubectl get pods -o wide
### describe the created pod
    kubectl describe pod pod_name
### execute command in container of a pod
    kubectl exec nginx -- ls
### Access shell of pod having single container
    kubectl exec pod_name -it -- /bin/bash
### go into the container, running in the pod, specify the container name
    kubectl exec pod_name -c container_name -it -- /bin/bash
### list the pods and all its Labels
    kubectl get pods --show-labels
### update the label of pod
    kubectl label pods -l app=nginx tier=fe
### first filters all pods with the label "app=nginx", and then labels them with the "tier=fe". To see the pods you labeled, run:
    kubectl get pods -l app=nginx -L/--label-columns tier
