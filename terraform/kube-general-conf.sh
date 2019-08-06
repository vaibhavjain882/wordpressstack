#!/bin/bash

curl -o /usr/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.9/2019-06-21/bin/linux/amd64/kubectl
curl -o /usr/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator

chmod +x /usr/bin/kubectl /usr/bin/aws-iam-authenticator

terraform output storage_class_custom_gp2 > /opt/storage_class_custom_gp2.yaml
terraform output kubeconfig > /opt/kubeconfig
terraform output albingcontroller > /opt/albingcontroller.yaml
terraform output alb_ing_rbac > /opt/alb_ing_rbac.yaml
terraform output config_map_aws_auth > /opt/config_map_aws_auth.yaml

export KUBECONFIG=$KUBECONFIG:/opt/kubeconfig

kubectl delete sc/gp2
kubectl apply -f /opt/storage_class_custom_gp2.yaml
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl apply -f /opt/config_map_aws_auth.yaml

echo "export KUBECONFIG=$KUBECONFIG:/opt/kubeconfig" >> ~/.bash_profile
