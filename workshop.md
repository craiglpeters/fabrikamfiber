# Workshop for lifting and shifting ASP.NET applications to Kubernetes

## Preparation steps to run on Azure

1. Let participants know that they should prepare a Windows 10 dev machine with Docker (with Windows containers enabled) and
1. Docker run both docker run mcr.microsoft.com/windows/servercore:ltsc2019 and mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2019 to download the images from a faster (than a workshop location) network
1. Preallocate a static IP address
1. Precreate Kubernetes clusters with a Windows nodepool
1. Taint the Windows nodes

## Lab 1 - Intro to Windows Containers

Run a simple cmd in a Windows container

TODO: For Mac - instructions for connecting to a Windows VM using Microsoft Remote Desktop

If you are running on a Windows 10 or Windows Server Core Host, then all of the following commands will work.
> If you're running a VM on Azure, make sure it is a _v2 machine supporting nested virtualization

### Install docker

If you do not already have Docker installed, go to the [Docker for Windows installation](https://hub.docker.com/editions/community/docker-ce-desktop-windows) and follow the instructions. May require a couple of reboots to enable docker and then HyperV.

> Make sure that [Docker is set to run Windows containers](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers). If this isn't set correctly you'll see an error on docker pull or run of Windows containers that the correct manifest can't be found

### Check if it works

```cmd
# Run Windows Server Core as a Windows Container and obtain the Windows Build information via ver
C:\Users\username\> docker run mcr.microsoft.com/windows/servercore:ltsc2019 cmd /c ver

# Run Windows Server Core as a Windows Container and obtain the Windows Build information via Powershell
C:\Users\username\> docker run mcr.microsoft.com/windows/servercore:ltsc2019 powershell [environment]::OSVersion.Version

# Run Core as a Windows Container and launch interactive Powershell shell
C:\Users\username\> docker run -it mcr.microsoft.com/windows/servercore:ltsc2019 powershell
```

### Install az, git, and clone the repo

```powershell
# Install chocolatey
C:> @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install az
C:\> choco install azure-cli

# Install git
C:\> choco install git -params '"/GitAndUnixToolsOnPath"'

# Clone the workshop repository
C:\> git clone https://github.com/craiglpeters/fabrikamfiber.git
C:\> cd windows-containers-workshop
```
### Install kubectl, get connected to the cluster, and set your namespace

```cmd
C:\> mkdir C:\k
C:\> cd C:\k
C:\k> curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/windows/amd64/kubectl.exe
C:\k> set PATH=%PATH%;C:\k

# Get your kubeconfig from your instructor, or if you have an Azure account follow the instructions in the [AKS docs](https://docs.microsoft.com/en-us/azure/aks/windows-container-cli) to create an AKS cluster with a Windows nodepool
C:\> az aks get-credentials --resource-group <myResourceGroup> --name <myAKSCluster>
```

### Check out the nodes - there are Windows and Linux nodes in the cluster
```cmd
# List the nodes
C:\k\> kubectl get nodes -o wide

# Examine the taints on the Windows nodes
C:\k\> kubectl describe node <insert-a-windows-node-name-here>
```

## Lab 2 Package an ASP.NET app in a Docker image

```cmd
C:\fabrikamfiber\> msbuild FabrikamFiber.CallCenter.sln /t:clean /p:Configuration=Release
C:\fabrikamfiber\> msbuild FabrikamFiber.CallCenter.sln /t:build /p:Configuration=Release /p:PublishProfile=FolderProfile /p:DeployOnBuild=true
C:\fabrikamfiber\> cd FabrikamFiber.Web
C:\fabrikamfiber\FabrikamFiber.Web\> docker build --no-cache -t ff .
```
> For brevity, lets skip pushing the Docker image to a registry and use a pre-pushed image. Optionally, you may do those steps if you have time and a registry available. Just be sure to update the image in the deployment below.

## Lab 3 Run the ASP.NET app as a pod on a Kubernetes cluster and add a Linux ingress controller

### Running the ASP.NET application as a pod on Kubernetes

```cmd
# Create a namespace for your pods
C:\> cd \fabrikamfiber
# edit k8s\namespace.yaml and replace<insert-your-name-here>
C:\fabrikamfiber\> kubectl apply -f k8s\namespace.yaml

# Set your namespace preference
kubectl config set-context $(kubectl config current-context) --namespace=<insert-your-name-here>
# Validate it
kubectl config view | grep namespace:

# configure the database authentication as a kubernetes secret
kubectl apply -f k8s/db-secret.yaml

# create the mssql on linux deployment
kubectl apply -f k8s/db-mssql-linux.yaml

# create the kubernetes service so the ASP.NET app can connect to the database
kubectl apply -f k8s/db-service.yaml

# deploy the APS.NET pods as a part of a deployment
kubectl apply -f k8s/fabrikamfiber.web-deployment.yaml

# create a load balancer
kubectl apply -f k8s/fabrikamfiber.web-loadbalancer.yaml

# get the external IP for your service
kubectl get service

# Once the IP address is available, your can open a browser to connect to your ASP.NET app running in an container on a Windows node
```
You  are now running an ASP.NET application in a Kubernetes managed pod on a Windows node!

### configure an NGNIX ingress controller running on Linux to route to your service for TLS

Edit k8s/fabrikamfiber.web-ingress.yaml and update the backend with your service name like fabrikamfiber.<insert-your-name-here>.service.cluster.local

```bash
# configure the service so the client can connect to the pods running the ASP.NET app
kubectl apply -n <insert-your-name-here> -f k8s/fabrikamfiber.web-ingress.yaml

# get the URL to the ingress controller
kubectl describe ingress fabrikamfiber-ingress -n ingress-basic 
```

Now  open a browser to the TLS terminated host and append your path. This is your Windows app running in container orchestrated by Kubernetes to run a Windows node, being fronted by an NGNIX ingress controller running on a Linux node.