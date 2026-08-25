## Security

There are multiple ways to restrict the access and give role base access to the resources.

we can define access of the users based on the username and password.


create a csv file and add password,user,userid,group

password123,user1,u0001,group1
password123,user2,u0002,group1
password123,user3,u0003,group2

modify kube-api-server's manifist file
vim /etc/kubernetes/manifests/kube-apiserver.yaml 

--basic-auth-file=user-details.csv

and restart the server

curl -v -k https://master-node-ip:6443/api/v1/pods -u "user1:password123"


authentication based on the token

user-token-details.csv

randomtoken:user1,u0001,group1
randomtoken2:user2,u0002,group2

modify kube-api-server's manifist file
vim /etc/kubernetes/manifests/kube-apiserver.yaml 

--token-auth-file=user-token-details.csv

and restart the server

curl -v -k https://master-node-ip:6443/api/v1/pods --header "Authorization: Bearer randomtoken"


========
TLS certificates for cluster

kubernetes server certificates

- kube-apiserver
    - apiserver.crt
    - apiserver.key

- ETCD Server
    - etcdserver.crt
    - etcdserver.key

- Kubelet server
    - kubelet.crt
    - kubelet.key

Client Components/ Client Certificates


Clients are those componenets who talk to the kube-api-server like kube-scheduler, kube-proxy etc. Same way if kube-apiserver has to talk to any other componenets like etcd so here kube-apiserver is the client for etcd server. If kube-apiserver is the client for etcd, then it can use its previous apiserver.crt and apiserver.key to authenticate with etcd or it can generate specific certificates for etcd like apiserver-etcd-client.crt, apiserver-etcd-client.key. Same way kube-apiserver for kube-let. it can generate new certificates for kubelet like apiserver-kubelet-client.crt, apiserver-kubelet-client.key

- Admin Users
    - admin.crt
    - admin.key

As an Admin we have to access the kube-apiserver. so we need certificates for us

- Kube Scheduler
    - scheduler.crt
    - scheduler.key

Scheduler is the client for kube-apiserver. It just like who talks to kube-apiserver, so he needs to validate his identity with his own pairs of certificates which are above.

- kube controller manager
    - controller-manager.crt
    - controller-manager.key

kube controller manager is the client for kube-apiserver needs to talk to kube-apiserver

- kube proxy
    - kube-proxy.crt
    - kube-proxy.key

kube-proxy is the client for kube-apiserver



