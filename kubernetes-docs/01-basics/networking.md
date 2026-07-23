## Container Networking
Container networking enables isolated containers to communicate with each other, the host machine, and external networks, typically using virtual bridges or overlay networks

## Network Namespaces
Containers are isolated from other containers and hosts with namespaces.
From container we can't see the process running on the host but from host we can see the processes of containers.

Real time example

Namespaces are just like rooms in the house. Each room is assigned to a child, where a child can't see what is happening in other rooms. However, as a parent, you have visibility of all the rooms in the house. If you wish, you can establish the connectivity between the other rooms

For each container there is a namespace which isolate this container from others.

## Interfaces for host

Each host as its own 
- network interface through which it is connected with local area network
- routing table
- ARP table

Same for container, when a container is created, a namespace is also created with it. Container can has its own 
- virtual interface (veth)
- Routing table
- ARP table

ARP table is created when we access or ping to other ip, if ping is success then it gets its mac address otherwise it shows as incomplete.

We can check 'arp -n' commnad

## How to create namespaces, How to create virtual network, how to assign ip addresses to namesapaces, and how to make connectivity

Points:
- Create namespace on host
- Create interfaces for namespace on host
- Attach interfaces to namespaces from the host
- Give IP address to each interface by going inside the namespace
- Make the interface up by going inside the namespace
- Ping other namespace by going inside the namespace

#### Create new network namespaces  with named red and blue
```
ip netns add read
ip netns add blue
```

#### list the namespaces 
```
ip netns
```

#### list the interfaces on the host
```
ip link
```

#### list the interfaces within the namespaces created above
```
ip netns exec red ip link
or
ip -n red link
```

#### execute the arp command on host
```
arp
```
#### execute the arp command on namespace
```
ip netns exec red arp
```
### make the connectivity between 2 namespaces with pipe or with virtual cabel just like we connect 2 physical machines with cabel

#### to create the virtual cabel
```
ip link add veth-red type veth peer name veth-blue
    veth-red <------> veth-blue
```

#### Attach veth-red with red and veth-blue with blue namespaces
```
ip link set veth-red netns red
ip link set veth-blue netns blue
```

#### Assign the IP Addresses to each namespaces
```
ip netns exec red ip addr add 192.168.10.1/24 dev veth-red
ip netns exec blue ip addr add 192.168.10.2/24 dev veth-blue
```

#### Up the links of both namespaces
```
ip -n red link set veth-red up
ip -n blue link set veth-blue up
```
#### Try ping from red namespace to blue namespace
```
ip netns exec red ping 192.168.10.2
```

#### Look the arp table of red namespace
```
ip netns exec red arp
```

#### list the arp table of blue namespace
```
ip netns exec blue arp
```

#### list the host arp table. Host has no idea about this new namespaces we have created
```
arp
```

## Use of Virtual Switch
If there are too many namespaces, there would be difficulty to make connectivity between each of them manually. To make it easy we create virtual switch and connect the namespaces to this virtual switch. For this there are multiple solutions available like Linux bridge, Open Switch. Let's use Linux Bridge

#### To create internal bridge network, we add a new virtual interface on the host.
```
ip link add v-net-0 type bridge
```

#### List the interfaces on the host
```
ip a
```

#### UP the above newly created virtual interface
```
ip link set dev v-net-0 up
```

Above is interface for the host and virtaul switch for namespaces. Namespaces will be connected to this vitual switch. Since we have created a virtaul cabel in above steps to connect 2 namespaces directly. Now we don't need that. We need a new cable through wich namespace will be connected to virtaul switch.

#### Delete the above created cabel. By deleting one side, other side will be deleted automatically.
```
ip -n red link del veth-red
```

#### create new cabel for connection between namespace and virtual switch.
```
ip link add veth-red type veth peer name veth-red-br
    here
    - veth-red (interface for red namespace)
    - veth-red-br, other end of cabel which indicates the connection with bridge network
ip link add veth-blue type veth peer name veth-blue-br
```

#### To attach the one end of above created cabel with red and blue namespaces 
```
ip link set veth-red netns red
ip link set veth-blue netns blue
```

#### To attach the other end of the above virtual cable with virtual switch
```
ip link set veth-red-br master v-net-0
ip link set veth-blue-br master v-net-0
```

#### set the ip addresses for the above namespaces
```
ip -n red addr 192.168.10.1 dev veth-red
ip -n blue addr 192.168.10.2 dev veth-blue
```

#### turn the devices up
```
ip -n red link set veth-red up
ip -n blue link set veth-blue up
```
Now the containers will be able to communicate with each other.

## Establish connectivity between host and namespaces
Since we created a new interface for host with named `v-net-0` in above steps. Now we just need to have assign the IP address to this interface so we can reach the namespaces through it.
```
 ip addr add 192.168.10.5/24 dev v-net-0
```

#### Now ping red name space from host
```
ping 192.168.10.1
```
## Establish connection between namespace other host/vm
what if we want to make connection between our red namcespace with other host/virtual machin. Currently if we ping the other host ip (192.168.1.3), it will first check its routing table and since there is no information for other host or IP, so it will say Network is unreachable
```
ip netns exec blue ping 192.168.1.3
```

#### To communicate between multiple hosts, add the gateway entry in namespace routing table. let's do it in blue namespace's routing table
```
ip netns exec blue ip route add 192.168.1.0/24 via 192.168.10.5(IP of virtual interface)
```

#### Now if we try to ping other host from blue namespace, we will not get network unreachable but we will not get ping result
```
ip netns exec blue ping 192.168.1.3
```

#### To get the ping result or response from othe host, we have to enable NAT on our host.
```
iptables -t nat -A POSTROUTING -s 192.168.10.0/24(namespace network) -j MASQUERADE
```

#### Now if we try to ping, we will get the ping responce back.
```
ip netns exec blue ping 192.168.1.3
```
### Access the Internet from namespace

To access the internet from our namespace, we have to add default gateway. Or we say, to reach anything which is accessible from our host talk to our host.
```
ip netns exec blue ip route add default via 192.168.10.5
```

#### Try to ping google.com
```
ip netns exec blue ping 8.8.8.8
```

## CNI

In any containerization technology like Docker,rkt,Mesos, kubernetes, following steps are performed for container networking. So that containers can communicate with each other and remains isolated from host network
1. Create namespaces
2. Create Bridge Network/Interface
3. Create VETH Pairs(Pipe, Virtual Cabel)
4. Attach vETH to namespace
5. Attach Other vETH to Bridge
6. Assign IP Address
7. Bring the interface UP
8. Enable NAT - IP Masquerade

Since each containerization technology do the same practice, so everyone thought instead of writing same program for their technology, their should be a separate code which is standarized for each containerization technology and everyone easyly adopt it. 

All the above networking portion is moved into a single code which is called `bridge`. 

For example, to attach a container to a specifice namespace we use following command

```
bridge add container_ID /var/run/netns/container_ID
```
When a kuberntes or rkt creates a container, they call the bridge program and pass the container_id and namespace to bridge to get networking configure for that container.

So if you want to create such a program for yourself like for new networking type, there should be some standards that can define how a program should look, how a container run time can call to that program, how commands and what areguments should be there for your networking type. That is where a Container Network Interface comes in.

CNI is a set of standards that defines how program should be developed to solve networking challenges in container run time environment.

The program reffered as plugins. In current case, the bridge program that we have been refering to is a plugin for CNI. CNI defines how the plugin should be developed and how container runtime should invoke them.

CNI defines set of responsibilites for container run time and plugins.

Container runtime, CNI specifies that
1. Container runtime must create network namespace for each container
2. Container runtime must identify network the container must attach to
3. Container runtime should invoke the Network Plugin (Bridge) when container is added/deleted
4. JSON format of the Network Configurations

on Plugin size, CNI specifies that

1. Plugin must support command line arguments ADD/DEL/CHECK
2. Plugin must support parameters container_id, network namespace etc.
3. Plugin must manage IP Address assignment to PODs,
4. Plugin must return result in specific format

Any runtime should be able to work with any plugin

CNI already comes with supported plugins such as Bridge, VLAN, IPVLAN, MACVLAN, WINDOWS and IPAM plugins like DHCP, Host-local

Some other third party plugins weaveworks, flannel, cilium, Vmware(NSX), Calico

All the container runtime supports all these plugins.

Docker has its own set of standards which are known as Container Network Model. This is similer to CNI but with differences. Due to differences, above mentiond plugins can not be integrated with docker

e.g 
```
docker run --network=cni-bridge nginx --> This is wrong

# To use CNI
# Create Docker container without networking
docker run --network=none nginx

# Then manually invoke the bridge plugin
bridge add container_id /var/run/netns/container_id
```

## Real lifecycle when a Pod is created

When you run:
```
kubectl apply -f pod.yaml
```

Step 1 — Kubernetes API

Kubernetes scheduler decides: This pod should run on Node A

Step 2 — kubelet (node agent)

On Node A, kubelet receives the instruction: Create pod networking + containers
kubelet is the component that orchestrates everything on the node.

Step 3 — kubelet → container runtime

kubelet talks to the runtime via CRI:
- containerd
- CRI-O
- (Docker used to work via dockershim)

kubelet says:

    Create a sandbox (pod network namespace)

Step 4 — container runtime calls CNI

Now the runtime executes:
```
CNI ADD
```
It runs the configured CNI plugin binary and passes:

- network namespace
- container ID
- config JSON

The plugin:

- creates veth pair
- assigns IP
- attaches to bridge/overlay
- sets routes
- returns result

Step 5 — runtime returns success

Networking is ready.
Then containers start inside that namespace.








