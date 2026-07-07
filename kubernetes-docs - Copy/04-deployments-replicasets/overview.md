## What is Replication Contoller
Replication controllers helps us to run multiple instances of a single pods in kubernetes cluster to provide high availability. It maintains our desired number of pods. This is older and depricated in newer version but supported. In object specification file we just define the replicas field. like
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: myapp-rc
  labels:
    type: webserver

spec:
  template:
    metadata:
      name: nginx-pod
      labels:
          type: webserver 
    spec:
      containers:
        - name: nginx-container
          image: nginx
  replicas: 3
```  

## What is ReplicaSet
ReplicaSet does the same thing as ReplicationController but with different way

```
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-pod # pod name
spec:
  template:
    metadata:
      name: replicas-pod
      labels:  
        type: webserver # used in selector too
    spec:
      containers:
        - name: replicas-container
          image: nginx
  replicas: 6
  selector:
    matchLabels:
      type: webserver # match this from spec.template.metadata.labels
```

## What is deployment
A Deployment manages a set of Pods to run an application workload. You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.
### Benifits of Deployment
- Rollout a ReplicaSet
- Rollback a ReplicaSet
- Scale up the deployment
- pause the rollout of a deployment

In object file, there is no difference between replicaset and deployment file except kind. In replicaSet kind is replicaSet and in Deployment file the kind is deployment


- Deployment creates the replicaSet and replicaSet creates the pods
- The .spec.selector field defines how the created ReplicaSet finds which Pods to manage

### 🔴 Note

A Deployment's rollout is triggered if and only if the Deployment's Pod template (that is, .spec.template) is changed, for example if the labels or container images of the template are updated. Other updates, such as scaling the Deployment, do not trigger a rollout.

### Rollout the deployment
Let's update our application

1. update image using kubectl set command

        kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1

        syntax:

            kubectl set image deployment/deployment-name container-name=images-name

2. update image using kubectl edit command

        kubectl edit deployment/nginx-deployment

3. To see the rollout status, run:
    
        kubectl rollout status deployment/nginx-deployment

4. Get details of your Deployment

        kubectl describe deployments

Deployment ensures that only a certain number of Pods are down while they are being updated. By default, it ensures that at least 75% of the desired number of Pods are up (25% max unavailable)

Deployment also ensures that only a certain number of Pods are created above the desired number of Pods. By default, it ensures that at most 125% of the desired number of Pods are up (25% max surge).

### Checking Rollout History of a Deployment

1. check the revisions of this Deployment:
    
        kubectl rollout history deployment/nginx-deployment

        # Output
            deployments "nginx-deployment"
            REVISION    CHANGE-CAUSE
            1           <none>
            2           <none>
            3           <none>
        Heere REVISION 3 is the latest.
2. Give the description of rollout/rollback revisions
 
        kubectl annotate deployment/nginx-deployment kubernetes.io/change-cause="image updated to 1.16.1"

3. To see the details of each revision, run:

        kubectl rollout history deployment/nginx-deployment --revision=2

### Rolling Back to a Previous Revision

1. Now you've decided to undo the current rollout and rollback to the previous revision:

        kubectl rollout undo deployment/nginx-deployment

2. Rollback to specific version

        kubectl rollout undo deployment/nginx-deployment --to-revision=2

### Pausing and Resuming a rollout of a Deployment
When you update a Deployment, or plan to, you can pause rollouts for that Deployment before you trigger one or more updates. When you're ready to apply those changes, you resume rollouts for the Deployment. This approach allows you to apply multiple fixes in between pausing and resuming without triggering unnecessary rollouts.

1. pause running deployment

        kubectl rollout pause deployment/nginx-deployment

2. update image

        kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
3. Notice that no new rollout started:

        kubectl rollout history deployment/nginx-deployment

3. resume deployment

        kubectl rollout resume deployment/nginx-deployment

### Scaling a Deployment

1. You can scale a Deployment by using the following command:

    kubectl scale deployment/nginx-deployment --replicas=10

2. Scale on the basis of CPU

        kubectl autoscale deployment/nginx-deployment --min=10 --max=15 --cpu-percent=80

### Proportional scaling
When you or an autoscaler scales a RollingUpdate Deployment that is in the middle of a rollout (either in progress or paused), the Deployment controller balances the additional replicas in the existing active ReplicaSets (ReplicaSets with Pods) in order to mitigate risk. This is called proportional scaling.

maxSurg=25%
maxUnavailable=25%

### Deployment status

#### Progressing Deployment
Kubernetes marks a Deployment as progressing when one of the following tasks is performed:

- The Deployment creates a new ReplicaSet.
- The Deployment is scaling up its newest ReplicaSet.
- The Deployment is scaling down its older ReplicaSet(s).
- New Pods become ready or available (ready for at least MinReadySeconds).

#### Complete Deployment
Kubernetes marks a Deployment as complete when it has the following characteristics:

- All of the replicas associated with the Deployment have been updated to the latest version you've specified, meaning any updates you've requested have been completed.
- All of the replicas associated with the Deployment are available.
- No old replicas for the Deployment are running.

#### Failed Deployment

Your Deployment may get stuck trying to deploy its newest ReplicaSet without ever completing. This can occur due to some of the following factors:

- Insufficient quota
- Readiness probe failures
- Image pull errors
- Insufficient permissions
- Limit ranges
- Application runtime misconfiguration

Configure how many seconds a Deployment Controller should wait before indicating that the Deployment progress is failed
`.spec.progressDeadlineSeconds`

#### Operating on a failed deployment
All actions that apply to a complete Deployment also apply to a failed Deployment
You can 
- scale it up/down
- roll back to a previous revision
- pause it if you need to apply multiple tweaks in the Deployment Pod template

### Clean up Policy

1. Specify how many old ReplicaSet of this Deployment you want to retain by specifing the field `.spec.revisionHistoryLimit`. The rest will be garbage-collected in the background. By default, it is 10.

    You can check how many revisons/history is avaibale of ReplicaSet

        kubectl get replicaSet
### Canary Deployment
If you want to roll out releases to a subset of users or servers using the Deployment, you can create multiple Deployments, one for each release, following the canary pattern described in managing resources.

### Pod Template 

#### template
#### selector
#### replicas

#### strategy
`.spec.strategy` specifies the strategy used to replace old Pods by new ones. `.spec.strategy.type` can be `Recreate` or `RollingUpdate`. "RollingUpdate" is the default value

##### RollingUpdate
The Deployment updates Pods in a rolling update fashion (gradually scale down the old ReplicaSets and scale up the new one) when `.spec.strategy.type==RollingUpdate`. You can specify maxUnavailable and maxSurge to control the rolling update process

##### Recreate
All existing Pods are killed before new ones are created when `.spec.strategy.type==Recreate`

##### Max Unavailable
`.spec.strategy.rollingUpdate.maxUnavailable` is an optional field that specifies the maximum number of Pods that can be unavailable during the update process. The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%). The default value is 25%.

##### Max Surge
`.spec.strategy.rollingUpdate.maxSurge` is an optional field that specifies the maximum number of Pods that can be created over the desired number of Pods. The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%). The value cannot be 0 if maxUnavailable is 0.
    