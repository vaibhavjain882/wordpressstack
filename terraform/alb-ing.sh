#!/bin/bash

kubectl apply -f /opt/alb_ing_rbac.yaml
kubectl apply -f /opt/albingcontroller.yaml
