## 12. 서비스 (Service)

### 12.0 Telepresense

#### 12.0.1 Telepresense CLI 로컬 설치

- Mac

```
brew install datawire/blackbird/telepresence
```

- Windows

```
# 1. 다운로드
curl -fL https://app.getambassador.io/download/tel2/windows/amd64/latest/telepresence.zip -o telepresence.zip
# 2. 압축해지
# 3. 명령어 수행
Set-ExecutionPolicy Bypass -Scope Process .\install-telepresence.ps1
# 4. 원본 압축파일 지우고, PowerShell 다시 열기
```

- linux

```{BASH}
# 1. make director for telepresence
mkdir /code/local/k8s/util

# 2. Download the latest binary (~95 MB):
sudo curl -fL https://app.getambassador.io/download/tel2oss/releases/download/v2.17.0/telepresence-linux-amd64 -o /code/local/k8s/util/telepresence

# 3. Make the binary executable:
sudo chmod a+x /code/local/k8s/util/telepresence

# 4. Add path to .bashrc
```

#### 12.0.2 Telepresense 서버를 쿠버네티스 클러스터에 설치

```
# Telepresence namespace 생성
kubectl create namespace telepresense

# Telepresense 서버를 쿠버네티스에 설치
telepresence helm install -n telepresense

# 설치 확인
kubectl get all -n telepresence
```

#### 12.0.3 연결 하고 상태 확인하기

```
# Telepresense 프록시 연결
telepresence connect  --manager-namespace telepresence

# 연결 상태 확인
telepresence status
```

### 12.1 ClusterIP

#### 12.1.0 nodes app 생성

```{javascript}
const http = require('http');
const os = require('os');

console.log("Kubia server starting...");

var handler = function(request, response) {
  console.log("Received request from " + request.connection.remoteAddress);
  response.writeHead(200);
  response.end("You've hit " + os.hostname() + "\n");
};

var www = http.createServer(handler);
www.listen(8080);
```

```{bash}
# FROM 으로 BASE 이미지 로드
FROM node:7

# ADD 명령어로 이미지에 app.js 파일 추가
ADD app.js /app.js

# ENTRYPOINT 명령어로 node 를 실행하고 매개변수로 app.js 를 전달
ENTRYPOINT ["node", "app.js"]
```

#### 12.1.1. pod 생성

```{yaml}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodeapp-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodeapp-pod
  template:
    metadata:
      labels:
        app: nodeapp-pod
    spec:
      containers:
      - name: nodeapp-container
        image: dangtong/nodeapp
        ports:
        - containerPort: 8080
```

#### 12.1.2 yaml을 통한 ClusterIP 생성

```{yaml}
apiVersion: v1
kind: Service
metadata:
  name: nodeapp-service
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: nodeapp-pod
```

#### 12.1.3 서비스 상태 확인

```{bash}
kubectl get  po,deploy,svc

NAME                                      READY   STATUS    RESTARTS   AGE
pod/nodeapp-deployment-55688d9d4b-8pzsk   1/1     Running   0          2m45s
pod/nodeapp-deployment-55688d9d4b-pslvb   1/1     Running   0          2m46s
pod/nodeapp-deployment-55688d9d4b-whbk8   1/1     Running   0          2m46s

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nodeapp-deployment   3/3     3            3           2m46s

NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
nodeapp-service   ClusterIP      10.101.249.42    <none>           80/TCP         78s
```

#### 12.1.4 서비스 확인

- local VirtualBox

```{bash}
curl http://10.101.249.42  #여러번 수행 하기

You've hit nodeapp-deployment-55688d9d4b-8pzsk
```

- GCP Cloud

먼저 Pod 를 조회 합니다.

```{bash}
kubectl get po, svc

NAME                              READY   STATUS    RESTARTS   AGE
nodeapp-deploy-6dc7c5dd68-lh26q   1/1     Running   0          116m
nodeapp-deploy-6dc7c5dd68-r78cj   1/1     Running   0          116m
nodeapp-deploy-6dc7c5dd68-wcm7d   1/1     Running   0          116m

NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes         ClusterIP   10.116.0.1      <none>        443/TCP        32h
nodeapp-nodeport   NodePort    10.116.11.242   <none>        80:30123/TCP   121m
```

조회된 Pod 중 하나에  exec 옵션을 사용해 sh 로 접속 합니다.

```{bash}
kubectl exec nodeapp-deploy-6dc7c5dd68-lh26q -- sh
```

curl 을 설치 하고 Cluster IP 로 접속합니다.

```{bash}
apt-get install curl

curl http://10.116.11.242
```

#### 12.1.5 원격 Pod에서 curl 명령 수행하기

```{bash}
kubectl exec nodeapp-deployment-55688d9d4b-8pzsk -- curl -s http://10.101.249.42

You've hit nodeapp-deployment-55688d9d4b-whbk8
```

> .더블 대시는 kubectl 명령의의 종료를 가르킴

#### 12.1.6 서비스 삭제

```{bash}
kubectl delete svc nodeapp-service
```

## [연습문제 12-1] ClusterIP

다음 조건을 만족하는 서비스와 ClusterIP 를 생성 하세요

- Deployment
  
  | 항목            | 내용          |
  | ------------- | ----------- |
  | kind          | Deployment  |
  | image         | nginx:1.8.9 |
  | replicas      | 3           |
  | containerPort | 80          |

- Service
  
  | 항목         | 내용        |
  | ---------- | --------- |
  | kind       | Service   |
  | type       | ClusterIP |
  | port       | 80        |
  | targetPort | 80        |

- nginx:1.8.9 이미지를 이용하여 Replica=3 인 Deployment 를 생성하세요

- nginx 서비스를 로드밸렁싱 하는 서비스를 ClusterIP 로 생성하세요

- kubernetes port-forward를 이용해서 네트워크를 연결하고 curl 명령어로 웹사이트를 조회 하세요

### 12.2 NodePort

#### 12.2.1 yaml 을 이용한 NodePort 생성 (GCP 에서 수행 하기)

```{yaml}
apiVersion: v1
kind: Service
metadata:
  name: node-nodeport
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30123
  selector:
    app:  nodeapp-pod
```

#### 12.2.2 NodePort 조회

```{bash}
kubectl get po,rs,svc

NAME                                      READY   STATUS    RESTARTS   AGE
pod/nodeapp-deployment-55688d9d4b-8pzsk   1/1     Running   0          145m
pod/nodeapp-deployment-55688d9d4b-pslvb   1/1     Running   0          145m
pod/nodeapp-deployment-55688d9d4b-whbk8   1/1     Running   0          145m

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/nodeapp-deployment-55688d9d4b   3         3         3       145m

NAME                       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes         ClusterIP   10.96.0.1      <none>        443/TCP        10d
service/nodeapp-nodeport   NodePort    10.108.30.68   <none>        80:30123/TCP   4m14s
```

#### 12.2.3 NodePort 를 통한 서비스 접속 확인(여러번 수행)

- KIND Cluster

```{bash}
$ curl http://localhost:30123
You've hit nodeapp-deployment-55688d9d4b-pslvb

$ curl http://localhost:30123
You've hit nodeapp-deployment-55688d9d4b-whbk8

$ curl http://localhost:30123
You've hit nodeapp-deployment-55688d9d4b-pslvb
```

- GCP Cloud

```{bash}
kubectl get no -o wide # 결과에서 External-IP 를 참조

NAME                                      STATUS   ROLES    AGE   VERSION             INTERNAL-IP   EXTERNAL-IP     OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-istiok8s-default-pool-36a6222b-33vv   Ready    <none>   32h   v1.18.12-gke.1210   10.146.0.21   35.221.70.145   Container-Optimized OS from Google   5.4.49+          docker://19.3.9
gke-istiok8s-default-pool-36a6222b-6rhk   Ready    <none>   32h   v1.18.12-gke.1210   10.146.0.20   35.221.82.6     Container-Optimized OS from Google   5.4.49+          docker://19.3.9
gke-istiok8s-default-pool-36a6222b-xrzj   Ready    <none>   32h   v1.18.12-gke.1210   10.146.0.22   34.84.27.67     Container-Optimized OS from Google   5.4.49+          docker://19.3.9
```

```{bash}
$ curl http://35.221.70.145:30123
You've hit nodeapp-deploy-6dc7c5dd68-wcm7d

$ curl http://35.221.70.145:30123
You've hit nodeapp-deploy-6dc7c5dd68-lh26q

$ curl http://35.221.70.145:30123
You've hit nodeapp-deploy-6dc7c5dd68-r78cj
```

#### 12.2.4 NodePort 삭제

```{bash}
kubectl delete svc nodeapp-nodeport
```

### 12.3 LoadBalancer

#### 12.3.1 yaml 파일로 deployment 생성

```{bash}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodeapp-deployment
  labels:
    app: nodeapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodeapp-pod
  template:
    metadata:
      labels:
        app: nodeapp-pod
    spec:
      containers:
      - name: nodeapp-container
        image: dangtong/nodeapp
        ports:
        - containerPort: 8080
```

#### 12.3.2 서비스 확인

```{bash}
$ kubectl get po,rs,deploy

NAME                                      READY   STATUS    RESTARTS   AGE
pod/nodeapp-deployment-7d58f5d487-7hphx   1/1     Running   0          20m
pod/nodeapp-deployment-7d58f5d487-d74rp   1/1     Running   0          20m
pod/nodeapp-deployment-7d58f5d487-r8hq8   1/1     Running   0          20m
NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.extensions/nodeapp-deployment-7d58f5d487   3         3         3       20m
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/nodeapp-deployment   3/3     3            3           20m
```

```{bash}
kubectl get po -o wide

NAME                                  READY   STATUS    RESTARTS   AGE   IP           NODE                                  NOMINATED NODE   READINESS GATES
nodeapp-deployment-7d58f5d487-7hphx   1/1     Running   0          21m   10.32.2.10   gke-gke1-default-pool-ad44d907-cq8j
nodeapp-deployment-7d58f5d487-d74rp   1/1     Running   0          21m   10.32.2.12   gke-gke1-default-pool-ad44d907-cq8j
nodeapp-deployment-7d58f5d487-r8hq8   1/1     Running   0          21m   10.32.2.11   gke-gke1-default-pool-ad44d907-cq8j
```

#### 12.3.2 nodeapp 접속 해보기

```{bash}
$ kubectl exec nodeapp-deployment-7d58f5d487-7hphx -- curl -s http://10.32.2.10:8080
또는
$ kubectl exec -it nodeapp-deployment-7d58f5d487-7hphx bash

$ curl http://10.32.2.10:8080
You've hit nodeapp-deployment-7d58f5d487-7hphx
```

#### 12.3.3 yaml 파일을 이용해 LoadBalancer 생성

- KIND Cluster 및 GCP
  
  ```{yaml}
  apiVersion: v1
  kind: Service
  metadata:
    name:  nodeapp-lb
  spec:
    type: LoadBalancer
    ports:
    - port: 80
      targetPort: 8080
    selector:
      app: nodeapp-pod
  ```

- AWS
  
  ```{bash}
  apiVersion: v1
  kind: Service
  metadata:
    name:  nodeapp-lb
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  spec:
    type: LoadBalancer
    ports:
    - port: 80
      targetPort: 8080
    selector:
      app: nodeapp-pod
  ```

#### 12.3.5 LoadBalancer 생성 확인

```{bash}
kubectl get svc

NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP      10.36.0.1      <none>        443/TCP        7d21h
nodeapp-lb   LoadBalancer   10.36.14.234   <pending>     80:31237/TCP   33s
```

현재 pending 상태임 20초 정도 지나면

```{bash}
kubectl get svc

NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.36.0.1      <none>           443/TCP        7d21h
nodeapp-lb   LoadBalancer   10.36.14.234   35.221.179.171   80:31237/TCP   45s
```

#### 12.3.6 서비스 확인

```{bash}
curl http://35.221.179.171

You've hit nodeapp-deployment-7d58f5d487-r8hq8
```

### 12.4 Ingress

#### 12.4.1 Deployment 생성

- nginx / goapp deployment 생성

```{yaml}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-container
        image: nginx:1.7.9
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goapp-deployment
  labels:
    app: goapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: goapp
  template:
    metadata:
      labels:
        app: goapp
    spec:
      containers:
      - name: goapp-container
        image: dangtong/goapp
        ports:
        - containerPort: 8080
```

#### 12.4.2 Service 생성

- KIND Cluster , GCP
  
  ```{yaml}
  apiVersion: v1
  kind: Service
  metadata:
    name:  nginx-lb
  spec:
    type: LoadBalancer
    ports:
    - port: 80
      targetPort: 80
    selector:
      app: nginx
  
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name:  goapp-lb
  spec:
    type: LoadBalancer
    ports:
    - port: 80
      targetPort: 8080
    selector:
      app: goapp
  ```

- AWS
  
  ```{yaml}
  apiVersion: v1
  kind: Service
  metadata:
    name:  nginx-lb
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  spec:
    type: LoadBalancer
    ports:
    - port: 80
      targetPort: 80
    selector:
      app: nginx
  
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name:  goapp-lb
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  spec:
    type: LoadBalancer
    ports:
    - port: 80
      targetPort: 8080
    selector:
      app: goapp
  ```

#### 12.4.3 Ingress 생성

- KIND Cluster, GCP
  
  ```{yaml}
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: nginx-goapp-ingress
  spec:
    rules:
    - host: nginx.acorn.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: nginx-lb
              port:
                number: 80
    - host: goapp.acorn.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: goapp-lb
              port:
                number: 80
  ```

- AWS
  
  ```{yaml}
  apiVersion: networking.k8s.io/v1
  kind: IngressClass
  metadata:
    name: alb-ingress-class
  spec:
    controller: ingress.k8s.aws/alb
  ---
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: nginx-goapp-ingress
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
  spec:
    ingressClassName: "alb-ingress-class"
    rules:
    - host: nginx.duldul32.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: nginx-lb
              port:
                number: 80
    - host: goapp.duldul32.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: goapp-lb
              port:
                number: 80
  ```

#### 12.4.4 Ingress 조회

```{bash}
kubectl get ingress

NAME                  HOSTS                             ADDRESS   PORTS     AGE
nginx-goapp-ingress   nginx.acorn.com,goapp.acorn.com             80, 443   15s
```

> Ingress 가 완전히 생성되기 까지 시간이 걸립니다. 2~5분 소요

다시 조회 합니다

```{bash}
kubectl get ingress

NAME                  HOSTS                             ADDRESS          PORTS     AGE
nginx-goapp-ingress   nginx.acorn.com,goapp.acorn.com   35.227.227.127   80, 443   13m
```

#### 12.4.5 /etc/hosts 파일 수정

```{bash}
sudo vi /etc/hosts

35.227.227.127 nginx.acorn.com goapp.acorn.com
```

#### 12.4.6 서비스 확인

```{bash}
$ curl http://goapp.acorn.com
hostname: goapp-deployment-d7564689f-6rrzw

$ curl http://nginx.acorn.com
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
```

## 13.Volums

### 13.1 EmptyDir

#### 13.1.1 Docker 이미지 만들기

아래와 같이 폴더를 만들고 ./fortune/docimg 폴더로 이동합니다.

```{bash}
$ mkdir -p ./fortune/docimg
$ mkdir -p ./fortune/kubetmp
```

아래와 같이 docker 이미지를 작성하기 위해 bash 로 Application을 작성 합니다.

파일명 : fortuneloop.sh

```{bash}
#!/bin/bash
trap "exit" SIGINT
mkdir /var/htdocs
while :
do
    echo $(date) Writing fortune to /var/htdocs/index.html
    /usr/games/fortune  > /var/htdocs/index.html
    sleep 10
done
```

Dockerfile 을 작성 합니다.

```{dockerfile}
FROM ubuntu:latest
RUN apt-get update; apt-get -y install fortune
ADD fortuneloop.sh /bin/fortuneloop.sh
RUN chmod 755 /bin/fortuneloop.sh
ENTRYPOINT /bin/fortuneloop.sh
```

Dcoker 이미지를 만듭니다.

```{bash}
$ docker build -t dangtong/fortune .
```

Docker 이미지를 Docker Hub 에 push 합니다.

```{bash}
$ docker login
$ docker push dangtong/fortune
```

#### 13.1.2 Deployment 작성

fortune APP을 적용하기 위해 Deployment 를 작성 합니다.

```{bash}
cd ../ktmp/
vi fortune-deploy.yaml
```

```{yaml}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fortune-deployment
  labels:
    app: fortune
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fortune
  template:
    metadata:
      labels:
        app: fortune
    spec:
      containers:
      - image: dangtong/fortune
        name: html-generator
        volumeMounts:
        - name: html
          mountPath: /var/htdocs
      - image: nginx:alpine
        name: web-server
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
          readOnly: true
        ports:
          - containerPort: 80
            protocol: TCP
      volumes:
      - name: html
        emptyDir: {}
```

> html 볼륨을 html-generator 및 web-seerver 컨테이너에 모두 마운트 하였습니다.
> 
> html 볼륨에는 /var/htdocs 및 /usr/share/nginx/html 이름 으로 서로 따른 컨테이너에서 바라 보게 됩니다.
> 
> 다만, web-server 컨테이너는 읽기 전용(reeadOnly) 으로만 접근 하도록 설정 하였습니다.

> emptDir 을 디스크가 아닌 메모리에 생성 할 수도 있으며, 이를 위해서는 아래와 같이 설정을 바꾸어 주면 됩니다.
> 
> emptyDir:
> 
> medium: Memory

#### 13.1.3 LoadBalancer 작성

```{bash}
vi fortune-lb.yaml
```

```{yaml}
apiVersion: v1
kind: Service
metadata:
  name: fortune-lb
spec:
  selector:
    app: fortune
  ports:
    - port: 80
      targetPort: 80
  type: LoadBalancer
  externalIPs:
  - 192.168.56.108
```

#### 13.1.4 Deployment 및 Loadbalancer 생성

```{bash}
$ kubectl apply -f ./fortune-deploy.yaml
$ kubectl apply -f ./fortune-lb.yaml
```

#### 13.1.5. 서비스 확인

```{bash}
curl http://192.168.56.108
```

### 13.2 Git EmptyDir

#### 13.2.1 웹서비스용 Git 리포지토리 생성

Appendix3 . Git 계정 생성 및 Sync 참조

#### 13.2.2 Deployment 용 yaml 파일 작성

```{bash}
$ cd ./gitvolume/kubetmp
$ vi gitvolume-deploy.yaml
```

```{yaml}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitvolume-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:alpine
        name: web-server
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
          readOnly: true
        ports:
          - containerPort: 80
            protocol: TCP
      volumes:
      - name: html
        gitRepo:
          repository: https://github.com/dangtong76/k8s-web.git
          revision: master
          directory: .
```

#### 13.2.3 Deployment 생성

```{bash}
$ kubectl apply -f ./gitvolume-deploy.yaml
```

#### 13.2.4 Service 생성

```{bash}
apiVersion: v1
kind: Service
metadata:
  name: gitvolume-lb
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
  type: LoadBalancer
```

### 13.3 GCE Persisteent DISK 사용하기

#### 13.3.1. Persistent DISK 생성

- 리전/존 확인

```{bash}
# GCP
$ gcloud container clusters list
# AWS
$ aws eks describe-cluster --name cwave
```

- Disk 생성

```{bash}
## GCP
$ gcloud compute disks create --size=16GiB --zone asia-northeast1-b  mongodb

## GCP 삭제
## gcloud compute disks delete mongodb --zone asia-northeast1-b

## AWS
$ aws ec2 create-volume --volume-type gp2 --size 80 --availability-zone ap-northeast-2a

## AWS 삭제
## aws ec2 delete-volume --volume-id vol-038a54dff454064f6

## AWS 조회
## aws ec2 describe-volumes --filters Name=status,Values=available Name=availability-zone,Values=ap-northeast-2a
```

#### 13.3.2 Pod 생성을 위한 yaml 파일 작성

AWS 에서는 POD에 직접적으로 디스크를 마운트 하는것을 허용하지 않습니다.

- 파일명 : pv.yaml

```{yaml}
# GCP
apiVersion: v1
kind: Pod
metadata:
  name: mongodb
spec:
  volumes:
  - name: mongodb-data
    gcePersistentDisk:
      pdName: mongodb
      fsType: ext4
  containers:
  - image: mongo
    name:  mongodb
    volumeMounts:
    -  name: mongodb-data
       mountPath: /data/db
    ports:
    - containerPort: 27017
      protocol: TCP
```

- Pod 생성

```{bash}
$ kubectl apply -f ./gce-pv.yaml

$ kubectl get po

NAME      READY   STATUS    RESTARTS   AGE
mongodb   1/1     Running   0          8m42s
```

- Disk 확인

```{bash}
$ kubectl describe pod mongodb

...(중략)

Volumes:
  mongodb-data:
    Type:       GCEPersistentDisk (a Persistent Disk resource in Google Compute Engine)
    PDName:     mongodb  # 디스크이름
    FSType:     ext4
    Partition:  0
    ReadOnly:   false
  default-token-dgkd5:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-dgkd5
    Optional:    false

...(중략)
```

#### 13.3.3 Mongodb 접속 및 데이터 Insert

- 접속

```{bash}
kubectl exec -it mongodb mongosh
```

- 데이터 Insert

```{bash}
> use mystore
> db.foo.insert({"first-name" : "dangtong"})

> db.foo.find()
{ "_id" : ObjectId("5f9c4127caf2e6464e18331c"), "first-name" : "dangtong" }

> exit
```

#### 13.3.4 MongoDB Pod 재시작

- MongoDB 중단

```{bash}
$ kubectl delete pod mongodb
```

- MongoDB Pod 재생성

```{bash}
$ kubectl apply -f ./gce-pv.yaml
```

- 기존에 Insert 한 데이터 확인

```{bash}
$ kubectl exec -it mongodb mongo

> use mystore

> db.foo.find()
{ "_id" : ObjectId("5e9684134384860bc207b1f9"), "first-name" : "dangtong" }
```

#### 13.3.5 Pod 삭제

```{bash}
$ kubectl delete po mongodb
```

### 13.4 PersistentVolume 및 PersistentVolumeClaim

#### 13.4.1 PersistentVolume 생성

- GCP
  
  ```{yaml}
  # GCP
  apiVersion: v1
  kind: PersistentVolume
  metadata:
     name: mongodb-pv
  spec:
    capacity:
      storage: 1Gi
    accessModes:
    - ReadWriteOnce
    - ReadOnlyMany
    persistentVolumeReclaimPolicy: Retain
    gcePersistentDisk:
     pdName: mongodb
     fsType: ext4
  ```

- AWS
  
  볼륜정보 조회
  
  ```{yaml}
  aws ec2 describe-volumes --filters "Name=availability-zone,Values=ap-northeast-2a"
  ```
  
  - 

- AWS 노드 라벨 부여하기

```
kubectl label nodes ip-192-168-11-22.ap-northeast-2.compute.internal az=a
```

```{bash}
kubectl apply -f ./gce-pv2.yaml
```

```{bash}
kubectl get pv
```

#### 13.4.2 PersistentVolumeClaim 생성

gce-pvc.yaml 로 작성

```{yaml}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-pvc
spec:
  resources:
    requests:
      storage: 1Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: ""
```

```{bash}
kubectl apply -f ./gce-pvc.yaml
```

```{bash}
kubectl get pvc
```

#### 13.4.3 PV, PVC 를 이용한 Pod 생성

gce-pod.yaml 파일 생성

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: mongodb
spec:
  containers:
  - image: mongo
    name: mongodb
    volumeMounts:
    - name: mongodb-data
      mountPath: /data/db
    ports:
    - containerPort: 27017
      protocol: TCP
  volumes:
  - name: mongodb-data
    persistentVolumeClaim:
      claimName: mongodb-pvc
```

```bash
$ kubectl apply -f ./gce-pod.yaml
```

```{bash}
$ kubectl get po,pv,pvc
```

#### 13.4.4 Mongodb 접속 및 데이터 확인

```{bash}
$ kubectl exec -it mongodb -- mongo

> use mystore

> db.foo.find()
```

### 13.5 Persistent Volume 의 동적 할당

#### 13.5.1 StorageClass 를 이용해 스토리지 유형 정의

- 클라우드에서 제공하는 Default Storage Class  확인 해보기

```{bash}
# GCP
kubectl get sc

NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
fast                 kubernetes.io/gce-pd    Delete          Immediate              false                  3m37s
premium-rwo          pd.csi.storage.gke.io   Delete          WaitForFirstConsumer   true                   10d
standard (default)   kubernetes.io/gce-pd    Delete          Immediate              true                   10d
standard-rwo         pd.csi.storage.gke.io   Delete          WaitForFirstConsumer   true                   10d
# AWS
kubectl get sc
NAME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2 (default)   kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  44m
```

- 상세 내역 확인

```{bash}
kubectl describe sc standard

Name:                  standard
IsDefaultClass:        Yes
Annotations:           storageclass.kubernetes.io/is-default-class=true
Provisioner:           kubernetes.io/gce-pd
Parameters:            type=pd-standard # 일반 디스크
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>

kubectl describe sc premium-rwo

Name:                  premium-rwo
IsDefaultClass:        No
Annotations:           components.gke.io/component-name=pdcsi-addon,components.gke.io/component-version=0.8.7
Provisioner:           pd.csi.storage.gke.io
Parameters:            type=pd-ssd  # SSD 
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
```

- Storage Class 생성하기 위한 Zone 확인

```{bash}
gcloud container clusters list

NAME      LOCATION           MASTER_VERSION    MASTER_IP       MACHINE_TYPE  NODE_VERSION      NUM_NODES  STATUS
istiok8s  asia-northeast1-a  1.18.12-gke.1210  35.189.139.222  e2-medium     1.18.12-gke.1210  3          RUNNING
```

- GCP 지원 디스크 종류 확인 하기

```{bash}
gcloud compute disk-types list | grep asia-northeast1-a

local-ssd    asia-northeast1-a          375GB-375GB
pd-balanced  asia-northeast1-a          10GB-65536GB
pd-ssd       asia-northeast1-a          10GB-65536GB
pd-standard  asia-northeast1-a          10GB-65536GB
```

- Stroage Class 생성 (파일명 : sc.yaml)

```{yaml}
# GCP
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  zone: asia-northeast1-a  #클러스터를 만든 지역으로 설정 해야함

--- 
# AWS
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: ebs.csi.aws.com
volumeBindingMode: Immediate
reclaimPolicy: Delete
parameters:
  csi.storage.k8s.io/fstype: ext4
  type: gp2
allowedTopologies:
  - matchLabelExpressions:
    - key: topology.ebs.csi.aws.com/zone
      values:
      - ap-northeast-2a
      - ap-northeast-2c
```

```{bash}
$ kubectl apply -f ./gce-sclass.yaml
```

#### 13.5.2 Storage Class 이용한 PVC 생성

- gce-pvc-sclass.yaml

```{yaml}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
   name: mongodb-pvc
spec:
  storageClassName: fast
  resources:
    requests:
      storage: 100Mi
  accessModes:
    - ReadWriteOnce
```

```{bash}
$ kubectl apply -f ./gce-pvc-sclass.yaml
```

#### 13.5.3 PV 및 PVC 확인

- pvc 확인

```{bash}
$ kubectl get pvc mongdb-pvc
```

- pv 확인

```{bash}
$ kubectl get pv
```

#### 13.5.4 PVC 를 이용한 POD 생성

파일명 : gce-pod.yaml 파일 생성

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: mongodb
spec:
  containers:
  - image: mongo
    name: mongodb
    volumeMounts:
    - name: mongodb-data
      mountPath: /data/db
    ports:
    - containerPort: 27017
      protocol: TCP
  volumes:
  - name: mongodb-data
    persistentVolumeClaim:
      claimName: mongodb-pvc
```
