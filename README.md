# wordpressstack

## Base infrastructure deployment

The infrastructure is being deployed on AWS. To run the below infrastructure, IAM permissions are needed for atleast IAM, EC2, VPC, RDS and EKS. Also the "aws-iam-authenticator" and the "kubectl" binaries are required in the PATH (if the project is run on Linux, the "aws-iam-authenticator" and the "kubectl" binaries are automatically installed by the scripts)

From the directory "terraform", run

```
$ terraform apply -auto-approve
```

What this does

* Creates a VPC
* Creates three public and three private subnets (along with route tables, gateways, etc) across multiple availability zones
* Creates three security groups and IAM permissions for the EKS cluster, RDS cluster and the Kubernetes worker nodes
* Creates a EKS cluster spanning multiple availability zones
* Creates a RDS cluster of the Aurora MySQL type spanning multiple availability zones
* Creates an Autoscaling group for worker nodes across multiple availability zones
* EKS endpoint is available publicly at port 443 but only via proper certificates

After the above command completes run the following scripts from the "terraform" directory

```
$ bash kube-general-conf.sh
```

What this does

* Downloads and installs the "aws-iam-authenticator" and "kubectl" binaries
* Sets the Kubernetes environment to run "kubectl" command by setting the KUBECONFIG env variable
* The default EKS gp2 storage class does not have a lot of options such as dynamic volume provisioning for cross zone deployment and volume expansion. The script deletes the default class and adds a new one with required parameters and sets it as default
* Adds the required roles for worker nodes to be accepted in the EKS cluster

After the above command completes perform the following from the "terraform" directory

* In the file "terraform/alb_ing.tf", for the "albingcontroller" local, the values for AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY needs to be set for the controller to be able to deploy load balancers. Replace the placeholders <AWS_ACCESS_KEY> and <AWS_SECRET_KEY> with the correct values. This can be avoided by running the ALB ingress controller on worker nodes with instance profile having the correct permissions
* The run the below command

```
$ bash alb-ing.sh (read the below lines before running this)
```

What this does

* Adds the RBAC roles for deploying the ALB ingress controller
* Deploys the ALB ingress controller

During this process the KUBECONFIG env variable is automatically added to the .bash_profile file in your HOME directory. However, if the "kubectl" command refuses to execute, run the below command,

```
export KUBECONFIG=$KUBECONFIG:/opt/kubeconfig
```
