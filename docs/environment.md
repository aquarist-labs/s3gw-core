# Running s3gw/Longhorn

## s3gw/Longhorn on Virtual Machines

[s3gw/Longhorn on virtual machines](./environment-vm.md)

## s3gw/Longhorn on Bare Metal

* [Note Before](#note-before)
* [K3s Installation](#k3s-installation)
* [Longhorn Deploy](#longhorn-deploy)
* [s3gw Deploy](#s3gw-deploy)
* [Access the Longhorn UI](#access-the-longhorn-ui)
* [Access the S3 API](#access-the-s3-api)
* [Configure s3gw as Longhorn backup target](#configure-s3gw-as-longhorn-backup-target)
* [Ingresses](#ingresses)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->

## Note Before

In some host systems, including OpenSUSE Tumbleweed, one will need to disable
firewalld to ensure proper functioning of k3s and its pods:

```shell
sudo systemctl stop firewalld.service
```

## K3s Installation

Install k3s from the internet, by running

```shell
curl -sfL https://get.k3s.io | sh -
```

## Longhorn Deploy

Deploy Longhorn from the internet, by running

```shell
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.2.4/deploy/prerequisite/longhorn-iscsi-installation.yaml
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.2.4/deploy/longhorn.yaml
```

## s3gw Deploy

Follow the instructions at [s3gw-charts](https://github.com/aquarist-labs/s3gw-charts) repository to deploy s3gw with an Helm chart.

## Access the Longhorn UI

The Longhorn UI can be access via the URL `http://longhorn.local`.

## Access the S3 API

The S3 API can be accessed via `http://s3gw.local`.

We provide a [s3cmd](https://github.com/s3tools/s3cmd) configuration file
to easily communicate with the S3 gateway in the k3s cluster.

```shell
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

* **s3gw**, on: `s3gw.local` and `no-tls-s3gw.local`
* **s3gw UI**, on: `ui-s3gw.local` and `no-tls-ui-s3gw.local`

Host names are exposed with a node port service listening on ports
30443 (https) and 30080 (http).  
You are required to resolve these names with the external ip of one
of the nodes of the cluster.  

You can patch host's `/etc/hosts` file as follow:  

```text
YOUR-HOST-IP   s3gw.local no-tls-s3gw.local ui-s3gw.local no-tls-ui-s3gw.local
```

Services can now be accessed at:

```text
https://s3gw.local:30443
http://no-tls-s3gw.local:30080
https://ui-s3gw.local:30443
http://no-tls-ui-s3gw.local:30080
```
