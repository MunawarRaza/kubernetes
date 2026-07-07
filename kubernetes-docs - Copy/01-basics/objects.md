# Table of Contents

- [Objects In Kubernetes](#objects-in-kubernetes)
- [Known Types of Objects](#known-types-of-objects)
- [Describing a Kubernetes Object](#describing-a-kubernetes-object)
  - [Required fields](#required-fields)
  - [Object spec and status](#object-spec-and-status)
    - [spec](#spec)
    - [Status](#status)
- [Server side field validation](#server-side-field-validation)
  - [Strict](#strict)
  - [Warn](#warn)
  - [Ignore](#ignore)
- [Object Management](#object-management)
- [Object Names and IDs](#object-names-and-ids)
  - [DNS Subdomain Names](#dns-subdomain-names)
  - [UIDs](#uids)
- [Labels and Selectors](#labels-and-selectors)
  - [Syntax and character set](#syntax-and-character-set)
    - [key name](#key-name)
    - [key prefix](#key-prefix)
    - [key value](#key-value)
  - [Label selectors](#label-selectors)
  - [Best Practice](#best-practice)
  - [Types of selectors](#types-of-selectors)
    - [Equality-based](#equality-based)
    - [Set-based](#set-based)
- [Annotations](#annotations)
  - [Difference between Lables and Annotations](#difference-between-lables-and-annotations)
    - [Lables](#lables)
    - [Annotations](#annotations-1)
  - [Use Cases](#use-cases)
- [Field Selectors](#field-selectors)
  - [List of supported fields](#list-of-supported-fields)
  - [Supported operators](#supported-operators)
  - [Chained selectors](#chained-selectors)
  - [Multiple resource types](#multiple-resource-types)
- [Namespaces](#namespaces)
- [Finalizers](#finalizers)
- [Owners and Dependents](#owners-and-dependents)

## Objects In Kubernetes
Kubernetes objects are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of your cluster.
Objects are sort of like blueprints. They provide detailed instructions to Kubernetes on how the applications must be set up and managed

For example, a Deployment object might specify that you want three replicas (copies) of some application running at all times, while a Service object might define how you want to expose your application to the internet. Kubernetes then takes these instructions and automatically configures and manages the application accordingly, ensuring that it always matches the desired state.


## Known Types of Objects
01. Pod
02. Deployment
03. ReplicaSet
04. StatefulSet
05. DaemonSets
06. PersistentVolume
07. Service
08. Namespaces
09. ConfigMaps 
10. Secrets
11. Job

## Describing a Kubernetes object

When you create an object in Kubernetes, you must provide the object spec that describes its desired state, as well as some basic information about the object (such as a name).
You use the Kubernetes API to create the object either directly or via kubectl. Tools such as kubectl, convert the information from a manifest (.yaml) into JSON or another supported serialization format when making the API request over HTTP.

### Required fields
In the manifest file, we must write

- apiVersion - Which version of the Kubernetes API you're using to create this object
- kind - What kind of object you want to create
- metadata - Data that helps uniquely identify the object, including a name string, UID, and optional namespace
- spec - What state you desire for the object

> **Note:**  
>spec field is different for each object, which contains nested fields specific to that object

### Object spec and status
Almost every Kubernetes object includes two nested object fields that govern the object's configuration: the object `spec` and the object `status`

#### spec
spec (which describe the desired state of any object) is set by the user while creating the manifest file.
#### Status
status (which describe the current running state of any object) is set and updated by the kubernetes system and its components

## Server side field validation
Server side field validation detects unrecognized or duplicate fields in an object.

Kubernetes always validates the type of fields. For example, if a field in the API is defined as a number, you cannot set the field to a text value. If a field is defined as an array of strings, you can only provide an array.

The kubectl tool uses the `--validate` flag to set the level of field validation. It accepts the values `ignore`, `warn`, and `strict` while also accepting the values `true` (equivalent to `strict`) and `false` (equivalent to `ignore`). The default validation setting for kubectl is `--validate=true`

#### Strict
Strict field validation, errors on validation failure. The API server rejects the request with a 400 Bad Request error when it detects any unknown or duplicate fields.
#### Warn
Field validation is performed, but errors are exposed as warnings rather than failing the request
#### Ignore
No server side field validation is performed

## Object Management



## Object Names and IDs
Each object in your cluster has a Name that is unique for that type of resource.

Every Kubernetes object also has a UID that is unique across your whole cluster.

For example, 2 pods in same namespace cannot have same name but 1 pod, 1 deployment, 1 service and other type of object can have same name in samenamespace.

The server may generate a name when `generateName` is provided instead of `name` in a resource create request. Even though the name is generated, it may conflict with existing names resulting in an HTTP 409 response.

### DNS Subdomain Names
Most resource types require a name that can be used as a DNS subdomain name. This means the name must:

- contain no more than 253 characters
- contain only lowercase alphanumeric characters, '-' or '.'
- start with an alphanumeric character
- end with an alphanumeric character

### UIDs
A Kubernetes systems-generated string to uniquely identify objects.
Every object created over the whole lifetime of a Kubernetes cluster has a distinct UID.

## Labels and Selectors
Labels are key/value pairs that are attached to objects such as Pods.

Labels can be used to organize and to select subsets of objects.

Labels can be attached to objects at creation time and subsequently added and modified at any time. Each object can have a set of key/value labels defined.

### Syntax and character set
Labels are key/value pairs. Valid label keys have two segments: an optional prefix and name, separated by a slash (/)

#### key name
The name segment is required and must follow the rule

- contain no more than 62 characters
- contain only lowercase alphanumeric characters, dashes (-), underscores (_), dots (.)
- start with an alphanumeric character
- end with an alphanumeric character

#### key prefix
The prefix is optional. If specified, the prefix must be a DNS subdomain: a series of DNS labels separated by dots (.), not longer than 253 characters in total, followed by a slash (/).

For example
```
example.com/app: myapp
example.com/env: qa
type: frontend
```

#### key value
Valid label value:
- must be 63 characters or less (can be empty),
- unless empty, must begin and end with an alphanumeric character ([a-z0-9A-Z]),
- could contain dashes (-), underscores (_), dots (.), and alphanumerics between.

### Label selectors
Unlike names and UIDs, labels do not provide uniqueness. In general, we expect many objects to carry the same label(s).
Via a label selector, the client/user can identify a set of objects.

A label selector can be made of multiple requirements which are comma-separated. In the case of multiple requirements, all must be satisfied so the comma separator acts as a logical `AND (&&)` operator.

> **Caution:**  
> For both equality-based and set-based conditions there is no logical OR (||) operator.

### Best Practice


| Key | Description | Example | Type |
|------|-------------|---------|------|
| app.kubernetes.io/name | The name of the application | mysql | string |
| app.kubernetes.io/instance | A unique name identifying the instance of an application | mysql-abcxyz | string |
| app.kubernetes.io/version | The current version of the application (e.g., a SemVer, revision hash, etc.) | 5.7.21 | string |
| app.kubernetes.io/component | The component within the architecture | database | string |
| app.kubernetes.io/part-of | The name of a higher level application this one is part of | wordpress | string |
| app.kubernetes.io/managed-by | The tool being used to manage the operation of an application | Helm | string |


```
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: mysql-abcxyz
    app.kubernetes.io/version: "5.7.21"
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
    app.kubernetes.io/managed-by: Helm
```
#### Types of selectors
There are two types of selectors
- Equality-based
- Set-based

##### Equality-based
Equality- or inequality-based requirements allow filtering by label keys and values.

Three kinds of operators are admitted =,==,!=

For example
```
kubectl get pods -l environment=production,tier=frontend
```
Above example shows that, get all the pods who has lable as environment=production and tier=frontend

##### Set-based
Set-based label requirements allow filtering keys according to a set of values. Three kinds of operators are supported: in,notin and exists

For example:
```environment in (production, qa)
tier notin (frontend, backend)
partition
!partition
```
the above example says

- The first example selects all resources with key equal to environment and value equal to production or qa.
- The second example selects all resources with key equal to tier and values other than frontend and backend, and all resources with no labels with the tier key.
- The third example selects all resources including a label with key partition; no values are checked.
- The fourth example selects all resources without a label with key partition; no values are checked.

```
kubectl get pods -l 'environment in (production),tier in (frontend)'
```

---
## Annotations

Annotations can be attached to resources as metadata. It is possible to use labels as well as annotations in the metadata of the same object

### Difference between Lables and Annotations
##### Lables
Labels can be used to select objects and to find collections of objects that satisfy certain conditions.

##### Annotations
In contrast, annotations are not used to identify and select objects. The metadata in an annotation can be small or large, structured or unstructured, and can include characters not permitted by labels.

### Use Cases
- Build, release, or image information like timestamps, release IDs, git branch, PR numbers, image hashes, and registry address.
- Phone numbers of persons responsible, or directory entries that specify where that information can be found, such as a team web site.

> **INOFRMATION:**  
> Syntax of annotation is same as of lables

---

## Field Selectors
Field selectors let you select Kubernetes objects based on the value of one or more resource fields.

For Example
```
kubectl get pods --field-selector status.phase=Running
```

### List of supported fields

| Kind      | Fields |
|------------|---------|
| Pod | `spec.nodeName`<br>`spec.restartPolicy`<br>`spec.schedulerName`<br>`spec.serviceAccountName`<br>`spec.hostNetwork`<br>`status.phase`<br>`status.podIP`<br>`status.podIPs`<br>`status.nominatedNodeName` |
| Event | `involvedObject.kind`<br>`involvedObject.namespace`<br>`involvedObject.name`<br>`involvedObject.uid`<br>`involvedObject.apiVersion`<br>`involvedObject.resourceVersion`<br>`involvedObject.fieldPath`<br>`reason`<br>`reportingComponent`<br>`source`<br>`type` |
| Secret | `type` |
| Namespace | `status.phase` |
| ReplicaSet | `status.replicas` |
| ReplicationController | `status.replicas` |
| Job | `status.successful` |
| Node | `status.unschedulable` |
| CertificateSigningRequest | `status.signerName` |

### Supported operators
You can use the =, ==, and != operators with field selectors (= and == mean the same thing).

### Chained selectors
As with label and other selectors, field selectors can be chained together as a comma-separated list.

For example
```
kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always
```
### Multiple resource types
You can use field selectors across multiple resource types.

For Example
```
kubectl get statefulsets,services --all-namespaces --field-selector metadata.namespace!=default
```

---
## Namespaces
In Kubernetes, namespaces provide a mechanism for isolating groups of resources within a single cluster. Names of resources need to be unique within a namespace, but not across namespaces. Namespace-based scoping is applicable only for namespaced objects (e.g. Deployments, Services, etc.) and not for cluster-wide objects (e.g. StorageClass, Nodes, PersistentVolumes, etc.).

> **Warning:**  
>Deleting namespace, will delete all the resources under it

---
## Finalizers
Finalizers are namespaced keys that tell Kubernetes to wait until specific conditions are met before it fully deletes resources that are marked for deletion. Finalizers alert controllers to clean up resources the deleted object owned.

---
## Owners and Dependents

In Kubernetes, some objects are owners of other objects. These owned objects are dependents of their owner.

For example, a ReplicaSet is the owner of a set of Pods.

Dependent objects have a metadata.ownerReferences field that references their owner object.
Kubernetes sets the value of this field automatically for objects that are dependents of other objects