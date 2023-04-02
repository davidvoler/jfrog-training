# Install Jfrog of minukube on a virtual machine #

## create the virtual machine ##
You can use virtualbox, virtual machine manager or any other virtualization software 

Download and install of Ubuntu server 20.04.0 or 22.04.0

After installing the server verify that you can ssh into it

### Requirements ###

The virtual server should have 
- 4 virtual CPUS recommended 8
- 8 GB memory - recommended 16 GB


## install Docker ##
```bash    
sudo apt-get install ca-certificates   curl gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

```
restart the server
```bash
sudo reboot
```

## install minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
alias kubectl="minikube kubectl -- "
```

Now, before running the minikube for the first time lets do some configuration
Use the entire resources you have on the machine 

```bash
minikube config set cpus=8
minikube config set memory 16000 #memory is in MB
```
please note that configuration do not apply to an existing minikube cluster and you have to delete and create the cluster for the setting to take place


Now lets start minikube

```bash
minikube start
```

lets enable the ingress addon on minikube

```bash
minikube addons enable ingress
```

Now remember that at any stage you can delete and recreate the minikube cluster

The delete command in 
```bash 
minikube delete
```


## Postgres installation ##  

We are going to create a single database server inside the kubernetes cluster.

After the server is created we are going to create multiple database inside this server 

```bash
cd postgres
kubectl applay -f 
```


## jfrog installation ## 
