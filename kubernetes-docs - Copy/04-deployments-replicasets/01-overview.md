## What is Workload
In Kubernetes, workloads represent the applications and services you deploy within a cluster. Workloads are key resources that determine how containers are created, managed, and scaled across your cluster nodes.

## Types of workload
- Pod
- Containers running inside Pods

## Stateless vs Stateful Workloads
### Stateless

Stateless workloads do not store data locally and treat every request as an independent event.

- <b>Behavior: </b> If a pod crashes or is deleted, it can be replaced by a new, identical pod without any data loss because it doesn't "own" any data.
- <b>Kubernetes Object:</b> Managed via Deployments or ReplicaSets.
- <b>Identity:</b> Pods have random names and no permanent network identity.
- <b>Scaling:</b> Can be scaled up or down instantly in any order.
- <b>Examples:</b> Web frontends (Nginx), REST APIs, and microservices

### Stateful Applications
Stateful workloads require persistent storage and a stable identity to function correctly. They must remember past interactions, such as database transactions or user sessions
- <b>Behavior: </b> These applications expect the same data to be available even after a restart. Data is stored in PersistentVolumes (PV) that remain attached to specific pods.
- <b>Kubernetes Object:</b> Managed via StatefulSets.
- <b>Identity:</b> Pods have unique, sticky names (e.g., web-0, web-1) and stable network IDs that persist through restarts.
- <b>Scaling:</b> Scaling occurs in a strict, predictable order (0 then 1 then 2).
- <b>Examples:</b> Databases (MySQL, PostgreSQL, MongoDB), message queues (Kafka, RabbitMQ), and caching systems like Redis

## Workload Management
Kubernetes provides several built-in APIs for declarative management of your workloads and the components of those workloads.

Ultimately, your applications run as containers inside Pods; however, managing individual Pods would be a lot of effort. For example, if a Pod fails, you probably want to run a new Pod to replace it. Kubernetes can do that for you.

You use the Kubernetes API to create a workload object that represents a higher abstraction level than a Pod, and then the Kubernetes control plane automatically manages Pod objects on your behalf, based on the specification for the workload object you defined.

The built-in APIs for managing workloads are:
- Replication Controller
- Deployment
- ReplicaSet
- StatefulSet
- DaemonSet
- Jobs
- CronJob

### Easy Analogy

Imagine:

| Real World | Kubernetes |
|------|-------------|
| Workers | Pods |
| Manager | Deployment / StatefulSet 

The manager does not do the work itself. It manages workers.

### 1. Deployment
Deployments are one of the most commonly used Kubernetes workloads, particularly suited for stateless applications, where each pod instance is identical and can be scaled easily. Deployments are designed to run a set number of replicas, handle rolling updates, and allow for easy rollbacks if something goes wrong.

- <b>Use Case:</b> Web applications, APIs, or any stateless services where scalability and flexibility are essential.
- <b>Key Features: </b>Deployments support declarative updates, meaning you define the desired state, and Kubernetes aligns the current state to match. Deployments are also self-healing, automatically restarting failed pods to maintain the specified number of replicas.

### 2. ReplicaSet
A ReplicaSet maintains a stable number of pod replicas running at any given time. While similar to Deployments, ReplicaSets lack the advanced features for declarative updates and rollbacks. Instead, they are typically used under the hood by Deployments to ensure the specified number of pod replicas.
- <b>Use Case:</b> ReplicaSets are usually part of a Deployment. However, they can also be used directly for custom scenarios that require precise control over replica count without the need for rolling updates.
- <b>Key Features: </b>ReplicaSets are self-healing, maintaining the specified number of replicas by replacing any failed pods. They’re simple yet reliable, but are typically used as part of a larger Deployment resource.

### 3. StatefulSet
For applications that require persistent identity and stable storage across restarts. StatefulSets are designed for stateful applications where each instance of the application requires a unique identity, consistent storage, and ordered scaling or updates.
- <b>Use Case:</b> Databases like MySQL, Cassandra, and distributed systems that rely on stable storage and networking.
- <b>Key Features: </b>StatefulSets provide stable, unique network identifiers for each pod, such as sequential naming (e.g., `my-app-0`, `my-app-1`). They also use persistent volumes to retain data even if a pod is rescheduled or restarted, ensuring data continuity across sessions.

### 4. DaemonSet
A DaemonSet ensures that a particular pod runs on every node (or a subset of nodes) within the cluster. DaemonSets are essential for workloads that need to run a single instance on each node, such as monitoring agents or logging daemons.

- <b>Use Case:</b> System-level monitoring tools like Prometheus Node Exporter, log collectors like Fluentd, and other node-specific services.
- <b>Key Features: </b> DaemonSets automatically schedule pods on each node as it is added to the cluster, and they delete pods from nodes when those nodes are removed. This setup ensures that critical services have node-level coverage without manual intervention.

### 5. Job
Jobs in Kubernetes are designed for tasks that need to run once and then terminate. Jobs ensure that a specified number of pod replicas complete successfully and are automatically deleted upon completion. This workload type is suited for single-run tasks, such as data processing, batch jobs, or database migrations.

- <b>Use Case:</b> One-time data processing, report generation, and any task requiring guaranteed execution without continuous running.
- <b>Key Features: </b> Jobs can be configured to retry on failure, so if a pod fails, Kubernetes will launch a new one until the task completes. This retry mechanism is essential for high-reliability tasks where successful completion is required.

### 6. CronJob
CronJobs build on the Job workload, adding the ability to schedule Jobs at specific intervals. Similar to cron jobs on Unix-like systems, Kubernetes CronJobs are designed for periodic tasks that need to run at fixed times or intervals.

- <b>Use Case:</b> Scheduled database backups, log rotation, cache clearing, and any recurring task.
- <b>Key Features: </b> CronJobs support flexible scheduling using cron syntax, allowing tasks to run daily, weekly, or on other specified schedules. Kubernetes ensures each scheduled Job runs at the correct time, making CronJobs useful for automating routine maintenance.