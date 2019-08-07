# wordpressstack

## Base infrastructure deployment

The infrastructure is being deployed on AWS. To run the below infrastructure, IAM permissions are needed for atleast IAM, EC2, VPC, RDS and EKS. Also the "aws-iam-authenticator" and the "kubectl" binaries are required in the PATH (if the project is run on Linux, the "aws-iam-authenticator" and the "kubectl" binaries are automatically installed by the scripts)

* The AWS region "eu-west-1" is being used for this project. It can be changed by changing value of the "region" variable in the "terraform/variables.tf" file

* In the "terraform" directory, replace the <AWS_KEY> placeholder in the variables.tf file with the name of a valid AWS key (needed to launch worker nodes)
* From the directory "terraform", run

```
$ terraform init
$ terraform apply -auto-approve
```

What this does

* Creates a VPC
* Creates three public and three private subnets (along with route tables, gateways, etc) across multiple availability zones
* Creates three security groups and IAM permissions for the EKS cluster, RDS cluster and the Kubernetes worker nodes
* Creates a EKS cluster spanning multiple availability zones
* Creates a RDS cluster of the Aurora MySQL type spanning multiple availability zones
* Creates an Autoscaling group for worker nodes in one availability zone
* EKS endpoint is available publicly at port 443 but only via proper certificates

After the above command completes run the following scripts from the "terraform" directory

```
$ bash kube-general-conf.sh
```

What this does

* Downloads and installs the "aws-iam-authenticator" and "kubectl" binaries
* Sets the Kubernetes environment to run "kubectl" command by setting the KUBECONFIG env variable
* The default EKS gp2 storage class does not have a lot of options such as dynamic volume provisioning for cross zone deployment and volume expansion. The script deletes the default class and adds a new one with required parameters and sets it as default
* Adds the required roles for worker nodes to be accepted in the EKS cluster, also adds permissions for worker nodes to be able to launch ALBs
* Adds the RBAC roles for deploying the ALB ingress controller
* Deploys the ALB ingress controller

During this process the KUBECONFIG env variable is automatically added to the .bash_profile file in your HOME directory. However, if the "kubectl" command refuses to execute, run the below command,

```
export KUBECONFIG=$KUBECONFIG:/opt/kubeconfig
```

## Deploying Wordpress

### The DNS of the Application Load Balancer (ALB) will be used as the DNS of the Wordpress app in this project

All the following steps need to be executed from the "kubernetes" directory

* Run the following commands in sequence

```
$ kubectl apply -f namespace.yaml
```

**What it does** - Creates a namespace called "wordpress"

```
$ kubectl apply -f service.yaml
```

**What it does** - Creates a service in the "wordpress" namespace called wordpress

* Run the command "terraform output public_subnet_ids" in the "terraform" directory. This gives a list of public subnet IDs. Replace the <COMMA_SEPARATED_PUBLIC_SUBNETS> placeholder in the ingress.yaml file with the public subnet IDs separated by commas (e.g. subnet-xxxxxxxx,subnet-yyyyyyyy,subnet-zzzzzzzz)

```
$ kubectl apply -f ingress.yaml
```

**What it does** - Creates an ingress in the "wordpress" namespace which creates an ALB for public access

```
$ kubectl apply -f pvc.yaml
```

**What it does** - Creates a physical volume claim called "wordpress-pvc" in the "wordpress" namespace

```
$ kubectl apply -f secret.yaml
```

**What it does** - Creates a secret in the "wordpress" namespace called db-password

* Run the command "terraform output rds_db_endpoint" in the "terraform" directory. Replace the <WP_DB_HOST> placeholder in the deployment.yaml file with the output of the command (this is the RDS endpoint)
* By this time, the ingress has already created the ALB. Replace the <ALB_DNS> placeholders in the deployment.yaml file with the DNS of the ALB

```
$ kubectl apply -f deployment.yaml
```

**What it does** - Creates a deployment in the "wordpress" namespace called wordpress

After allowing the pods to come up and register with the load balancer, the DNS of the ALB can now be used to access Wordpress. After the Wordpress setup is completed, to test redundancy, the pod can be deleted and immediately a new pod will be launched to keep serving the app. If a worker node is terminated, the AWS autoscaling group will create a replacement which will automatically join the cluster as a worker node. RDS will keep the database data and the physical volume will keep the Wordpress data persistent

## Using HELM to deploy Wordpress

In the helm directory, there is a HELM chart called wpstack. The above deployment can also be done with this HELM chart. The values.yaml file in the chart directory needs to be populated with the required data and the chart needs to be pushed to a HELM repository. Then the following command needs to be run to deploy,

```
$ helm install HELM_REPOSITORY_NAME/wpstack --name wpstack --namespace wordpress
```

It should be noted that, if deployed via HELM, all the components get deployed automatically at the same time, so we cannot use the ALB DNS as the Wordpress DNS. In this case, a proper DNS should be used as the "wp_dns" in the values.yaml file

## Destroy the stack and infrastructure

* To terminate the Kubernetes components

```
$ kubectl delete ns/wordpress
```

* To terminate the AWS infrastructure

```
$ terraform destroy -auto-approve
```
