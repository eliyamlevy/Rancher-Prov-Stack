# set path to ssh private key so we can ssh into each node for provisioning. If aws ec2 should point to your aws public key
ssh_key_path: ${ssh_private_key_path}

# kubernetes_version is not required can leave blank or comment out and will use latest
kubernetes_version: 

# list of nodes including internal addresses is strongly recommended. user must be set to ubuntu for example for ubuntu ec2 instances for ssh access.
# if your AWS AMI is not ubuntu like centos, rocky linux, etc the username is usually (but not always) ec2-user
# role must be defined - here we specify all three roles per each node. However technically minimums just are: etcd 3 nodes, controlplane 2 nodes, worker 2 nodes for minimal fault tolerance

nodes:
  - address: ${instance1_ext}
    internal_address: ${instance1_int}
    user: ubuntu
    role: [etcd, controlplane, worker]
  - address: ${instance2_ext}
    internal_address: ${instance2_int}
    user: ubuntu
    role: [etcd, controlplane, worker]
  - address: ${instance3_ext}
    internal_address: ${instance3_int}
    user: ubuntu
    role: [etcd, controlplane, worker]
