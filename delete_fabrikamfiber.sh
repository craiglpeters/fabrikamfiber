#!/bin/bash

# configure the database authentication as a kubernetes secret
kubectl delete -f k8s/db-secret.yaml -n $NAMESPACE 

# create the mssql on linux deployment
kubectl delete -f k8s/db-mssql-linux.yaml -n $NAMESPACE 

# create the kubernetes service so the ASP.NET app can connect to the database
kubectl delete -f k8s/db-service.yaml -n $NAMESPACE

# deploy the APS.NET pods as a part of a deployment
kubectl delete -f k8s/fabrikamfiber.web-deployment.yaml -n $NAMESPACE

# create a k8s load balancer for the ASP.NET pods
kubectl delete -f k8s/fabrikamfiver.web-loadbalancer.yaml -n $NAMESPACE

# configure the ingress cotroller service so the client can connect to the pods running the ASP.NET app
kubectl delete -f k8s/fabrikamfiber.web-ingress.yaml -n $NAMESPACE