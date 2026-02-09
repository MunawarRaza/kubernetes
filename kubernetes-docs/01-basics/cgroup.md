## What is Control Group (cgroup)

Cgroups allows you to allocate resources — such as CPU time, system memory, network bandwidth, or combinations of these resources — among user-defined groups of tasks (processes) running on a system

cgroups lets you decide how much CPU, RAM ,disk I/O etc, a process or a group of processes is allowed to use

There two versions of cgroup. V1 and V2

## What are Cgroup Drivers?
A cgroup driver defines how a component (like kubelet or container runtime) interacts with Linux cgroups

It’s not a kernel feature, it’s a configuration choice made by:
* kubelet
* container runtime (Docker / containerd)

The cgroup driver tells Kubernetes:
* where cgroups live
* who controls them

## How many types of cgroup driver
There two types of cgrup driver
* systemd
* cgroupfs

### cgroupfs

Directly manages cgroups via filesystem:
``` 
/sys/fs/cgroup/
```

this is older and simple cgroup driver.
## how to check cgroup version
There are 2 versions of cgroup v1 and v2
to check which is running use
```
stat -fc %T /sys/fs/cgroup/
```
For cgroup v2, the output is cgroup2fs.

For cgroup v1, the output is tmpfs.

### systemd as cgroup driver
* systemd is responsible for managing cgroups
* kubelet and runtime integrate with systemd

Note for kubernetes:

``` Kubelet and container runtime MUST use the same cgroup driver```



## How to check cgroup driver

### Docker
docker info | grep -i cgroup

### Containerd
containerd config dump | grep SystemdCgroup

### kubelet
ps aux | grep kubelet | grep cgroup

Note:

``` Cgroupfs is the default cgroup driver in the kubelet ```

## How to change in Docker

## How to change in containerd

```
# download the configurations with following command

containerd config default | sudo tee /etc/containerd/config.toml

# change SystemdCgroup = false to SystemdCgroup = true in /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl restart containerd

```

## How to change in kubernetes
Configure Cgroup driver as systemd in kubelet configuration.

```
Edit the KubeletConfiguration option of cgroupDriver and set it to systemd
 For example
			apiVersion: kubelet.config.k8s.io/v1beta1
			kind: KubeletConfiguration
			cgroupDriver: systemd
            
    kubelet --feature-gates=SystemdCgroup=true
    Or
    /var/lib/kubelet/config.yaml
    cgroupDriver: systemd
```


## Difference Between cgroups and ulimit
### ulimt
Applies resource limits on a per-process basis and primarily for the current shell session. Root user can change the limit

```
file:
/etc/security/limits.conf 

command: ulimt
```

### cgroup
Controls a collection of processes as a single entity, regardless of the parent-child relationship. This allows for managing resources for an entire service, user session, or container.