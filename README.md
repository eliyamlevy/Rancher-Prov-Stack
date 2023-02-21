# Rancher-Prov-Stack
A collection of tools to provision rancher clusters easily

Please fill out the variables in the `variables.sh` file.
```
# aws creds
export TF_VAR_aws_region=
export TF_VAR_aws_access_key=
export TF_VAR_aws_secret_key=
# ec2
export TF_VAR_aws_prefix=
export TF_VAR_aws_key_name=
export TF_VAR_node_count=
# ssh info
export TF_VAR_ssh_private_key_path=
```

Also, if want to use a specific kubernetes version, you need to fill out the `kubernetes_version:` in the `cluster.yml.tpl` file
