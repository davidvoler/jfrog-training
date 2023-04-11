# Install Jfrog of minukube on a virtual machine #

## create the virtual machine ##
You can use virtualbox, virtual machine manager or any other virtualization software 

Download and install of Ubuntu server 20.04.0 or 22.04.0

After installing the server verify that you can ssh into it

### Requirements ###

The virtual server should have 
- 4 virtual CPUS recommended 8
- 8 GB memory - recommended 16 GB


## 1.0 install Docker ##
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

## 2.0 install minikube ##

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

#### 2.1 create minikube cluster ####
Now lets start minikube

```bash
minikube start
```

lets enable the ingress addon on minikube

```bash
minikube addons enable ingress
```

### 2.2 install helm ###

```bash
sudo snap install helm --classic 
```

### 3.0 install virtualenvwrapper ###

```bash
pip install --user  virtualenvwrapper
```


add the following lines to the end of ~/.bashrc
```bash 
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source $HOME/.local/bin/virtualenvwrapper.sh

```
run the following commands to create a virtualenv 
```bash 
source $HOME/.bashrc
mkvirtualenv jfrog
workon jfrog
```


### 4.0 jfrog utilities ###

```bash 
mkdir dev
cd dev
git clone  git@github.com:devops-sherpas/jfrog-utils.git
git clone  git@github.com:devops-sherpas/jfrog-lib.git

pip install -e jfrog-lib/
pip install -e jfrog-utils/
```


### 5.0 Postgres installation ###  

We are going to create a single database server inside the kubernetes cluster.

After the server is created we are going to create multiple database inside this server 

```bash
cd postgres
kubectl apply -f config.yaml
kubectl apply -f volume.yaml
kubectl apply -f service.yaml
kubectl apply -f postgres.yaml
```


now we should get the pod in which postgres is running and we are going to create the databases
 - ~2 minutes wait  
```bash
kubectl get pods
```

you will get a database named postgres-xxxxx-sss (with some random string and numbers)

```bash
kubectl exec -it postgres-XXXXX-SSS bash
su postgres
#create the databases
createdb artifactory           
createdb artifactory-asia      
createdb artifactory-europe    
createdb distribution          
createdb insights              
createdb platform-artifactory  
createdb platform-distribution 
createdb platform-insights     
createdb platform-xray         
createdb xray                  


#review the list of created databases
psql
\l
#you should get the list of created databases

#to exit 
\q
exit 
exit
```

### 6.0 hosts ###

VM_IP = the ip of the virtual machine oyu have created 

to get the vm ip 
```bash 
ip addr
```


On the host computer add the following to /etc/hosts

```bash
VM_IP artifactory.localhost artifactory-docker.localhost asia.localhost europe.localhost

```

to get the minikube ip (the default is 192.168.49.2)

```bash
minikube ip
```

### 7.0 jfrog installation ### 

```bash 
cd k8s 
```
follow the instructions in  k8s/README.md 


### 8.0 restarting the process - delete the minikube cluster ###

Now remember that at any stage you can delete and recreate the minikube cluster


The delete command in 
```bash 
minikube delete
```

Now you can start from stage  2.1



### 9.0 cleanup ###

The easiest way to clean up is simply deleting the virtual machine with all its file 

You would also want to delete the changes to /etc/hosts on the host machine 




### experiments ###
https://jfrog.com/artifactory/install/

docker volume create artifactory-data
docker pull releases-docker.jfrog.io/jfrog/artifactory-pro:latest
docker run -d --name artifactory -p 8082:8082 -p 8081:8081 -v artifactory-data:/var/opt/jfrog/artifactory releases-docker.jfrog.io/jfrog/artifactory-pro:latest

the ip is: 192.168.122.25

/etc/docker/daemon
{
  "insecure-registries" : ["192.168.122.25:8082"]     
}

sudo service docker restart

docker login 192.168.122.25:8082
docker tag nginx:latest 192.168.122.25:8082/docker-local/nginx:latest
docker push 192.168.122.25:8082/docker-local/nginx:latest




cmVmdGtuOjAxOjE3MTI3Mzc0NzE6TThDaFdCcWpxa2dNNTdpb21KUkxlSU9iTkVZ


85 admin
cmVmdGtuOjAxOjE3MTI3NTM2NzM6dEdJSWNiVXBsYXpjaEJiSW5IdWlmWXAzUmtH