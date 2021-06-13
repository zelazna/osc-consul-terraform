# Provision a Nomad cluster on Outscale

## Set the Credentials environment variables

```bash
$ export OUTSCALE_ACCESSKEYID=[OUTSCALE_ACCESSKEYID]
$ export OUTSCALE_SECRETKEYID=[OUTSCALE_SECRETKEYID]
```

## Build an AWS machine image with Packer

[Packer](https://www.packer.io/intro/index.html) is HashiCorp's open source tool 
for creating identical machine images for multiple platforms from a single 
source configuration. The Terraform templates included in this repo reference a 
publicly available Amazon machine image (AMI) by default. The AMI can be customized 
through modifications to the [build configuration script](../packer/scripts/setup.sh) 
and [template.pkr.hcl](template.pkr.hcl).

Use the following command to build the AMI:

```bash
$ packer build template.pkr.hcl
```

## Provision a cluster with Terraform

```bash
cd terraform
export TF_VAR_access_key_id=$OUTSCALE_ACCESSKEYID
export TF_VAR_secret_key_id=$OUTSCALE_SECRETKEYID
export TF_VAR_region="eu-west-2"
```

Update `terraform.tfvars` with your AMI ID if you created 
a custom AMI:

```bash
ami                     = "ami-09730698a875f6abd"
instance_type           = "t2.medium"
server_count            = "3"
client_count            = "4"
```

Modify the `instance_type`, `server_count`, and `client_count` variables
as appropriate. At least one client and one server are required. You can 
optionally replace the Nomad binary at runtime by adding the `nomad_binary` 
variable like so:

```bash
ami                     = "ami-09730698a875f6abd"
instance_type           = "t2.medium"
server_count            = "3"
client_count            = "4"
nomad_binary            = "https://releases.hashicorp.com/nomad/0.7.0/nomad_0.7.0_linux_amd64.zip"
```

Provision the cluster:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Access the cluster

SSH to the bastion using its public IP:

```bash
$ ssh -i /path/to/private/key outscale@PUBLIC_IP
```

The infrastructure that is provisioned for this test environment is configured to 
allow all traffic over port 22. This is obviously not recommended for production 
deployments.
