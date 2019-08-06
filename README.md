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

## Deploying Wordpress

All the following steps need to be executed from the "kubernetes" directory

* Run the following commands in sequence

```
$ kubectl apply -f namespace.yaml
```

**What it does** - Creates a namespace called "wordpress"

```
$ kubectl apply -f secret.yaml
```

**What it does** - Creates a secret in the "wordpress" namespace called db-password

```
$ kubectl apply -f service.yaml
```

**What it does** - Creates a service in the "wordpress" namespace called wordpress

Replace the <WP_DB_HOST> placeholder in the deployment.yaml file with the output of the command "terraform output rds_db_endpoint" which needs to be run in the "terraform" directory

```
$ kubectl apply -f deployment.yaml
```

**What it does** - Creates a deployment in the "wordpress" namespace called wordpress

Run the command "terraform output public_subnet_ids" in the "terraform" directory. This gives a list of public subnet IDs. Replace the <COMMA_SEPARATED_PUBLIC_SUBNETS> placeholder in the ingress.yaml file with the public subnet IDs separated by commas

```
$ kubectl apply -f ingress.yaml
```

**What it does** - Creates an ingress in the "wordpress" namespace which creates an ALB for public access

The DNS of the ALB can now be used to access Wordpress. After the setup is completed, the pods can be deleted and immediately new pods will be launched to keep serving the app. If a worker node is terminated, the AWS autoscaling group will create a replacement which will automatically join the cluster as a worker node.

## Using HELM to deploy Wordpress

In the helm directory, there is a HELM chart called wpstack. The above deployment can also be done with this HELM chart. The values.yaml file in the chart directory needs to be populated with the required data and the chart needs to be pushed to a HELM repository. Then the following command needs to be run to deploy,

```
$ helm install HELM_REPOSITORY_NAME/wpstack --name wpstack --namespace wordpress
```
