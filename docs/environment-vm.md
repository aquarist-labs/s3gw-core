# s3gw/Longhorn on Virtual Machines

Follow this guide if you wish to setup a K3s cluster running s3gw/Longhorn on virtual machines.  

## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Building the environment](#building-the-environment)
* [Destroying the environment](#destroying-the-environment)
* [Starting the environment](#starting-the-environment)
* [Accessing the environment](#accessing-the-environment)
  * [ssh](#ssh)
* [Access the Longhorn UI](#access-the-longhorn-ui)
* [Access the S3 API](#access-the-s3-api)
* [Configure s3gw as Longhorn backup target](#configure-s3gw-as-longhorn-backup-target)
* [Ingresses](#ingresses)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->

## Description

The entire environment build process is automated by a set of Ansible playbooks.  
The cluster is created with exactly one `admin` node and
an arbitrary number of `worker` nodes.  
A single virtual machine acting as an `admin` node is also possible; in this case, it
will be able to schedule pods as a `worker` node.  
Name topology for nodes is the following:

```text
admin
worker-1
worker-2
...
```

## Requirements

Make sure you have installed the following applications on your system:

* Vagrant
* libvirt
* Ansible

## Building the environment

You can build the environment with the `setup.sh` script.  
The simplest form you can use is:  

```bash
cd ~/git/s3gw-core/env
$ ./setup.sh build
Building environment ...
```

This will trigger the build of a Kubernetes cluster formed by one node `admin`
and one node `worker`.  
You can customize the build with the following environment variables:

```text
PROV_USER                   : The user used by Ansible (vagrant default)
BOX_NAME                    : The Vagrant box image used in the cluster (default: opensuse/Leap-15.3.x86_64)
VM_NET                      : The virtual machine subnet used in the cluster
VM_NET_LAST_OCTET_START     : Vagrant will increment this value when creating vm(s) and assigning an ip
K3S_VERSION                 : The K3s version to be used (default: v1.23.6+k3s1)
WORKER_COUNT                : The number of Kubernetes node in the cluster
ADMIN_MEM                   : The RAM amount used by the admin node (Vagrant format)
ADMIN_CPU                   : The CPU amount used by the admin node (Vagrant format)
ADMIN_DISK                  : yes/no, when yes a disk will be allocated for the admin node - this will be effective only for mono clusters
ADMIN_DISK_SIZE             : The disk size allocated for the admin node (Vagrant format) - this will be effective only for mono clusters
WORKER_MEM                  : The RAM amount used by a worker node (Vagrant format)
WORKER_CPU                  : The CPU amount used by a worker node (Vagrant format)
WORKER_DISK                 : yes/no, when yes a disk will be allocated for the worker node
WORKER_DISK_SIZE            : The disk size allocated for a worker node (Vagrant format)
STOP_AFTER_BOOTSTRAP        : yes/no, when yes stop just after bootstrap
STOP_AFTER_K3S_INSTALL      : yes/no, when yes stop just after install k3s
IMG_REG                     : s3gw's image registry
IMG_NAME                    : s3gw's image name
IMG_TAG                     : s3gw's image tag
IMG_PULL_POLICY             : s3gw's image pull policy
UI_IMG_REG_PUSH             : s3gw-ui's image registry, url used when pushing
UI_IMG_REG_PULL             : s3gw-ui's image registry, url used when pulling
UI_IMG_NAME                 : s3gw-ui's image name
UI_IMG_TAG                  : s3gw-ui's image tag
UI_IMG_PULL_POLICY          : s3gw-ui's image pull policy
UI_REPO                     : A git repository to be used when building the s3gw-ui's image
UI_REPO_BRANCH              : A UI_REPO's branch to be used
SCENARIO                    : An optional scenario to be loaded in the cluster
```

So, you could start a more specialized build with:

```bash
cd ~/git/s3gw-core/env
$ IMAGE_NAME=generic/ubuntu1804 WORKER_COUNT=4 ./setup.sh build
Building environment ...
```

You create a mono virtual machine cluster with the lone `admin` node with:

```bash
cd ~/git/s3gw-core/env
$ WORKER_COUNT=0 ./setup.sh build
Building environment ...
```

In this case, the node will be able to schedule pods as a `worker` node.  

## Destroying the environment

You can destroy a previously built environment with:

```bash
cd ~/git/s3gw-core/env
$ ./setup.sh destroy
Destroying environment ...
```

Be sure to match the `WORKER_COUNT` value with the one you used in the build phase.  
Providing a lower value instead of the actual one will cause some allocated vm not
to be released by Vagrant.

## Starting the environment

You can start a previously built environment with:

```bash
cd ~/git/s3gw-core/env
$ ./setup.sh start
Starting environment ...
```

Be sure to match the `WORKER_COUNT` value with the one you used in the build phase.  
Providing a lower value instead of the actual one will cause some allocated vm not
to start.

## Accessing the environment

### ssh

You can connect through `ssh` to all nodes in the cluster.  
To connect to the `admin` node run:

```bash
cd ~/git/s3gw-core/env
$ ./setup.sh ssh admin
Connecting to admin ...
```

To connect to a `worker` node run:

```bash
cd ~/git/s3gw-core/env
$ ./setup.sh ssh worker-2
Connecting to worker-2 ...
```

When connecting to a worker node be sure to match the `WORKER_COUNT`
value with the one you used in the build phase.

## Access the Longhorn UI

The Longhorn UI can be access via the URL `http://longhorn.local`.

## Access the S3 API

The S3 API can be accessed via `http://s3gw.local`.

We provide a [s3cmd](https://github.com/s3tools/s3cmd) configuration file
to easily communicate with the S3 gateway in the k3s cluster.

```bash
cd ~/git/s3gw-core/env
s3cmd -c ./s3cmd.cfg mb s3://foo
s3cmd -c ./s3cmd.cfg ls s3://
```

Please adapt the `host_base` and `host_bucket` properties in the `s3cmd.cfg`
configuration file if your K3s cluster is not accessible via localhost.

## Configure s3gw as Longhorn backup target

Use the following values in the Longhorn settings page to use the s3gw as
backup target.

Backup Target: `s3://<BUCKET_NAME>@us/`  
Backup Target Credential Secret: `s3gw-secret`

## Ingresses

Services are exposed with an Kubernetes ingress; each service category is
allocated on a separate virtual host:

* **Longhorn dashboard**, on: `longhorn.local`
* **s3gw**, on: `s3gw.local` and `no-tls-s3gw.local`
* **s3gw UI**, on: `ui-s3gw.local` and `no-tls-ui-s3gw.local`

Host names are exposed with a node port service listening on ports
30443 (https) and 30080 (http).  
You are required to resolve these names with the external ip of one
of the nodes of the cluster.  

You can patch host's `/etc/hosts` file as follow:  

```text
VM-IP   longhorn.local s3gw.local no-tls-s3gw.local ui-s3gw.local no-tls-ui-s3gw.local
```

Services can now be accessed at:

```text
https://longhorn.local:30443
https://s3gw.local:30443
http://no-tls-s3gw.local:30080
https://ui-s3gw.local:30443
http://no-tls-ui-s3gw.local:30080
```
