#!/bin/bash

export KUBECONFIG=$KUBECONFIG:/opt/kubeconfig

kubectl apply -f /opt/alb_ing_rbac.yaml
kubectl apply -f /opt/albingcontroller.yaml
