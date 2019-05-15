#!/bin/bash

# create a namespace to deploy into
kubectl apply -f k8s/kubecon-demo-namespace.yaml

# configure the database authentication as a kubernetes secret
kubectl apply -n kubecon-demo -f k8s/db-secret.yaml

# create the mssql on linux deployment
kubectl apply -n kubecon-demo -f k8s/db-mssql-linux.yaml

# create the kubernetes service so the ASP.NET app can connect to the database
kubectl apply -n kubecon-demo -f k8s/db-service.yaml

# deploy the APS.NET pods as a part of a deployment
kubectl apply -n kubecon-demo -f k8s/fabrikamfiber.web-deployment.yaml

# configure the service so the client can connect to the pods running the ASP.NET app
kubectl apply -n kubecon-demo -f k8s/fabrikamfiber.web-ingress.yaml
