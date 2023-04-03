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



### install virtualenvwrapper ###

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


### jfrog utilities ###

```bash 
mkdir dev
cd dev
git clone  git@github.com:devops-sherpas/jfrog-utils.git
git clone  git@github.com:devops-sherpas/jfrog-lib.git

pip install -e jfrog-lib/
pip install -e jfrog-utils/
```


## Postgres installation ##  

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

```bash
kubectl get pods
```

you will get a database named postgres-xxxxx-sss

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
```


## jfrog installation ## 


