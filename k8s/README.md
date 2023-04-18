  
7. Add JFrog's helm repo

```bash
helm repo add jfrog https://charts.jfrog.io/
```

8. Create a secret to contain the join key:

```bash
kubectl create secret generic join-key --from-literal=join-key=044c6240e62129e75d5ef9def656d992
```

9. Install Artifactory

```bash
helm upgrade --install artifactory -f artifactory-values.yaml jfrog/artifactory
```

run the following command to get an ip for the minikube ingress - open a new terminal or a terminal tab and leave it open 
The command will require a sudo password
```bash
minikube tunnel
```
now run the following command to get the IP of the artifactory

```bash
kubectl get svc
```
you will get results that look something like this:

NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
artifactory                     ClusterIP      10.99.16.151     <none>          8082/TCP,8081/TCP            5m8s
artifactory-artifactory-nginx   LoadBalancer   10.108.123.98    10.108.123.98   80:31135/TCP,443:30665/TCP   5m8s

you need this external ip of the artifactory-artifactory-nginx 


From now on, you can access artifactory via http://ARTIFACTORY_NGINX_IP:80

10. Launch the Artifactory UI (default password: `password`) and complete the basic installation and configuration:

a. You will be forced to change your password. Take note of it, this is the Artifactory administration password.

b. Set the custom base url, using the NGINX svc name (otherwise access federation setup fails, as well as federated repositories).
    To get the service name, use `kubectl get svc`. Normally, this would be `artifactory-artifactory-nginx` and the port
    will be `81`. So the URL should be `http://artifactory-artifactory-nginx:81`.

c. Upload the license buckets (see the `licenses` directory in the root of this repository):

    i. The `eplus.json` bucket file should be uploaded with the name `main` and with the unlock code located in `eplus.txt`

    ii. The `edge.json` bucket file should be uploaded with the name `edge` and with the unlock code located in `edge.txt`

d. Create an access token for yourself: open the user menu (top right), "Edit Profile", then generate an identity token
    and copy it to the clipboard.

e. Edit the DevOps Sherpas CLI config file. Under `local`, modify the `password` to contain your new password, and
    modify the `token` to contain your identity token.
f. get the url for the service on the virtual machine 


```bash 
minikube service artifactory-artifactory-nginx
```


```bash
mkdir ~/.dosjfrog/
nano ~/.dosjfrog/config.yaml
```

copy the following content into the file:
exposevm/default.example.conf

```bash
cd exposevm
cp default.example.conf  default.local.conf
```

Replace the ARTIFACTORY_URL with the url you got from minikube - 
Note that you get 2 urls http and https choose the http 
Now start the docker compose 

```bash
docker compose up -d 
```

```yaml
local:
    endpoint: http://artifactory:81
    username: admin
    password: THE PASSWORD 
    token: THE TOKEN
```


11. Install Insights

```bash
helm upgrade --install insight -f insights-values.yaml jfrog/insight
```

12. Install XRay

```bash
helm upgrade --install xray -f xray-values.yaml jfrog/xray
```

* For offline DB update: copy files to XRay

```bash
kubectl cp -c xray-server comp_0.zip xray-0:/var/opt/jfrog/xray/work/server/updates/component/
kubectl cp -c xray-server vuln_0.zip xray-0:/var/opt/jfrog/xray/work/server/updates/vulnerability/
```

Then trigger DB sync from the UI.

13. Install additional environment ("europe")

```bash
helm upgrade --install artifactory-europe -f artifactory-europe-values.yaml jfrog/artifactory
```

    Then, log in to the new Artifactory (http://artifactory-europe.localhost:83 with username `admin` and password `password`).

    * If you are asked to change your password, then change it.
    * If you are presented with a dialog to upload a license, then close it (there's an "X" at the top right corner of the window).
    
    Go to "User Management" -> "Access Tokens", click "Generate Token" and create a Pairing Token. Remember it (we will call it
    "Europe Pairing Token").

 a. add europe configuration to the nginx config file and restart docker compose 


14. Add "europe" as a Platform Deployment in the main artifactory. Replace `TOKEN` at the end of the command below with the
    value of the pairing token you just created:




```yaml
local-europe:
    endpoint: http://europe:83
    username: admin
    password: YOURPASS
    token: YOURTOKEN
```

15. get the port for europe by 
```bash 
minikube service url artifactory-europe-artifactory-nginx 
```


```bash
workon jfrog
mc register-jpd --profile local --name europe --url http://europe:THE_NODE_PORT --city Frankfurt --country DE --latitude 50.11552 --longitude 8.68417 --pairing-token TOKEN
```

    The command will provide a JSON. Remember the `id` field, you'll need it soon.

15. Assign license to "europe". Replace `JPD_ID` with the JPD ID from before.

```bash
workon jfrog
mc attach-license --profile local --jpd-id JPD_ID --bucket main
```

16. Log out of the `europe` site, and log back in. You should have full functionality now.

17. If you weren't already forced to do so: change the admin's password for the `europe` site (through the user's menu at the top right).
18. Create an identity token for yourself in the `europe` site.
18. Edit the DevOps Sherpas CLI configuration file. Under `local-europe`, populate your new password and identity token for the `europe` site.
19. Establish Circle of Trust between the two Artifactory sites

```bash
mkdir .tmp
kubectl cp artifactory-0:var/etc/access/keys/root.crt .tmp/artifactory-root.crt
kubectl cp artifactory-europe-0:var/etc/access/keys/root.crt .tmp/europe-root.crt
kubectl cp .tmp/artifactory-root.crt artifactory-europe-0:var/etc/access/keys/trusted/
kubectl cp .tmp/europe-root.crt artifactory-0:var/etc/access/keys/trusted/
```

**NOTE** Only proceed if you need to train on Distribution / Pipelines.

1. Create databases:
   * For Distribution: `distribution`
   * For Pipelines: `pipelines`
   * For Artifactory-Asia (edge node): `artifactory-asia`

2. Install Distribution

```bash
helm upgrade --install distribution -f distribution-values.yaml jfrog/distribution
```

a. Upload GPG key to distribution. Activate the Python virtual environment created above, and then:

```bash
distribution upload-keys-and-propagate --profile local --public-key-file public.asc --private-key-file private.asc --default --protocol gpg
```
this works
```bash 
distribution upload-keys-and-propagate --profile local --public public.asc --private private.asc --default --protocol gpg --alias local
```

3. Install Edge ("asia")

```bash
helm upgrade --install artifactory-asia -f artifactory-asia-values.yaml jfrog/artifactory
```

a. get the asia url 
```bash
minikube service url artifactory-asia-artifactory-nginx
``` 

   Then follow the same post-installation steps as you did for the Europe site. (The URL should be http://asia:PORT)

4. Add "asia" as a Platform Deployment in the main artifactory. Replace `TOKEN` at the end of the command below with the
   value of the pairing token you just created:

```bash
mc register-jpd --profile local --name asia --url http://asia:PORT --city Mumbai --country IN --latitude 19.07283 --longitude 72.88261 --pairing-token TOKEN
```

   The command will provide a JSON. Remember the `id` field, you'll need it soon.

5. Assign an Edge license to "asia". Replace `JPD_ID` with the JPD ID from before.

```bash
mc attach-license --profile local --jpd-id JPD_ID --bucket edge
```

6. Log out of the `asia` site, and log back in. You should have full Edge functionality now.

7. If you weren't already forced to do so: change the admin's password for the `asia` site (through the user's menu at the top right).
8. Create an identity token for yourself in the `asia` site.
9. Edit the DevOps Sherpas CLI configuration file. Under `local-asia`, populate your new password and identity token for the `asia` site.
10. Establish Circle of Trust between "asia" and the two remaining Artifactory sites

```bash
kubectl cp artifactory-asia-0:var/etc/access/keys/root.crt .tmp/asia-root.crt
kubectl cp .tmp/artifactory-root.crt artifactory-asia-0:var/etc/access/keys/trusted/
kubectl cp .tmp/europe-root.crt artifactory-asia-0:var/etc/access/keys/trusted/
kubectl cp .tmp/asia-root.crt artifactory-europe-0:var/etc/access/keys/trusted/
kubectl cp .tmp/asia-root.crt artifactory-0:var/etc/access/keys/trusted/
```

11. Install Pipelines

```bash
helm upgrade --install pipelines jfrog/pipelines -f pipelines-values.yaml
```

# CONTROL

## Startup

### Infra

# not needed in linux 
```bash
kubectl scale deployment ingress-nginx-controller --namespace ingress-nginx --replicas=1
```

### Artifactory (main)

```bash
kubectl scale deployment artifactory-artifactory-nginx --replicas=1
kubectl scale statefulsets artifactory --replicas=1
```

### Artifactory (europe)

```bash
kubectl scale deployment artifactory-europe-artifactory-nginx --replicas=1
kubectl scale statefulsets artifactory-europe --replicas=1
```

### Artifactory (asia)

```bash
kubectl scale deployment artifactory-asia-artifactory-nginx --replicas=1
kubectl scale statefulsets artifactory-asia --replicas=1
```

### Insights

```bash
kubectl scale statefulsets insight --replicas=1
```

### Distribution

```bash
kubectl scale statefulsets distribution --replicas=1
```

### XRay

```bash
kubectl scale statefulsets xray-rabbitmq --replicas=1
kubectl scale statefulsets xray --replicas=1
```

### Pipelines

```bash
kubectl scale statefulsets pipelines-redis-master --replicas=1
kubectl scale statefulsets pipelines-rabbitmq --replicas=1
kubectl scale statefulsets pipelines-vault --replicas=1
kubectl scale statefulsets pipelines-pipelines-services --replicas=1
```

## Shutdown

### Pipelines

```bash
kubectl scale statefulsets pipelines-pipelines-services --replicas=0
kubectl scale statefulsets pipelines-vault --replicas=0
kubectl scale statefulsets pipelines-rabbitmq --replicas=0
kubectl scale statefulsets pipelines-redis-master --replicas=0
```

### XRay

```bash
kubectl scale statefulsets xray --replicas=0
kubectl scale statefulsets xray-rabbitmq --replicas=0
```

### Distribution
```bash
kubectl scale statefulsets distribution --replicas=0
```

### Insights
```bash
kubectl scale statefulsets insight --replicas=0
```

### Artifactory (asia)

```bash
kubectl scale statefulsets artifactory-asia --replicas=0
kubectl scale deployment artifactory-asia-artifactory-nginx --replicas=0
```

### Artifactory (europe)

```bash
kubectl scale statefulsets artifactory-europe --replicas=0
kubectl scale deployment artifactory-europe-artifactory-nginx --replicas=0
```

### Artifactory (main)

```bash
kubectl scale statefulsets artifactory --replicas=0
kubectl scale deployment artifactory-artifactory-nginx --replicas=0
```

### Infra

```bash
kubectl scale deployment ingress-nginx-controller --namespace ingress-nginx --replicas=0
```

## Upgrade

1. Start the ingress nginx controller:

```bash
kubectl scale deployment ingress-nginx-controller --namespace ingress-nginx --replicas=1
```

2. If you're updating Artifactory: Re-run the Artifactory installation command. It will upgrade
   Artifactory in-place.

   a. Otherwise, start Artifactory (see the startup command above).
3. Run the installation command for the component that you'd like to upgrade. For example, in order
   to upgrade Xray, run the same command you used to install Xray in the first place. The component
   will be upgraded in-place.
