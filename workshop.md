# Workshop for lifting and shifting ASP.NET applications to Kubernetes

## Preparation steps to run on Azure

1. Preallocate X static IP addresses
1. Precreate Y Kubernetes clusters
1. Define namespaces and users for all attendees, and distribute among the clusters
1. Assign the namespaces and users to attendees when they arrive

## Lab 1 - Intro to Windows Containers

Run a simple cmd in a Windows container

TODO: Instructions for connecting to a Windows VM using Microsoft Remote Desktop

### Windows

#### Exercise 1 - Run a Windows Server container on Windows Server 2019

If you are running on a Windows 10 or Windows Server Core Host, then all of the following commands will work.
> If you're running a VM on Azure, make sure it is a _v2 machine supporting nested virtualization

##### Install docker

If you do not already have Docker installed, go to the [Docker for Windows installation](https://hub.docker.com/editions/community/docker-ce-desktop-windows) and follow the instructions. May require a couple of reboots to enable docker and then HyperV.

Make sure that [Docker is set to run Windows containers](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers).

##### Check if it works

```cmd
# Run Windows Server Core as a Windows Container and obtain the Windows Build information via ver
C:\Users\username> docker run mcr.microsoft.com/windows/servercore:ltsc2019 cmd /c ver

# Run Windows Server Core as a Windows Container and obtain the Windows Build information via Powershell
C:\Users\username> docker run mcr.microsoft.com/windows/servercore:ltsc2019 powershell [environment]::OSVersion.Version

# Run Core as a Windows Container and launch interactive Powershell shell
C:\Users\username> docker run -it mcr.microsoft.com/windows/servercore:ltsc2019 powershell
```

##### Install az, git, and clone the repo

```powershell
# Install chocolatey
C:> @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install az
C:> choco install azure-cli

# Install git
C:> choco install git -params '"/GitAndUnixToolsOnPath"'

# Clone the workshop repository
C:> git clone https://github.com/craiglpeters/windows-containers-workshop.git
C:> cd windows-containers-workshop
```
##### Install kubectl

```cmd
C:\> mkdir C:\k
C:\> cd C:\k
C:\k> curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/windows/amd64/kubectl.exe
C:\k> set PATH=%PATH%;C:\k

# Install az
C:\> choco install azure-cli

# Get your kubeconf for access to your cluster replacing vars below
C:\> az aks get-credentials --resource-group <myResourceGroup> --name <myAKSCluster>

# Create a namespace for your pods
C:\> cd \fabrikamfiber
# edit k8s\namespace.yaml and replace<insert-your-name-here>
C:\fabrikamfiber\> kubectl apply -f k8s\namespace.yaml

# Set your namespace preference
kubectl config set-context $(kubectl config current-context) --namespace=<insert-your-name-here>
# Validate it
kubectl config view | grep namespace:
```

##### Create a pod spec for powershell, and use kubectl to run it
TO DO: write this part

## Lab 2 Package an ASP.NET app in a Docker image

```cmd
C:\fabrikamfiber\> rmdir /s /q MyCompany.Visitors.Web\bin\Release\Publish
C:\fabrikamfiber\> msbuild FabrikamFiber.CallCenter.sln /t:clean /p:Configuration=Release
C:\fabrikamfiber\> msbuild FabrikamFiber.CallCenter.sln /t:build /p:Configuration=Release /p:PublishProfile=FolderProfile /p:DeployOnBuild=true
C:\fabrikamfiber\> cd FabrikamFiber.Web
C:\fabrikamfiber\FabrikamFiber.Web\> docker build --no-cache -t ff .
C:\fabrikamfiber\FabrikamFiber.Web\> docker push <your registry>
```

## Lab 3 Run the ASP.NET app as a pod on a Kubernetes cluster and add a Linux ingress controller

### Running the application as a pod on Kubernetes

```bash
# configure the database authentication as a kubernetes secret
kubectl apply -n <insert-your-name-here> -f k8s/db-secret.yaml

# create the mssql on linux deployment
kubectl apply -n <insert-your-name-here> -f k8s/db-mssql-linux.yaml

# create the kubernetes service so the ASP.NET app can connect to the database
kubectl apply -n <insert-your-name-here> -f k8s/db-service.yaml

# deploy the APS.NET pods as a part of a deployment
kubectl apply -n <insert-your-name-here> -f k8s/fabrikamfiber.web-deployment.yaml

# edit k8s/fabrikamfiber.web-loadbalancer.yaml and append your name to the servicea

# then create the load balancer
kubectl apply -n <insert-your-name-here> -f k8s/fabrikamfiber.web-loadbalancer.yaml

# get the external IP for your service
kubectl get service -n <insert-your-name-here>

# Once the IP address is available, your can open a browser to connect to your ASP.NET app running in an container on a Windows node
```

### configure an NGNIX ingress controller running on Linux to route to your service for TLS

```bash
# edit k8s/fabrikamfiber.web-ingress.yaml to replace your service name

# configure the service so the client can connect to the pods running the ASP.NET app
kubectl apply -n ingress-basic -f k8s/fabrikamfiber.web-ingress.yaml

# get the URL to the ingress controller
kubectl describe ingress fabrikamfiber-ingress -n ingress-basic

# pick the URL from the 
```