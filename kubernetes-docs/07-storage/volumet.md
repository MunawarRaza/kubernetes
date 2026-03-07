# Agenda
1. Volumes
    - Types of Volumes
2. Persistent Volumes
3. PersisitentVolumeClaims
4. Storage Class
## What is Volume
A volume is a directory, possibly with some data in it, which is accessible to the containers in a pod.

A process in the container sees a filesystem view composed from the initial contents of the container image, plus volumes (if defined) mounted inside the container. The process sees a root filesystem that initially matches the contents of the container image

Note:
- Volumes cannot mount within other volumes
- A volume cannot contain a hard link to anything in a different volume

## Container Layered Architecture
When we build the container, it uses the layred architecture in which it creates a layer for each line and when we build image with changes in Dockerfile or forom other Dockerfile which is having few same instructions as first Dockerfile, docker uses the layered from previous build.

There are tow types of mount
1. Volume mount
2. Bind mount

### Volume mount
When we create a volume with docker create volume command, a volume is created in /var/lib/docker/volumes and we mount this volume with following command
```
docker run -v data_volume:/var/lib/mysql mysql
```
### Bind Mount
Mount a directory from any location of the host.
```
docker run -v /opt/mysql:/var/lib/mysql mysql

#Recomended and lates way 

docker run --mount -type=bind,source=/opt/mysql,target=/var/lib/mysql mysql
```
## Storage Driver
Docker use the storage drive to enable layerd architecutre. Sotrage drive is responsible for all operations like maintaing the layered architecture, creating writeable layers, moving files accross layers etc.

### Common Storage Drviers
Docker will chose best storage driver automatically based on the operating System
- AUFS
    - This is defualt for Ubuntu and not available for other systems like CentOS and Fedora. In that case Device Mapper is the better option
- ZFS
- BTRFS
- Device Mapper
- Overlay
- Overlay2


## Types of volumes
- configMap

    A ConfigMap provides a way to inject configuration data into pods. The data stored in a ConfigMap can be referenced in a volume of type configMap and then consumed by containerized applications running in a pod.
- downwardAPI

    DownloadAPI is the mechanisam to expose pod and container the fields values to the code running in a container.

- emptyDir

    For a Pod that defines an emptyDir volume, the empty volume is created when the Pod is assigned to a node.
    When a Pod is removed from a node for any reason, the data in the emptyDir is deleted permanently

- hostPath

    A hostPath volume mounts a file or directory from the host node's filesystem into your Pod. 

## Persistent Volume
A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.
To share the volume accross multiple pods with different access mode for data persistancy we create persistant volume

```
apiVersion: v1
kind: PersistantVolume
metadata:
  name: pv-voll
spec:
  accessModes:
    - ReadWriteOnce | ReadOnlyMany | ReadWriteMany
  capacity:
    storage: 1Gi
  hostPath:
    
```

## Persistent  Volume Claims
A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes

An administartor creates the persistent volume object and user create persitent volume claims to use the storage

Kubernetes binds the persistent volume to persitent volume claims based on the request and properties set on the volume. Every persitent volume claim is bound to single persistent volume.


```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce | ReadOnlyMany | ReadWriteMany
  resources:
    requests:
      storage: 500Mi
```
kubectl get persistentvolumeclaims

AccessModes
- ReadWriteOnce
- ReadOnlyMany
- ReadWriteMany
- ReadWriteOncePod

## Storage Class
Before the PV is created we must have to create volume on cloud like on gcp,aws etc
To resolve this we must have to create storageClass object so that it automatically creates the storage on cloud
If we use this then we don't need to create pv definition/object separately. storage class auto matically handles this because we have used stoarageClassName in our persistentVolumeClaim

