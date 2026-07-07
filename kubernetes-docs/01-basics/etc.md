## What is ETCD

This is distributed relible key-value store that is simple, secure and fast

## What is key-value store

## Install ETCD
1. Download the binary
2. Extract
3. RUN ETCD service

It run on 2379 port

## ETCD Client

etcd controll client that is default 

For Example
```
./etcdctl set key1 value1
./etcdctl get key1
```

## ETCD in k8s
It stores the information regarding the cluster like
- Nodes
- PODs
- Configs
- Secrets
- Accounts
- Roles
- Bindings
- Others

Every information we get using kubectl get command, it retrives from etcd every change we made it stores in etcd database

## Deploy the ETCD in k8s

<b> Deploy Manually </b>
1. Download the Binary

2. Extract it 

3. Configure the service etcd.service in master node

<b> Deploy with kubeadm </b>

if it is deployed with kubeadm we can check

```
kubectl get pod -n kube-system
```
To list the all keys 
```
kubect exec pod etcd-master -n kube-system etcdctl get / --prefix --keys-only
```

Kubernetes stores the data in specific directory
```
/registry
    - minions
    - pods
    - replicasets
    - deployments
    - roles
    - secrets
```

## Etcd in HA

if we have etcd in multiple instances then we have to configure the etcd.service in such a way that everyone knows each other. below parameter is used
etcd.service
```
--initial-cluster controller-0=https://{controller0_IP}:2280,controller-1=https://{controller1_ip}:2280 \\
```

