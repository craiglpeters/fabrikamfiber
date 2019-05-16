#!/bin/bash

# delete the database authentication as a kubernetes secret
echo 'kubectl delete -f k8s/db-secret.yaml -n '$NAMESPACE
kubectl delete -f k8s/db-secret.yaml -n $NAMESPACE 

# delete the mssql on linux deployment
echo 'kubectl delete -f k8s/db-mssql-linux.yaml -n '$NAMESPACE
kubectl delete -f k8s/db-mssql-linux.yaml -n $NAMESPACE 

# delete the kubernetes service so the ASP.NET app can connect to the database
echo 'kubectl delete -f k8s/db-service.yaml -n '$NAMESPACE
kubectl delete -f k8s/db-service.yaml -n $NAMESPACE

# delete the APS.NET pods as a part of a deployment
echo 'kubectl delete -f k8s/fabrikamfiber.web-deployment.yaml -n '$NAMESPACE
kubectl delete -f k8s/fabrikamfiber.web-deployment.yaml -n $NAMESPACE

# delete a k8s load balancer for the ASP.NET pods
echo 'kubectl delete -f k8s/fabrikamfiber.web-loadbalancer.yaml -n '$NAMESPACE
kubectl delete -f k8s/fabrikamfiber.web-loadbalancer.yaml -n $NAMESPACE

# delete the ingress controller configuration
echo 'kubectl delete -f k8s/fabrikamfiber.web-ingress.yaml -n ingress-basic'
kubectl delete -f k8s/fabrikamfiber.web-ingress.yaml -n ingress-basic 