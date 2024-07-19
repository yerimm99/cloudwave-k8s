# 실전! CI-CD 실습하기

## 1. Gitclone 받기

소스를 클론 받은 뒤  VSCode 새창을 뛰워서 폴더를 엽니다.

```{bash}
git clone https://github.com/dangtong76/cwave-cicd-start.gitcd original-repo

cd original-repo

git remote remove origin

git remote add origin https://github.com/myusername/my-new-repo.git

git add .

git commit -m "Initial commit"

git push -u origin main
```

## 2. Java 설치 하기

[Microsoft Build of OpenJDK 다운로드 | Microsoft Learn](https://learn.microsoft.com/ko-kr/java/openjdk/download#openjdk-21)

에서 JDK 21.0.1 다운로드 및 설치

## 3. VsCode Java 플러그인 설치 하기

- Spring Boot Dashboard

- SpringBoot Extension

- Extension Pack for Java

- Gradle Extension Pack

## 4. 로컬환경에서 뛰워보기

- mysql docker volume 만들기
  
  xinfra/docker/data 디렉토리 만들기

- Docker-compose 로 Mysql 뛰우기

```{yaml}
version: '3'
services:
  db:
    image: mysql:8.0
    container_name: db
    environment:
      MYSQL_ROOT_PASSWORD: admin123
      MYSQL_DATABASE: istory 
      MYSQL_USER: dangtong
      MYSQL_PASSWORD: admin123
    ports:
      - "3306:3306"
    volumes:
      - ./data:/var/lib/mysq
```

- SpringBoot Dashboard 에서 cwave-cicd-start 시작 시키기

- http://localhost:8080 접속해서 서비스 확인하기

## 5. istroy 서비스 이미지 만들기

```{dockerfile}
FROM eclipse-temurin:21-jdk-alpine
VOLUME /tmp
RUN addgroup -S istory && adduser -S istory -G istory
USER istory
WORKDIR /home/istory
COPY springbootdeveloper-0.0.1-SNAPSHOT.jar /home/istory/istory.jar
ENTRYPOINT ["java","-jar","/home/istory/istory.jar"]
```

```{bash}
docker build -t dangtong/istory .

docker build --platform linux/amd64  -t dangtong/istory .
```

## 6. configmap 으로 만들기

### 파일명 : istory-app-config.yaml

- 참조 URL : https://env.simplestep.ca/

- src/main/resources/application.yml 내용을 configmap 으로 저장

| 항목   | 내용                |
| ---- | ----------------- |
| kind | ConfigMap         |
| name | istory-app-config |

```{yaml}
apiVersion: v1
kind: ConfigMap
metadata:
  name: istory-app-config
data:
  spring.datasource.url: 'jdbc:mysql://mysql-svc.default:3306/istory'
  spring.datasource.driver-class-name: 'com.mysql.cj.jdbc.Driver'
  spring.jpa.database-platform: 'org.hibernate.dialect.MySQLDialect'
  spring.jpa.hibernate.ddl-auto: 'update'
  spring.jpa.show-sql: 'true'
  spring.application.name: 'USER-SERVICE'
```

### 파일명 : istory-db-config.yaml

```{bash}
kind: ConfigMap
apiVersion: v1
metadata:
  name: istory-db-config
data:
  MYSQL_DATABASE: 'istory'
  MYSQL_USER: 'dangtong'
```

### 파일명 : istory-db-secret.yaml

```{yaml}
apiVersion: v1
kind: Secret
metadata:
  name: istory-db-secret
type: Opaque
data:
  MYSQL_PASSWORD: YWRtaW4xMjM=
  MYSQL_ROOT_PASSWORD: YWRtaW4xMjM=
```

## 7. Istory Deployment 만들기

### 파일명 : istory-app-deploy.yaml

```{yaml}
apiVersion: apps/v1
kind: Deployment
metadata:
  name:  istory
  labels:
    app:  istory
spec:
  selector:
    matchLabels:
      app: istory
  replicas: 3
  template:
    metadata:
      labels:
        app:  istory
    spec:
      initContainers:
        - name: check-mysql-ready
          image: mysql:8.0
          env:
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: istory-db-secret
                  key: MYSQL_PASSWORD
          command: ['sh',
                    '-c',
                    'until mysqladmin ping -u dangtong -p${MYSQL_PASSWORD} -h mysql-svc.default; do echo waiting for database; sleep 2; done;']
      containers:
        - name:  istory
          image:  dangtong/istory
          envFrom:
            - configMapRef:
                name: istory-app-config
          env:
            - name: spring.datasource.password
              valueFrom:
                secretKeyRef:
                  name: istory-db-secret
                  key: MYSQL_PASSWORD
            - name: spring.datasource.username
              valueFrom:
                configMapKeyRef:
                  name: istory-db-config
                  key: MYSQL_USER
          resources:
            requests:
              cpu: 300m
              memory: 500Mi
            limits:
              cpu: 400m
              memory: 600Mi
          readinessProbe:
            httpGet:
              path: /actuator
              port: 8080
            initialDelaySeconds: 30
            timeoutSeconds: 3
            successThreshold: 2
            failureThreshold: 3
            periodSeconds: 10
          ports:
            - containerPort:  3306
              name:  istory
      volumes:
        - name: application-config
          configMap:
            name: istory-app-config
      restartPolicy: Always
```

## 8. DB  만들기

### 파일명: istory-db-sc.yaml

```{yaml}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-persistent
provisioner: kubernetes.io/aws-ebs
reclaimPolicy: Retain
parameters:
  type: gp2
  fsType: ext4
volumeBindingMode: WaitForFirstConsumer
```

### 파일명 : istory-db-pvc.yaml

```{yaml}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: mysql
spec:
  storageClassName: gp2-persistent
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### 파일명 : istory-db-pod.yaml

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  containers:
    - image: mysql/mysql-server
      name: mysql
      resources:
        requests:
          cpu: "500m"
          memory: "500Mi"
        limits:
          cpu: "600m"
          memory: "600Mi"
      envFrom:
        - secretRef:
            name: istory-db-secret
        - configMapRef:
            name: istory-db-config
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

### 파일명 : istory-db-svc.yaml

```{yaml}
apiVersion: v1
kind: Service
metadata:
  name: mysql-svc
spec:
  selector:
    app: mysql
  ports:
    - name: mysql-svc
      protocol: TCP
      port: 3306
```

### 파일명 : istory-app-loadbalancer.yaml

```{yaml}
apiVersion: v1
kind: Service
metadata:
  name: istory-lb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: external
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
spec:
  type: LoadBalancer
  selector:
    app: istory
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 800
  ports:
    - name: istory
      protocol: TCP
      port: 80
      targetPort: 8080
```

## 9. github Action 파이프라인 만들기

```{yaml}
name: Java CI with Gradle

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

permissions:
  contents: read

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
      - name: 1. CheckOut Source
        uses: actions/checkout@v3

      - name: 2.Set up JDK 21
        uses: actions/setup-java@v3
        with:
          java-version: '21'
          distribution: 'temurin'
      - name: 3.Install Mysql
        uses: mirromutth/mysql-action@v1.1
        with:
          host port: 3306 # Optional, default value is 3306. The port of host
          container port: 3306 # Optional, default value is 3306. The port of container
          character set server: 'utf8' # Optional, default value is 'utf8mb4'. The '--character-set-server' option for mysqld
          collation server: 'utf8_general_ci' # Optional, default value is 'utf8mb4_general_ci'. The '--collation-server' option for mysqld
          mysql version: '8.0' # Optional, default value is "latest". The version of the MySQL
          mysql database: 'istory' # Optional, default value is "test". The specified database which will be create
          mysql root password: ${{ secrets.MYSQL_ROOT_PASSWORD }} # Required if "mysql user" is empty, default is empty. The root superuser password
          mysql user: ${{ secrets.MYSQL_USER }} # Required if "mysql root password" is empty, default is empty. The superuser for the specified database. Can use secrets, too
          mysql password: ${{ secrets.MYSQL_PASSWORD }} # Required if "mysql user" exists. The password for the "mysql user"
      - name: 3.Build with Gradle
        uses: gradle/gradle-build-action@bd5760595778326ba7f1441bcf7e88b49de61a25 # v2.6.0
        with:
          arguments: build

      - name: 4.Docker Image Build
        run: docker build ./xinfra/docker -t ${{ secrets.DOCKER_USERNAME }}/istory -f ./xinfra/docker/Dockerfile

      - name: 5.Docker Login
        uses: docker/login-action@v3.0.0
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
          logout: true

      - name: 6.Docker Push
        run: docker push ${{ secrets.DOCKER_USERNAME }}/istory
```
