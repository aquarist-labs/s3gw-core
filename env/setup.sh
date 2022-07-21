#!/bin/sh

set -e

export PROV_USER=${PROV_USER:-"vagrant"}
export BOX_NAME=${BOX_NAME:-"opensuse/Leap-15.3.x86_64"}
export VM_PROVIDER=${VM_PROVIDER:-"libvirt"}
export VM_NET=${VM_NET:-"10.46.201.0"}
export VM_NET_LAST_OCTET_START=${CLUSTER_NET_LAST_OCTET_START:-"101"}
export VM_BRIDGE_INET=${VM_BRIDGE_INET:-"eth0"}
export ADMIN_COUNT=${ADMIN_COUNT:-"1"}
export WORKER_COUNT=${WORKER_COUNT:-"1"}
export ADMIN_MEM=${ADMIN_MEM:-"4096"}
export ADMIN_CPU=${ADMIN_CPU:-"2"}
export ADMIN_DISK=${ADMIN_DISK:-"no"}
export ADMIN_DISK_SIZE=${ADMIN_DISK_SIZE:-"8G"}
export WORKER_MEM=${WORKER_MEM:-"4096"}
export WORKER_CPU=${WORKER_CPU:-"2"}
export WORKER_DISK=${WORKER_DISK:-"no"}
export WORKER_DISK_SIZE=${WORKER_DISK_SIZE:-"8G"}
export STOP_AFTER_BOOTSTRAP=${STOP_AFTER_BOOTSTRAP:-"no"}
export STOP_AFTER_K3S_INSTALL=${STOP_AFTER_K3S_INSTALL:-"no"}
export IMG_REG=${IMG_REG:-"ghcr.io/aquarist-labs"}
export IMG_NAME=${IMG_NAME:-"s3gw"}
export IMG_TAG=${IMG_TAG:-"latest"}
export IMG_PULL_POLICY=${IMG_PULL_POLICY:-"Always"}
export UI_IMG_REG_PUSH=${UI_IMG_REG_PUSH:-"admin-1:5000"}
export UI_IMG_REG_PULL=${UI_IMG_REG_PULL:-"admin-1.local"}
export UI_IMG_NAME=${UI_IMG_NAME:-"s3gw-ui"}
export UI_IMG_TAG=${UI_IMG_TAG:-"latest"}
export UI_IMG_PULL_POLICY=${UI_IMG_PULL_POLICY:-"Always"}

#these defaults will change
export UI_REPO=${UI_REPO:-"https://github.com/aquarist-labs/aws-s3-explorer.git"}
export UI_REPO_BRANCH=${UI_REPO_BRANCH:-"s3gw-ui-testing"}

export SCENARIO=${SCENARIO:-""}
export K3S_VERSION=${K3S_VERSION:-"v1.23.6+k3s1"}

start_env() {
  echo "Starting environment ..."
  echo "WORKER_COUNT=${WORKER_COUNT}"
  vagrant up
}

build_env() {
  echo "PROV_USER=${PROV_USER}"
  echo "BOX_NAME=${BOX_NAME}"
  echo "VM_PROVIDER=${VM_PROVIDER}"
  echo "VM_NET=${VM_NET}"
  echo "VM_NET_LAST_OCTET_START=${VM_NET_LAST_OCTET_START}"
  echo "VM_BRIDGE_INET=${VM_BRIDGE_INET}"
  echo "ADMIN_COUNT=${ADMIN_COUNT}"
  echo "WORKER_COUNT=${WORKER_COUNT}"
  echo "ADMIN_MEM=${ADMIN_MEM}"
  echo "ADMIN_CPU=${ADMIN_CPU}"
  echo "ADMIN_DISK=${ADMIN_DISK}"
  echo "ADMIN_DISK_SIZE=${ADMIN_DISK_SIZE}"
  echo "WORKER_MEM=${WORKER_MEM}"
  echo "WORKER_CPU=${WORKER_CPU}"
  echo "WORKER_DISK=${WORKER_DISK}"
  echo "WORKER_DISK_SIZE=${WORKER_DISK_SIZE}"
  echo "STOP_AFTER_BOOTSTRAP=${STOP_AFTER_BOOTSTRAP}"
  echo "STOP_AFTER_K3S_INSTALL=${STOP_AFTER_K3S_INSTALL}"
  echo "IMG_REG=${IMG_REG}"
  echo "IMG_NAME=${IMG_NAME}"
  echo "IMG_TAG=${IMG_TAG}"
  echo "IMG_PULL_POLICY=${IMG_PULL_POLICY}"
  echo "UI_IMG_REG_PUSH=${UI_IMG_REG_PUSH}"
  echo "UI_IMG_REG_PULL=${UI_IMG_REG_PULL}"
  echo "UI_IMG_NAME=${UI_IMG_NAME}"
  echo "UI_IMG_TAG=${UI_IMG_TAG}"
  echo "UI_IMG_PULL_POLICY=${UI_IMG_PULL_POLICY}"
  echo "UI_REPO=${UI_REPO}"
  echo "UI_REPO_BRANCH=${UI_REPO_BRANCH}"
  echo "SCENARIO=${SCENARIO}"
  echo "K3S_VERSION=${K3S_VERSION}"

  echo "Building environment ..."
  vagrant up --provision
  echo "Built"

  echo "Cleaning ..."
  rm -rf ./*.tar
  echo "Cleaned"
  echo
  echo "Connect to admin node with:"
  echo "vagrant ssh admin-1"
}

destroy_env() {
  echo "Destroying environment ..."
  echo "WORKER_COUNT=${WORKER_COUNT}"
  vagrant destroy -f
}

ssh_vm() {
  echo "Connecting to $1 ..."
  echo "WORKER_COUNT=${WORKER_COUNT}"

  vagrant ssh $1
}

if [ $# -eq 0 ]; then
  build_env
elif [ $# -eq 1 ]; then
  case $1 in
    start)
      start_env
      ;;
    build)
      build_env
      ;;
    destroy)
      destroy_env
      ;;
  esac
else
  case $1 in
    ssh)
      ssh_vm $2
      ;;
  esac
fi

exit 0
