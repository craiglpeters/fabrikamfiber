#!/bin/bash

# configure the database authentication as a kubernetes secret
echo 'kubectl apply -n $NAMESPACE -f k8s/db-secret.yaml'
kubectl apply -n $NAMESPACE -f k8s/db-secret.yaml

# create the mssql on linux deployment
echo 'kubectl apply -n $NAMESPACE -f k8s/db-mssql-linux.yaml'
kubectl apply -n $NAMESPACE -f k8s/db-mssql-linux.yaml

# create the kubernetes service so the ASP.NET app can connect to the database
echo 'kubectl apply -n $NAMESPACE -f k8s/db-service.yaml'
kubectl apply -n $NAMESPACE -f k8s/db-service.yaml

# deploy the APS.NET pods as a part of a deployment
echo kubectl 'apply -n $NAMESPACE -f k8s/fabrikamfiber.web-deployment.yaml'
kubectl apply -n $NAMESPACE -f k8s/fabrikamfiber.web-deployment.yaml

# create a k8s load balancer for the ASP.NET pods
echo 'kubectl apply -n $NAMESPACE -f k8s/fabrikamfiber.web-loadbalancer.yaml'
kubectl apply -n $NAMESPACE -f k8s/fabrikamfiber.web-loadbalancer.yaml

# configure the ingress cotroller service so the client can connect to the pods running the ASP.NET app
echo 'kubectl apply -n ingress-basic -f k8s/fabrikamfiber.web-ingress.yaml'
kubectl apply -n ingress-basic -f k8s/fabrikamfiber.web-ingress.yaml
