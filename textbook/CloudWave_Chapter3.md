## 14. ConfigMap

#### 14.1 도커에서 매개변수 전달

##### 14.1.1 디렉토리 생성 및 소스 코드 작성

```{bash}
mkdir -p ./configmap/docimg/indocker
mkdir -p ./configmap/kubetmp

cd ./configmap/docimg/indocker
vi fortuneloop.sh
```

```{bash}
#!/bin/bash
trap "exit" SIGINT
INTERVAL=$1 #파라메터로 첫번째 매개 변수를 INTERVAL 로 저장
echo "Configured to generate neew fortune every " $INTERVAL " seconds"
mkdir /var/htdocs
while :
do
    echo $(date) Writing fortune to /var/htdocs/index.html
    /usr/games/fortune  > /var/htdocs/index.html
    sleep $INTERVAL
done
```

```{bash}
chmod 755 fortuneloop.sh
```

##### 14.1.2 Docker 이미지 생성

> Docker CMD 는 3가지 형태로 사용 가능 합니다.
>
> - CMD [ "실행파일" ,  "파라메터1" , "파라메터2" ] → **실행파일 형태**
> - CMD [ "파라메터1" , "파라메터2"]  → **ENTRYPOINT 의 디펄트 파라메터**
> - CMD command 파라메터1 파라매터2 → **쉘 명령어 형태**

```{bash}
$ vi dockerfile
```

```{dockerfile}
FROM ubuntu:latest
RUN apt-get update;  apt-get -y install fortune
ADD fortuneloop.sh /bin/fortuneloop.sh
RUN chmod 755 /bin/fortuneloop.sh
ENTRYPOINT ["/bin/fortuneloop.sh"]
CMD ["10"]  # args가 없으면 10초
```

```{bash}
$ docker build -t dangtong/fortune:args .
$ docker push dangtong/fortune:args
```

> 테스트를 위해 다음과 같이 수행 가능
>
> $ docker run -it dangtong/fortune:args # 기본 10초 수행
>
> $ docker rm -f [docker-id]
>
> $ docker run -it dangtong/fortune:args 15 # 15초로 매개변수 전달
>
> $ docker rm -f [docker-id]

##### 14.1.3 Pod생성

파일명 : config-fortune-pod.yaml

```{bash}
cd ../../kubetmp
vi config-fortune-indocker-pod.yaml
```

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: fortune5s
spec:
  containers:
  - image: dangtong/fortune:args
    args: ["5"]
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

```{bash}
kubectl apply -f ./config-fortune-indockeer-pod.yaml
```

#### 14.2 Yaml 파일을 통한 매개변수 전달

##### 14.2.1 fortuneloop.sh 작성

```{bash}
cd ../
mkdir -p ./docimg/inyaml
cd ./docimg/inyaml
vi fortuneloop.sh
```

```{bash}
#!/bin/bash
# 매개변수르 받지 않고 환경변로에서 바로 참조
trap "exit" SIGINT
echo "Configured to generate neew fortune every " $INTERVAL " seconds"
mkdir /var/htdocs
while :
do
    echo $(date) Writing fortune to /var/htdocs/index.html
    /usr/games/fortune  > /var/htdocs/index.html
    sleep $INTERVAL
done
```

##### 14.2.2 Dockerfile 작성 및 build

```{bash}
$ vi dockerfile
```

```{dockerfile}
FROM ubuntu:latest
RUN apt-get update;  apt-get -y install fortune
ADD fortuneloop.sh /bin/fortuneloop.sh
ENTRYPOINT ["/bin/fortuneloop.sh"]
CMD ["10"]  # args가 없으면 10초
```

```{bash}
$ docker build -t dangtong/fortune:env .
$ docker push dangtong/fortune:env
```

##### 14.2.2 Pod 생성및 매개변수 전달을 위한 yaml 파일 작성

```{bash}
cd ../../kubetmp
vi config-fortune-inyaml-pod.yaml
```

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: fortune30s
spec:
  containers:
  - image: dangtong/fortune:env
    env:
    - name: INTERVAL 
      value: "30"
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

#### 14.3 ConfigMap 을 통한 설정

##### 14.3.1 ConfigMap 생성 및 확인

- configMap 생성

```{bash}
$ kubectl create configmap fortune-config --from-literal=sleep-interval=7
```

> ConfigMap 생성시 이름은 영문자,숫자, 대시, 밑줄, 점 만 포함 할 수 있습니다.
>
> 만약 여러개의 매개변수를 저장 할려면 --from-literal=sleep-interval=5 --from-literal=sleep-count=10 와 같이 from-literal 부분을 여러번 반복해서 입력 하면 됩니다.

- configMap 확인

```{bash}
$ kubectl get cm fortune-config

NAME             DATA   AGE
fortune-config   1      15s

$ kubectl get configmap fortune-config. -o yaml

apiVersion: v1
data:
  sleep-interval: "7"
kind: ConfigMap
metadata:
  creationTimestamp: "2020-04-16T09:09:33Z"
  name: fortune-config
  namespace: default
  resourceVersion: "1044269"
  selfLink: /api/v1/namespaces/default/configmaps/fortune-config
  uid: 85723e0a-1959-4ace-9365-47c101ebef82
```

##### 14.3.2 ConfigMap을 환경변수로 전달한는 yaml 파일 작성

- Yaml 파일 생성

```{bash}
vi config-fortune-mapenv-pod.yaml
```

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: fortune7s
spec:
  containers:
  - image: dangtong/fortune:env
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
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

##### 14.3.3 Pod 생성 및 확인

- Pod 생성

```{bash}
$ kubectl create -f ./config-fortune-mapenv-pod.yaml
```

- Pod 생성 확인

```{bash}
$ kubectl get po, cm

$ kubectl describe cm

Name:         fortune-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
sleep-interval:
----
7
Events:  <none>
```

- configMap 삭제

```{bash}
$ kubectl delete configmap fortune-config
```

#### 14.4 ConfigMap Volume 사용 (파일숨김)

##### 14.4.1 ConfigMap 생성

```{bash}
mkdir config-dir
cd config-dir
vi custom-nginx-config.conf
```

파일명 : custom-nginx-config.conf

```{conf}
server {
	listen				8080;
	server_name		www.acron.com;

	gzip on;
	gzip_types text/plain application/xml;
	location / {
		root	/usr/share/nginx/html;
		index	index.html index.htm;
	}
}
```

```{bash}
$ kubectl create configmap fortune-config --from-file=config-dir
```

##### 14.4.2 configMap volume 이용 Pod 생성

- Yaml 파일 작성 : config-fortune-mapvol-pod.yaml

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: nginx-configvol
spec:
  containers:
  - image: nginx:1.7.9
    name: web-server
    volumeMounts:
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
    ports:
    - containerPort: 8080
      protocol: TCP
  volumes:
  - name: config
    configMap:
      name: fortune-config
```

> 서버에 접속해서 디렉토리 구조를 한번 보는것이 좋습니다.
>
> kubectl exec -it nginx-pod bash

```{bash}
$ kubectl apply -f ./config-fortune-mapvol-pod.yaml
```

##### 14.4.3 ConfigMap Volume 참조 확인

```{bash}
$ kubectl get pod -o wide

AME              READY   STATUS    RESTARTS   AGE     IP          NODE
nginx-configvol   1/1     Running   0          9m25s   10.32.0.2   worker01.acorn.com
```

- Response 에 압축(gzip)을 사용 하는지 확인

```{bash}
$ curl -H "Accept-Encoding: gzip" -I 10.32.0.2:8080
```

- 마운트된 configMap 볼륨 내용확인

```{bash}
$ kubectl exec nginx-configvol -c web-server ls /etc/nginx/conf.d

nginx-config.conf


$ kubectl exec -it nginx-configvol sh
```

##### 14.4.4 ConfigMap 동적 변경

- 사전 테스트

```{bash}
$ curl -H "Accept-Encoding: gzip" -I 10.32.0.2:8080

HTTP/1.1 200 OK
Server: nginx/1.17.9
Date: Fri, 17 Apr 2020 06:10:32 GMT
Content-Type: text/html
Last-Modified: Tue, 03 Mar 2020 14:32:47 GMT
Connection: keep-alive
ETag: W/"5e5e6a8f-264"
Content-Encoding: gzip
```

- configMap 변경

```{bash}
$ kubectl edit cm fortune-config


```

**gzip on** 부분을 **gzip off ** 로 변경 합니다.

```{bash}
apiVersion: v1
data:
  nginx-config.conf: "server {\n  listen\t80;\n  server_name\tnginx.acorn.com;\n\n
    \ gzip off;\n  gzip_types text/plain application/xml;\n  location / {\n    root\t/usr/share/nginx/html;\n
    \   index\tindex.html index.htm;\n  }  \n}\n\n\n"
  nginx-ssl-config.conf: '##Nginx SSL Config'
  sleep-interval: |
    25
kind: ConfigMap
metadata:
  creationTimestamp: "2020-04-16T15:58:42Z"
  name: fortune-config
  namespace: default
  resourceVersion: "1115758"
  selfLink: /api/v1/namespaces/default/configmaps/fortune-config
  uid: 182302d8-f30f-4045-9615-36e24b185ecb
```

- 변경후 테스트

```{bash}
$ curl -H "Accept-Encoding: gzip" -I 10.32.0.2:8080

HTTP/1.1 200 OK
Server: nginx/1.17.9
Date: Fri, 17 Apr 2020 06:10:32 GMT
Content-Type: text/html
Last-Modified: Tue, 03 Mar 2020 14:32:47 GMT
Connection: keep-alive
ETag: W/"5e5e6a8f-264"
Content-Encoding: gzip
```

- nginx reload 명령으로 설정 갱신 

```{bash}
$ kubectl  exec nginx-configvol -c web-server -- nginx -s reload
```

- 최종 테스트

```{bash}
$ curl -H "Accept-Encoding: gzip" -I 10.32.0.2:8080

HTTP/1.1 200 OK
Server: nginx/1.17.9
Date: Fri, 17 Apr 2020 06:10:32 GMT
Content-Type: text/html
Last-Modified: Tue, 03 Mar 2020 14:32:47 GMT
Connection: keep-alive
ETag: W/"5e5e6a8f-264"
```

#### 14.5 ConfigMap Volume(파일 추가)

##### 14.5.1 configMap volume 이용 Pod 생성

- Yaml 파일 작성 : config-fortune-mapvol-pod2.yaml

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: nginx-configvol
spec:
  containers:
  - image: nginx:1.7.9
    name: web-server
    volumeMounts:
    - name: config
      mountPath: /etc/nginx/conf.d/default.conf
      subPath: nginx-config.conf # 주의 : configmap 의 key 와 파일명이 일치 해야합니다.
      readOnly: true
    ports:
    - containerPort: 8080
      protocol: TCP
  volumes:
  - name: config
    configMap:
      name: fortune-config
      defaultMode: 0660
```

> nginx 1.7.9 이상 버전, 예를 들면 nginx:latest 로 하면 /etc/nginx/conf.d 폴더내에 default.conf 파일만 존재 합니다. Example_cat tssl.conf 파일은 없습니다. 테스트를 위해서 nginx:1.7.9 버전으로 설정 한것입니다.

```{bash}
$ kubectl apply -f ./config-fortune-mapvol-pod.yaml
```

##### 14.5.2 서비스 및 ConfiMap 확인

- 서비스 확인

```{bash}
$ curl -H "Accept-Encoding: gzip" -I 10.32.0.2:8080
```

- configMap 확인

```{bash}
$ kubectl exec nginx-configvol -c web-server ls /etc/nginx/conf.d
```

##### 14.5.3 ConfigMap 추가

- configMap 추가

```{bash}
$ kubectl edit cm fortune-config
```

아래와 같이 nginx-ssl-config.conf 키값을 추가합니다.

```{bash}
apiVersion: v1
data:
  nginx-config.conf: "server {\n  listen\t80;\n  server_name\tnginx.acorn.com;\n\n
    \ gzip on;\n  gzip_types text/plain application/xml;\n  location / {\n    root\t/usr/share/nginx/html;\n
    \   index\tindex.html index.htm;\n  }  \n}\n\n\n"
  nginx-ssl-config.conf: ""##Nginx SSL Config" # 이부분이 추가됨
  sleep-interval: |
    25
kind: ConfigMap
metadata:
  creationTimestamp: "2020-04-16T15:58:42Z"
  name: fortune-config
  namespace: default
  resourceVersion: "1098337"
  selfLink: /api/v1/namespaces/default/configmaps/fortune-config
  uid: 182302d8-f30f-4045-9615-36e24b185ecb
```

##### 14.5.4 ConfigMap 추가된 Pod 생성

- 설정 파일 추가 하기위해 yaml 파일 수정

파일명 : config-fortune-mapvol-pod3.yaml

```{yaml}
kind: Pod
metadata:
  name: nginx-configvol
spec:
  containers:
  - image: nginx:1.7.9
    name: web-server
    volumeMounts:
    - name: config #default.conf 파일 교체
      mountPath: /etc/nginx/conf.d/default.conf
      subPath: nginx-config.conf
      readOnly: true
    - name: config #example_ssl.conf 파일 교체
      mountPath: /etc/nginx/conf.d/example_ssl.conf
      subPath: nginx-ssl-config.conf
      readOnly: true
    ports:
    - containerPort: 8080
      protocol: TCP
  volumes:
  - name: config
    configMap:
      name: fortune-config
      defaultMode: 0660
```

```{bash}
$ kubectl apply -f ./ config-fortune-mapvol-pod3.yaml
```

##### 14.5.6 추가된 ConfigMap 확인

- 서비스 확인

```{bash}
$ curl http://10.32.0.4
```

- configMap 확인

```{bash}
$ kubectl exec -it nginx-configvol bash

$ cd /etc/nginx/conf.d
$ ls -al

```

## 15. Secret

```{bash}
mkdir -p ./secret/cert
mkdir -p ./secret/config
mkdir -p ./secret/kubetmp
```

### 15.1 Secret 생성 (fortune-https)

```{bash}
cd ./secret/cert
```

```{bash}
openssl genrsa -out https.key 2048
openssl req -new -x509 -key https.key -out https.cert -days 360 -subj '/CN=*.acron.com'
```

```{bash}
kubectl create secret generic fortune-https --from-file=https.key --from-file=https.cert
```

### 15.2 SSL 용 niginx 설정 생성(fortune-config)

```{bash}
cd ./secret/config
vi custom-nginx-config.conf
```

```{bash}
server {
	listen				8080;
  listen				443 ssl;
	server_name		www.acron.com;
	ssl_certificate		certs/https.cert;
	ssl_certificate_key	certs/https.key;
	ssl_protocols		TLSv1 TLSv1.1 TLSv1.2;
	ssl_ciphers		HIGH:!aNULL:!MD5;
	gzip on;
	gzip_types text/plain application/xml;
	location / {
		root	/usr/share/nginx/html;
		index	index.html index.htm;
	}
}
```

```{bash}
vi sleep-interval
7
```

```{bash}
kubectl create cm fortune-config --from-file=./config
```

### 15.3 POD 생성

- Pod 생성 : 8.3.2 의 yaml 파일 참조
- 파일명 : secret-pod.yaml

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: fortune-https
spec:
  containers:
  - image: dangtong/fortune:env
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
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
    - name: config # 추가
      mountPath: /etc/nginx/conf.d
      readOnly: true
    - name: certs # 추가
      mountPath: /etc/nginx/certs/
      readOnly: true
    ports:
    - containerPort: 80
    - containerPort: 443 # 추가
  volumes:
  - name: html
    emptyDir: {}
  - name: config # 추가
    configMap:
      name: fortune-config
      items:
      - key: custom-nginx-config.conf
        path: https.conf
  - name: certs  #추가
    secret:
      secretName: fortune-https
```

```{bash}
kubectl apply -f ./secret-pod.yaml
```

### 15.4 서비스 확인

```{bash}
kubectl port-forward fortune-https 8443:443 &
```

```{bash}
curl https://localhsot:8443 -k
curl https://localhost:8443 -k -v
```

### [연습문제  15-1]

#### 1. Mysql 구성하기

##### 1.1 서비스 구성

파일명 : mysql-svc.yaml

```{yaml}
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
```

> 해드리스(Headless) 서비스를 만들면 명시적인 클러스터 IP 가 할당되지 않고 라우팅 됩니다. 헤드리스 서비스는 다른 네임스페이스의 서비스에 라우팅이 필요 할때도 유용 합니다. 헤드리스 서비스의 ExternalName 을 사용하 다른 네임스페이스의 서비스를 연결 할 수 있습니다. 원래 ExternalName은 K8s 외부의 서비스를 K8s 내부 서비스인 것처럼 참조할수 있게 해주는 기능 입니다.
>
> - 셀렉터가 있는경우 : 엔드포인트 컨트롤러가 엔드포인트 레코드를 생성하고 DNS 를 업데이트 하여 파드를 가르키는 A레코드(IP주소) 반환 하여 라우팅이 가능 합니다.
>
> - 셀렉터기 없는 경우 : DNS 시스템이 CNAME레코드 구성 하거나 서비스 이름으로 구성된 엔트포인트 레코드 참조
>
> - A 레코드와  CNAME 의 차이
>
>   - A레코드 : 간단하게 도메인 이름에 IP Address 를 매핑하는 레코드
>
>     ```{bash}
>     Name: www.acorn.com
>     Address: 10.0.24.3
>     ```
>
>   - CNAME(Canonical Name) : 도메인의 별칭을 부여하는 방식. 도메인의 또 다른 도메인 이름, A 레코드는 직접적으로 IP가 할당 되기 때문에 IP가 변경되면 직접 도메인에 영향을 미치지만, CNAME은 도메인에 매핑되어 있기 때문에 IP 변경에 직접적인 영향을 받지 않음
>
>     ```{bash}
>     www.acornstudy.com -> study.acorn.com (CNAME) 
>     study.acorn.com -> 211.231.99.250 (A record)
>     ```
>
>     ```{bah}
>             
>     ```
>
>
>     mysql.acorn.com -> 211.231.99.250 (A record) 직접통신
>     ```

##### 1.2 볼륨 구성

파일명 : mysql-pvc.yaml

```{yaml}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```

##### 1.3 Pod 구성

- mysql 비번을 secret 을 생성하여 저장 합니다.

```{bash}
kubectl create secret generic mysql-pass  --from-literal=password='admin123'
```



파일명 : mysql-deploy.yaml

```{yaml}
apiVersion: apps/v1 # 1.9.0 이전 버전은 apps/v1beta2 를 사용하세요
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

```{bash}
kubectl apply -f ./mysql-deploy.yaml
```

#### 2. WordPress 서비스 구성

##### 2.1 LoadBalancer 구성

```{yaml}
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: LoadBalancer
```

##### 2.2 PVC 구성

```{yaml}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```

##### 2.3 WordPress 구성

```{yaml}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - image: wordpress:4.8-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pv-claim
```

## 16. StatefullSet

### 16.1 애플리케이션 이미지 작성

#### 16.1.1 app.js 작성

```{javascript}
const http = require('http');
const os = require('os');
const fs = require('fs');

const dataFile = "/var/data/kubia.txt";
const port  = 8080;

// 파일 존재  유/무 검사
function fileExists(file) {
  try {
    fs.statSync(file);
    return true;
  } catch (e) {
    return false;
  }
}

var handler = function(request, response) {
//  POST 요청일 경우 BODY에 있는 내용을 파일에 기록 함
  if (request.method == 'POST') {
    var file = fs.createWriteStream(dataFile);
    file.on('open', function (fd) {
      request.pipe(file);
      console.log("New data has been received and stored.");
      response.writeHead(200);
      response.end("Data stored on pod " + os.hostname() + "\n");
    });
// GET 요청일 경우 호스트명과 파일에 기록된 내용을 반환 함
  } else {
    var data = fileExists(dataFile) ? fs.readFileSync(dataFile, 'utf8') : "No data posted yet";
    response.writeHead(200);
    response.write("You've hit " + os.hostname() + "\n");
    response.end("Data stored on this pod: " + data + "\n");
  }
};

var www = http.createServer(handler);
www.listen(port);
```

#### 16.1.2 Docker 이미지 만들기

- Dockerfile 작성

```{dockerfile}
FROM node:7
ADD app.js /app.js
ENTRYPOINT ["node", "app.js"]
```

- Docker 이미지 build 및 push

```{bash}
$ docker build dangtong/nodejs:sfs .
$ docker login
$ docker push dangtong/nodejs:sfs
```

### 16.2 Sotage Class  생성

```{yaml}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: sc-standard-retain
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Retain
parameters:
  type: pd-ssd
  zone: asia-northeast1-c
```

### 16.3 서비스 및 Pod 생성

#### 16.3.1 로드밸런서 서비스 생성

```{yaml}
apiVersion: v1
kind: Service
metadata:
    name: nodesjs-sfs-lb
spec:
    type: LoadBalancer
    ports:
    - port: 80
      targetPort: 8080
    selector:
        app: nodejs-sfs
```

#### 16.3.2 Pod 생성

```{yaml}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nodejs-sfs
spec:
  selector:
    matchLabels:
      app: nodejs-sfs
  serviceName: nodejs-sfs
  replicas: 2
  template:
    metadata:
      labels:
        app: nodejs-sfs
    spec:
      containers:
      - name: nodejs-sfs
        image: dangtong/nodejs:sfs
        ports:
        - name: http
          containerPort: 8080
        volumeMounts:
        - name: data
          mountPath: /var/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      resources:
        requests:
          storage: 1Mi
      accessModes:
      - ReadWriteOnce
      storageClassName: sc-standard-retain
```

```{bash}
kubectl apply -f nodejs-sfs.yaml
```

```{bash}
kubectl get svc

NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
service/kubernetes       ClusterIP      10.65.0.1      <none>         443/TCP        7h43m
service/nodesjs-sfs-lb   LoadBalancer   10.65.12.243   34.85.38.158   80:32280/TCP   120m

```

### 16.4 서비스 테스트

- 데이터 조회

```{bash}
curl http://34.85.38.158
```

- 데이터 입력

```{bash}
curl -X POST -d "hi, my name is dangtong-1" 34.85.38.158
curl -X POST -d "hi, my name is dangtong-2" 34.85.38.158
curl -X POST -d "hi, my name is dangtong-3" 34.85.38.158
curl -X POST -d "hi, my name is dangtong-4" 34.85.38.158
```

> 데이터 입력을 반복하에 두개 노드 모드에 데이터를 모두 저장 합니다. 양쪽 노드에 어떤 데이터가 입력 되었는지 기억 하고 다음 단계로 넘어 갑니다.

### 16.5 노드 삭제 및 데이터 보존 확인

- 노드 삭제 및 자동 재생성

```{bash}
kubectl delete pod nodejs-sfs-0
```

노드를 삭제 한뒤 노드가 재생성 될때 까지 기다립니다.

- 데이터 보존 확인

```{bash}
curl http://34.85.38.158
```

> 노드가 삭제 되었다 재생성 되도 기존 디스크를 그대로 유지하는 것을 볼 수 있습니다. ReclaimPolicy 를 Retain 으로 했기 때문 입니다.

## 17. 리소스 제어

### 17.1 부하 발생용 애플리 케이션 작성

#### 17.1.1 PHP 애플리 케이션 작성

파일명 : index.php

```{php}
<?php
  $x = 0.0001;
  for ($i = 0; $i <= 1000000; $i++) {
    $x += sqrt($x);
  }
  echo "OK!";
?>
```

#### 17.1.2 도커 이미지 빌드

```{dockerfile}
FROM php:5-apache
ADD index.php /var/www/html/index.php
RUN chmod a+rx index.php
```

```{bash}
docker build -t dangtong/php-apache .
docker login
docker push dangtong/php-apache
```

### 17.2 포드 및 서비스 만들기

#### 17.2.1 Deployment 로 Pod 새성

파일명 : php-apache-deploy.yaml

```{yaml}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache-dp
spec:
  selector:
    matchLabels:
      app: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: dangtong/php-apache
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
```

#### 17.2.2 로드밸런서 서비스 작성

파일명 : php-apache-svc.yaml

```{yaml}
apiVersion: v1
kind: Service
metadata:
  name: php-apache-lb
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: php-apache
```

```{bash}
kubectl apply -f ./php-apache-deploy.yaml
kubectl apply -f ./php-apache-svc.yaml
```

### [연습문제 17-1]

아래 요구 사항에 맞는 deploy 를 구현 하세요

| 항목        | 내용        |
| ----------- | ----------- |
| Deploy name | nginx       |
| Image       | ginx:latest |
| cpu         | 200m        |
| memory      | 300Mi       |
| Port        | 80          |



1. Deploy name : nginx
2. image : nginx
3. cpu 200m
4. 메모리 : 300Mi
5. Port : 80



### 12.3 HPA 리소스 생성

#### 12.3.1 HPA 리소스 생성

```{bash}
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=5
```



#### 12.3.2 HPA 리소스 생성 확인

```{bash}
kubectl get hpa
```



### 12.4 Jmeter 설치 및 구성



#### 12.4.1 Jmeter 설치를 위해 필요한 것들

- JDK 1.8 이상 설치 [오라클 java SE jdk 다운로드](https://www.oracle.com/java/technologies/javase-downloads.html)

- Jmeter 다운로드 [Jmeter 다운로드](https://jmeter.apache.org/download_jmeter.cgi)

  플러그인 다운로드 [Jmeter-plugin 다운로드](https://jmeter-plugins.org/install/Install/)

  - Plugins-manager.jar 다운로드 하여 jmeter 내에 lib/ext 밑에 복사 합니다.  jpgc

#### 12.4.2 Jmeter 를 통한 부하 발생

![jmeter](/Users/hbyun/Library/CloudStorage/GoogleDrive-dbyun@redhat.com/내 드라이브/05.Lecture/kubernetes/실습교재/textbook/img/jmeter.png)

#### 12.4.3 부하 발생후 Pod 모니터링

```{bash}
$ kubectl get hpa

$ kubectl top pods

NAME                          CPU(cores)   MEMORY(bytes)
nodejs-sfs-0                  0m           7Mi
nodejs-sfs-1                  0m           7Mi
php-apache-6997577bfc-27r95   1m           9Mi


$ kubectl exec -it nodejs-sfs-0 top

Tasks:   2 total,   1 running,   1 sleeping,   0 stopped,   0 zombie
%Cpu(s):  4.0 us,  1.0 sy,  0.0 ni, 95.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:   3786676 total,  3217936 used,   568740 free,   109732 buffers
KiB Swap:        0 total,        0 used,        0 free.  2264392 cached Mem
    PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
      1 root      20   0  813604  25872  19256 S  0.0  0.7   0:00.17 node
     11 root      20   0   21924   2408   2084 R  0.0  0.1   0:00.00 top
```

### [[연습문제 12-1]]

이미지를 nginx 를 생성하고 HPA 를 적용하세요

- Max : 8
- Min : 2
- CPU 사용량이 40% 가 되면 스케일링 되게 하세요