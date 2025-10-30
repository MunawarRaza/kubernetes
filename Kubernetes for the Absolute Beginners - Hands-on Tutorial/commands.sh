################# cluster #################
# get nodes in cluster
    kubectl get node -o wide
# get all created resources in default name space
    kubectl get all

################# pods #################
# create pod using command
    kubectl run nginx --image=nginx
# list the created pods
    kubectl get pods -o wide
# describe the created pod
    kubectl describe pod pod_name
# execute command in container of a pod
    kubectl exec nginx -- ls
# Go into the container, running in the pod
    kubectl exec pod_name -it /bin/bash
# Go into the container, running in the pod, specify the container name
    kubectl exec pod_name -c container_name -it /bin/bash
    
################# Labels #################
# List the pods and all its Labels
    kubectl get pods --show-Labels
# update the label of pod
    kubectl label pods -l app=nginx tier=fe
# first filters all pods with the label "app=nginx", and then labels them with the "tier=fe". To see the pods you labeled, run:
    kubectl get pods -l app=nginx -L/--label-columns tier
# delete the labels
    kubectl label pod pod_name label-

################# Field Selectors #################
# get pods for which the status.phase is running
    kubectl get pods --field-selector status.phase=Running
# Get pods whose phase is not running and restartpolicy is alwys
    kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always

################# Namespaces #################
# list the created namespaces 
    kubectl get namespace
# create resource in separete namespace at the time of resource creation
    kubectl run nginx --image=nginx --namespace=<insert-namespace-name-here>
# list the resources in specific namespace
    kubectl get pods --namespace=<insert-namespace-name-here>
# save the namespace for all subsequent kubectl commands
    kubectl config set-context --current --namespace=<insert-namespace-name-here>
# list the config of namespace
    kubectl config view --minify | grep namespace:

################# replica controler #################
# list the created replication controler
    kubectl get replicationcontrollers / rc
# describe created replicationcontrollers
    kubectl describe rc rc_name
# scale the replicas using command
    kubectl scale rc replication_controler_name --replicas=2
# set autoscale when cpu usage is 50 percent
    kubectl autoscale rs rs_name --max=20 --min=3 --cpu-percent=50
# delete only replication controller instead of associated pods
    kubectl delete rc rc_name --cascade=orphan

################# replica-set #################
# list the created replica-set
    kubectl get replica-set
# describe created replica-set
    kubectl describe replicaset replica_set_name
# scale the replicas using command
     kubectl scale replicaset replica_set_name --replicas=2
# Delete only replica-set and keep pods running
    kubectl delete rs replica_set_name --cascade=orphan

################# deployment #################
# create deployment using file
    kubectl create -f first-deployment.yaml
# list the created deployments
    kubectl get deployments
# describe created deployment
    kubectl describe deployment my-deployment
# deployment strategies 
1- recreate strategy:
    destroy all created instances and create new one with updated version
    this is not default strategy
2- Rolling Update strategy:
    its mean if we have 5 running instances then delete 1 instance and create updated instance, then delete 2 instance and create updated instance and so on
    this is default strategy
# scale the deployment
    kubectl scale deployment/nginx-deployment --replicas=10
# auto scale the deployment based on the cpu utilization
    kubectl autoscale deployment/nginx-deployment --min=10 --max=15 --cpu-percent=80
# pause the deployment to rollout so that we can make any fixes
    kubectl rollout pause deployment/nginx-deployment
Note: when we paused the deployment we can make the new fixes, multiple times once fixed the issues we can resume the deployment
# resume the deployment for rollout
    kubectl rollout resume deployment/nginx-deployment
# set the resources
    kubectl set resources deployment/nginx-deployment -c=nginx --limits=cpu=200m,memory=512Mi
    
################# rollout and rollback #################
# update the deployment
    # make image changes in the file and hit following command
    kubectl apply -f file_name --record=true
    # without making changes in file, set the image
    kubectl set image deployment/my-deployment nginx=nginx:1.9.1
# rollout the deployment
    kubectl rollout status deployment/my-deployment --record
# see the history of rollout
     kubectl rollout history deployment/my-deployment
# rollback the deployment at a spcific version
    kubectl rollout undo deployment/my-deployment --to-revision=2

################# service #################
Nodeport
    NodePort: Port on which traffic will come and it will be forwarded to pod's port. e.g 3000
    range: 30000-32767
    port: each service has also a port which is simply called port. e.g 80
    TargetPort: It is the pod's port on which traffic will be forwarded to.  e.g 80


clusterIP
Loadbalancer

