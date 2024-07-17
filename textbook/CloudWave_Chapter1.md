## 1. 쿠버네티스 간단하게 맛보기

### 1.1 도커 허브 이미지로 컨테이너 생성 및 확인

- 컨테이너 생성 : run/v1 으로 수행 합니다.
  
  ```{bash}
  # POD 만 생성
  $ kubectl create deployment nginx --image=nginx
  ```

- 컨테이너 확인
  
  ```{bash}
  $ kubectl get pods
  ```
  
  ```{text}
  $ kubectl get po,deploy
  NAME                         READY   STATUS    RESTARTS   AGE
  pod/nginx-7854ff8877-cxf6r   1/1     Running   0          10s
  
  NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
  deployment.apps/nginx   1/1     1            1           10s
  ```
  
  > 아래 명령어를 추가적으로 수행해 보세요
  > 
  > ```
  > kubectl get pods -o wide
  > kubectl describe pod <pod_name>
  > ```

- k8s 서비스 생성
  
  ```{bash}
  $ kubectl expose deployment nginx --name=nginx-svc --type=LoadBalancer --port 80
  ```
  
  ```{text}
  service/nginx-svc exposed
  ```

- 생성한 서비스 조회
  
  ```{bash}
  $ kubectl get svc
  ```
  
  ```{text}
  NAME         TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)        AGE
  kubernetes   ClusterIP      10.120.0.1       <none>            443/TCP        5h2m
  nginx-svc    LoadBalancer   10.120.130.236   192.168.247.100   80:32484/TCP   3s
  ```

- 서비스 테스트 (여러번 수행)
  
  ```{bash}
  curl http://192.168.247.100
  ```
  
  [출력]
  
  ```{text}
  <!DOCTYPE html>
  <html>
  <head>
  <title>Welcome to nginx!</title>
  <style>
  html { color-scheme: light dark; }
  body { width: 35em; margin: 0 auto;
  font-family: Tahoma, Verdana, Arial, sans-serif; }
  </style>
  </head>
  <body>
  <h1>Welcome to nginx!</h1>
  <p>If you see this page, the nginx web server is successfully installed and
  working. Further configuration is required.</p>
  
  <p>For online documentation and support please refer to
  <a href="http://nginx.org/">nginx.org</a>.<br/>
  Commercial support is available at
  <a href="http://nginx.com/">nginx.com</a>.</p>
  
  <p><em>Thank you for using nginx.</em></p>
  </body>
  </html>
  ```

- POD 삭제

```{bash}
kubectl delete deploy nginx
kubectl delete svc nginx-svc
```

## 2. PODS

### 2.1 POD 기본

- POD 설정을 yaml 파일로 가져오기

```{bash}
kubectl get pod nginx-7854ff8877-4z46b -o yaml
```

크게  **metadata, spec, status** 3가지 항목으로 나누어 집니다.

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2024-07-10T14:55:24Z"
  generateName: nginx-7854ff8877-
  labels:
    app: nginx
    pod-template-hash: 7854ff8877
  name: nginx-7854ff8877-4z46b
  namespace: default
  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: nginx-7854ff8877
    uid: 334ba2b8-2b05-4c1d-96a2-50112c6d2645
  resourceVersion: "29469"
  uid: 766bfed7-69c2-4fc5-8955-4e2a2653a5ce
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-htdzr
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: cwave-cluster-worker2
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: kube-api-access-htdzr
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2024-07-10T14:55:26Z"
    status: "True"
    type: PodReadyToStartContainers
  - lastProbeTime: null
    lastTransitionTime: "2024-07-10T14:55:24Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2024-07-10T14:55:26Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2024-07-10T14:55:26Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2024-07-10T14:55:24Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: containerd://676d1444c8ca634b8e16a0d6140b65750660b128cfdd40ba2fe6e13a6b300485
    image: docker.io/library/nginx:latest
    imageID: docker.io/library/nginx@sha256:67682bda769fae1ccf5183192b8daf37b64cae99c6c3302650f6f8bf5f0f95df
    lastState: {}
    name: nginx
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2024-07-10T14:55:26Z"
  hostIP: 192.168.247.2
  hostIPs:
  - ip: 192.168.247.2
  phase: Running
  podIP: 10.110.2.5
  podIPs:
  - ip: 10.110.2.5
  qosClass: BestEffort
  startTime: "2024-07-10T14:55:24Z"
```

- Pod 삭제

```{bash}
$ kubectl delete deploy nginx
$ kubectl delete svc nginx-svc
```

### 2.2 POD 생성을 위한 YAML 파일 만들기

아래와 같이 goapp.yaml 파일을 만듭니다.

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: goapp-pod
spec:
  containers:
  - image: dangtong/goapp
    name: goapp-container
    ports:
    - containerPort: 8080
      protocol: TCP
```

> ports 정보를 yaml 파일에 기록 하지 않으면 아래 명령어로 향후에 포트를 할당해도 됩니다.
> 
> ```
> $ kubectl port-forward goapp-pod 8080:8080
> 
> Forwarding from 127.0.0.1:8080 -> 8080
> Forwarding from [::1]:8080 -> 8080
> 
> # 다른 터미널을 열어서
> $ curl http://localhost:8080
> 
> hostname: goapp-pod
> 
> $ kubectl exec -it goapp-pod -- bash
> bash-5.0# hostname
> goapp-pod
> ```

### 5.3 YAML 파일을 이용한 POD 생성 및 확인

```{bash}
$ kubectl create -f goapp.yaml
```

[output]

```{txt}
 pod/goapp-pod created
```

```{bash}
$ kubectl get pod
```

[output]

```{txt}
NAME                  READY   STATUS    RESTARTS   AGE
goapp-pod             1/1     Running   0          12m
```

### 5.4 POD 및 Container 로그 확인

- POD 로그 확인

```{bash}
kubectl logs goapp-pod
```

[output]

```{bash}
Starting GoApp Server......
```

- 특정 Container 로그 확인

```{bash}
kubectl logs goapp-pod -c goapp-container
```

[output]

```{bash}
Starting GoApp Server......
```

> 현재 1개 POD 내에 Container 가 1이기 때문에 출력 결과는 동일 합니다. POD 내의 Container 가 여러개 일 경우 모든 컨테이너의 표준 출력이 화면에 출력됩니다.

- Pod 삭제

```{bash}
kubectl delete po goapp-pod
```

### [연습문제 2-1]

아래 정보를 기반으로 POD를  생성 하세요.

| 항목     | 내용           |
| ------ | ------------ |
| 이미지    | nginx:1.18.0 |
| Pod 이름 | nginx-app    |
| Port   | 80           |

1. port-forward를 이용해서 로컬 8080 포트를 nginx 서비스 포트와 연결하세요
2. curl 명령어르 사용해서 nginx 서비스에 접속하세요
3. nginx Pod 의 정보를 yaml 파일로 출력 하세요
4. Nginx Pod의 Bash 에 접속해서 nginx 의 설정파일을 확인하세요
5. nginx-app Pod 를 삭제 하세요

## 3. Lable

### 3.1 Lable 정보를 추가해서 POD 생성하기

- goapp-with-lable.yaml 이라 파일에 아래 내용을 추가 하여 작성 합니다.

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: goapp-pod
  labels:
    env: prod
spec:
  containers:
  - image: dangtong/goapp
    name: goapp-container
    ports:
    - containerPort: 8080
      protocol: TCP
```

- yaml 파일을 이용해 pod 를 생성 합니다.

```{bash}
$ kubectl create -f ./goapp-with-lable.yaml
```

[output]

```{txt}
pod/goapp-pod created
```

- 생성된 POD를 조회 합니다.

```{bash}
kubectl get po --show-labels
```

[output]

```{txt}
NAME                  READY   STATUS    RESTARTS   AGE     LABELS
goapp-pod           1/1     Running   0          3m53s   env=prod
```

- Lable 태그를 출력 화면에 컬럼을 분리해서 출력

```{bash}
kubectl get pod -L env
```

[output]

```{txt}
NAME                  READY   STATUS    RESTARTS   AGE     ENV
goapp-pod            1/1     Running   0          5m19s   prod
```

- Lable을 이용한 필터링 조회

```{bash}
kubectl get pod -l env=prod
```

[output]

```{txt}
NAME         READY   STATUS    RESTARTS   AGE
goapp-pod   1/1     Running   0          39h
```

- Label 추가 하기

```{bash}
kubectl label pod goapp-pod app="application" tier="backend"
```

- Label 삭제 하기

```{bash}
kubectl label pod goapp-pod app- tier-
```

### 3.2 Label 셀렉터 사용

- AND 연산

```{bash}
kubectl get po -l 'app in (application), tier in (backend)'
```

- OR 연산

```{bash}
kubectl get po -l 'app in (application,backEnd)'

kubectl get po -l 'app in (application,frontEnd)'
```

### 3.3 생성된 POD 로 부터 yaml 파일 얻기

```{bash}
kubectl get pod goapp-pod -o yaml
```

[output]

```{txt}
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2020-01-10T08:07:04Z"
  name: goapp-pod
  namespace: default
  resourceVersion: "3086366"
  selfLink: /api/v1/namespaces/default/pods/goapp-pod
  uid: 18cf0ed0-be56-4b54-869c-4473117800b1
spec:
  containers:
  - image: dangtong/goapp
    imagePullPolicy: Always
    name: goapp-container
    ports:
    - containerPort: 8080
      protocol: TCP
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-qz4fh
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: worker02.sas.com
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: default-token-qz4fh
    secret:
      defaultMode: 420
      secretName: default-token-qz4fh
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2020-01-10T08:07:04Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2020-01-10T08:07:09Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2020-01-10T08:07:09Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2020-01-10T08:07:04Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: docker://d76af359c556c60d3ac1957d7498513f42ace14998c763456190274a3e4a1d5e
    image: dangtong/goapp:latest
    imageID: docker-pullable://dangtong/goapp@sha256:e5872256539152aecd2a8fb1f079e132a6a8f247c7a2295f0946ce2005e36d05
    lastState: {}
    name: goapp-container
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2020-01-10T08:07:08Z"
  hostIP: 10.0.2.5
  phase: Running
  podIP: 10.32.0.4
  podIPs:
  - ip: 10.32.0.4
  qosClass: BestEffort
  startTime: "2020-01-10T08:07:04Z"
```

### 3.4 Lable을 이용한 POD 스케줄링

- 노드목록 조회

```{bash}
kubectl get nodes
```

[output]

```{txt}
NAME               STATUS   ROLES    AGE   VERSION
master.sas.com     Ready    master   16d   v1.17.0
worker01.sas.com   Ready    <none>   16d   v1.17.0
worker02.sas.com   Ready    <none>   16d   v1.17.0
```

- 특정 노드에 레이블 부여

```{bash}
kubectl label node worker02.sas.com memsize=high
```

- 레이블 조회 필터 사용하여 조회

```{bash}
kubectl get nodes -l memsize=high
```

[output]

```{txt}
NAME               STATUS   ROLES    AGE   VERSION
worker02.sas.com   Ready    <none>   17d   v1.17.0
```

- 특정 노드에 신규 POD 스케줄링
  
  아래 내용과 같이 goapp-label-node.yaml 파을을 작성 합니다.

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: goapp-pod-memhigh
spec:
  nodeSelector:
    memsize: "high"
  containers:
  - image: dangtong/goapp
    name: goapp-container-memhigh
```

- YAML 파일을 이용한 POD 스케줄링

```{bash}
kubectl create -f ./goapp-lable-node.yaml
```

[output]

```{txt}
pod/goapp-pod-memhigh created
```

- 생성된 노드 조회

```{bash}
kubectl get pod -o wide
```

[output]

```{txt}
NAME                  READY   STATUS    RESTARTS   AGE    IP          NODE               NOMINATED NODE   READINESS GATES
goapp-pod-memhigh     1/1     Running   0          17s    10.32.0.5   worker02.sas.com   <none>           <none>
```

## 4. Annotation

### 4.1 POD 에 Annotation 추가하기

```{bash}
kubectl annotate pod goapp-pod-memhigh maker="dangtong" team="k8s-team"
```

[output]

```{txt}
pod/goapp-pod-memhigh annotated
```

### 4.2 Annotation 확인하기

- YAML 파일을 통해 확인하기

```{bash}
kubectl get po goapp-pod-memhigh -o yaml
```

[output]

```{txt}
kind: Pod
metadata:
  annotations:
    maker: dangtong
    team: k8s-team
  creationTimestamp: "2020-01-12T15:25:05Z"
  name: goapp-pod-memhigh
  namespace: default
  resourceVersion: "3562877"
  selfLink: /api/v1/namespaces/default/pods/goapp-pod-memhigh
  uid: a12c35d7-d0e6-4c01-b607-cccd267e39ec
spec:
  containers:
```

- DESCRIBE 를 통해 확인하기

```{bash}
kubectl describe pod goapp-pod-memhigh
```

[output]

```{txt}
Name:         goapp-pod-memhigh
Namespace:    default
Priority:     0
Node:         worker02.sas.com/10.0.2.5
Start Time:   Mon, 13 Jan 2020 00:25:05 +0900
Labels:       <none>
Annotations:  maker: dangtong
              team: k8s-team
Status:       Running
IP:           10.32.0.5
```

### 4.3 Annotation 삭제

```{bash}
kubectl annotate pod  goapp-pod-memhigh maker- team-
```

### [연습문제 4-1]

- bitnami/apache 이미지로 Pod 를 만들고 tier=FronEnd, app=apache 라벨 정보를 포함하세요 
  - kubectl apply -f ./apache-pod.yaml
- Pod 정보를 출력 할때 라벨을 함께 출력 하세요
  - kubectl get po --show-labels
- app=apache 라벨틀 가진 Pod 만 조회 하세요
  - kubectl get po -l app=apache
- 만들어진 Pod에 env=dev 라는 라벨 정보를 추가 하세요
  - kubectl label po apache-pod env=dev
- created_by=kevin 이라는 Annotation을 추가 하세요 
  - kubectl annotate po apache-pod create_by=kevin
- apache Pod를 삭제 하세요
  - kubectl delete po apache-pod

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  name: goapp-pod-memhigh
spec:
  nodeSelector:
    memsize: "high"
  containers:
  - image: dangtong/goapp
    name: goapp-container-memhigh
```

## 5. Namespace

### 5.1 네임스페이스 조회

```{bash}
kubectl get namespace
```

> kubectl get ns 와 동일함

[output]

```{bash}
NAME              STATUS   AGE
default           Active   17d
kube-node-lease   Active   17d
kube-public       Active   17d
kube-system       Active   17d
```

### 5.2 특정 네임스페이스의 POD 조회

```{bash}
kubectl get pod --namespace kube-system
# kubectl get po -n kube-system
```

> kubectl get pod -n kube-system 과 동일함

[output]

```{txt}
coredns-6955765f44-glcdc                 1/1     Running   0          17d
coredns-6955765f44-h7fbb                 1/1     Running   0          17d
etcd-master.sas.com                      1/1     Running   1          17d
kube-apiserver-master.sas.com            1/1     Running   1          17d
kube-controller-manager-master.sas.com   1/1     Running   1          17d
kube-proxy-gm44f                         1/1     Running   1          17d
kube-proxy-ngqr6                         1/1     Running   0          17d
kube-proxy-wmq7d                         1/1     Running   0          17d
kube-scheduler-master.sas.com            1/1     Running   1          17d
weave-net-2pm2x                          2/2     Running   0          17d
weave-net-4wksv                          2/2     Running   0          17d
weave-net-7j7mn                          2/2     Running   0          17d
```

### 5.3 YAML 파일을 이용한 네임스페이스 생성

- YAML 파일 작성 : first-namespace.yaml 이름으로 파일 작성

```{bash}
apiVersion: v1
kind: Namespace
metadata:
  name: first-namespace
```

- YAML 파일을 이용한 네이스페이스 생성

```{bash}
kubectl create -f first-namespace.yaml
```

[output]

```{txt}
namespace/first-namespace created
```

- 생성된 네임스페이스 확인

```{bash}
kubectl get namespace
kubectl get ns
```

[output]

```{txt}
NAME              STATUS   AGE
default           Active   17d
first-namespace   Active   5s
kube-node-lease   Active   17d
kube-public       Active   17d
kube-system       Active   17d
```

> kubectl create namespace first-namespace 와 동일 합니다.

### 5.4 특정 네임스페이스에 POD 생성

- first-namespace 에 goapp 생성

```{bash}
kubectl create -f goapp.yaml -n first-namespace
```

[output]

```{txt}
pod/goapp-pod created
```

- 생성된 POD 확인하기

```{bash}
kubectl get pod -n first-namespace
```

[output]

```{txt}
NAME        READY   STATUS    RESTARTS   AGE
goapp-pod   1/1     Running   0          12h
```

### 5.5 POD 삭제

```{bash}
kubectl delete pod goapp-pod-memhigh
```

```{bash}
kubectl delete pod goapp-pod
```

```{bash}
kubectl delete pod goapp-pod -n first-namespace
```

> 현재 네임스페이스 에서 존재 하는 모든 리소스를 삭제하는 명령은 아래와 같습니다.
> 
> kubectl delete all --all
> 
> 현재 네임스페이스를 설정하고 조회 하는 명령은 아래와 같습니다.
> 
> ```shell
> # 네임스페이스 설정
> kubectl config set-context --current --namespace=<insert-namespace-name-here>
> # 확인
> kubectl config view --minify | grep namespace:
> ```

### [연습문제 5-1]

1. 쿠버네티스 클러스터에 몇개의 네임스페이가 존재 하나요?
   
   - kubectl get ns

2. my-dev 라는 네임스페이를 생성하고 nginx Pod를 배포 하세요
   
   - kubectl apply -f ./ns.yaml
   
   - kubectl apply -f ./nginx.yaml -n my-dev

3. 현재 네임스페이스(Current Namespace)를 Kube-system 으로 변경 하세요
   
   - kubens kube-system

4. 모든 네임스페이스의 모든 리소스를 한번에 조회 하세요
   
   - kubectl get all --all-namespaces

## 6. kubectl 기본 사용법

### 6.1 단축형 키워드 사용하기

```{bash}
kubectl get po            # PODs
kubectl get svc            # Service
kubectl get rc            # Replication Controller
kubectl get deploy    # Deployment
kubectl get ns            # Namespace
kubectl get no            # Node
kubectl get cm            # Configmap
kubectl get pv            # PersistentVolumns
```

### 6.2 도움말 보기

```{bash}
kubectl -h
```

```{txt}
kubectl controls the Kubernetes cluster manager.

 Find more information at: https://kubernetes.io/docs/reference/kubectl/overview/

Basic Commands (Beginner):
  create         Create a resource from a file or from stdin.
  expose         Take a replication controller, service, deployment or pod and expose it as a new Kubernetes Service
  run            Run a particular image on the cluster
  set            Set specific features on objects

Basic Commands (Intermediate):
  explain        Documentation of resources
  get            Display one or many resources
  edit           Edit a resource on the server
  delete         Delete resources by filenames, stdin, resources and names, or by resources and label selector

Deploy Commands:
```

```{bash}
kubectl get -h
```

```{txt}
Display one or many resources

 Prints a table of the most important information about the specified resources. You can filter the list using a label
selector and the --selector flag. If the desired resource type is namespaced you will only see results in your current
namespace unless you pass --all-namespaces.

 Uninitialized objects are not shown unless --include-uninitialized is passed.

 By specifying the output as 'template' and providing a Go template as the value of the --template flag, you can filter
the attributes of the fetched resources.

Use "kubectl api-resources" for a complete list of supported resources.

Examples:
  # List all pods in ps output format.
  kubectl get pods

  # List all pods in ps output format with more information (such as node name).
  kubectl get pods -o wide
```

### 6.3 리소스 정의에 대한 도움말

```{bash}
kubectl explain pods
```

```{txt}
KIND:     Pod
VERSION:  v1

DESCRIPTION:
     Pod is a collection of containers that can run on a host. This resource is
     created by clients and scheduled onto hosts.

FIELDS:
   apiVersion    <string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources

   kind    <string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds

   metadata    <Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

   spec    <Object>
     Specification of the desired behavior of the pod. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

   status    <Object>
     Most recently observed status of the pod. This data may not be up to date.
     Populated by the system. Read-only. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
```

### 6.4 리소스 감시하기

- Kube-system 네임스페이스에 있는 모든 pod에 대해 모니터링 합니다.

```{bash}
kubectl get pods --watch -n kube-system
```

```{txt}
root@master:~# k get pods --watch -n kube-system
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-6955765f44-glcdc                 1/1     Running   0          19d
coredns-6955765f44-h7fbb                 1/1     Running   0          19d
etcd-master.sas.com                      1/1     Running   1          19d
kube-apiserver-master.sas.com            1/1     Running   1          19d
kube-controller-manager-master.sas.com   1/1     Running   1          19d
kube-proxy-gm44f                         1/1     Running   1          19d
kube-proxy-ngqr6                         1/1     Running   0          19d
kube-proxy-wmq7d                         1/1     Running   0          19d
kube-scheduler-master.sas.com            1/1     Running   1          19d
weave-net-2pm2x                          2/2     Running   0          19d
weave-net-4wksv                          2/2     Running   0          19d
weave-net-7j7mn                          2/2     Running   0          19d
...
```

### 6.5 kubectx 및 kubens 사용하기

현재 컨텍스트 및 네임스페이스를 확인하고 전환 할때 손쉽게 사용 할수 있는 도구

- kubectx 및 kubens 설치

```{bash}
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx

cat << FOE >> ~/.bashrc
export PATH=~/.kubectx:\$PATH
FOE
```

- kubectx 사용

```{bash}
kubectx
kubectx <변경하고 싶은 컨텍스트 이름>
```

- kubens 사용

현재 사용중인 네임스페이스를 조회 합니다. 현재 사용중인 네이스페이스는 하이라이트 됩니다.

```{bash}
kubens
```

```{txt}
default
first-namespace
kube-node-lease
kube-public
kube-system
```

Kube-system 네이스페이스로 전환 해봅니다.

```{bash}
kubens kube-system
```

```{txt}
Context "kubernetes-admin@kubernetes" modified.
Active namespace is "kube-system".
```

pod 조회 명령을 내리면 아래와 같이 kube-system 네임스페이스의 pod 들이 조회 됩니다.

```{bash}
kubectl get po
```

```{bash}
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-6955765f44-glcdc                 1/1     Running   0          34d
coredns-6955765f44-h7fbb                 1/1     Running   0          34d
etcd-master.sas.com                      1/1     Running   1          34d
kube-apiserver-master.sas.com            1/1     Running   1          34d
kube-controller-manager-master.sas.com   1/1     Running   1          34d
kube-proxy-gm44f                         1/1     Running   1          34d
kube-proxy-ngqr6                         1/1     Running   0          34d
kube-proxy-wmq7d                         1/1     Running   0          34d
kube-scheduler-master.sas.com            1/1     Running   1          34d
weave-net-2pm2x                          2/2     Running   0          34d
weave-net-4wksv                          2/2     Running   0          34d
weave-net-7j7mn                          2/2     Running   0          34d
```

### 6.6 kubernetes 컨텍스트 및 네임스페이스 표시하기

kube-ps1을 다운로드 하여 /usr/local/kube-ps1 설치 하고 .bashrc 파일에 아래와 같이 설정 합니다. [링크](https://github.com/jonmosco/kube-ps1)

```{bash}
source /usr/local/kube-ps1/kube-ps1.sh
PS1='[\u@\h \W $(kube_ps1)]\$ '
```

```{bash}
[root@master ~ (⎈ |kubernetes-admin@kubernetes:kube-public)]#
```

### 6.7 kubectl Context

. kube 디렉토리의 config 에 virtualBox 에 

- Context 조회

```{bash}
kubectl config get-contexts
```

- Context 변경

```{bash}
kubectl config get-contexts 
# get-contexts 결과에서 혹인후 아래 명령어로 현재 클러스터 변경
kubectl config use-context <Context-Name>
```

- Context 삭제

```{bash}
kubectl config delete-cluster [cluster-name]
kubectl config delete-context [context-name]
kubectl config delete-user [user-name]

or 

kubectl config unset users.[cluster-name]
kubectl config unset contexts.[context-name]
kubectl config unset clusters.[context-name]
```

> google cloud 에서는 cluster-name, context-name, user-name.  이 모두 동일함

### 6.8 alias 만들기

- Linux 및 MAC

```{bash}
alias chks='kubectl config use-context'
alias lsks='kubectl config get-contexts'
```

- Windows

```{powershell}
Set-Alias chks 'kubectl config use-context'
Set-Alias lsks 'kubectl config get-contexts'
```

## 7. Liveness probes

liveness prove는 Pod에 지정된 주소에 Health Check 를 수행하고 실패할 경우 Pod를 다시 시작 합니다.

이때 중요한 점은 단순히 다시 시작만 하는 것이 아니라, 리포지토리로 부터 이미지를 다시 받아 Pod 를 다시 시작 합니다.

아래 내용으로.

```{yaml}
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/liveness
    args:
    - /server
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: Custom-Header
          value: Awesome
      initialDelaySeconds: 3
      periodSeconds: 3
```

K8s.gcr.io/liveness 이미지는 liveness 테스트를 위해 만들어진 이미지 입니다. Go 언어로 작성 되었으며, 처음 10초 동안은 정상적인 서비스를 하지만, 10초 후에는 에러를 발생 시킵니다. 자세한 사항은 [URL](https://github.com/kubernetes/kubernetes/blob/master/test/images/agnhost/liveness/server.go) 을 참고 하세요

### 7.1 Pod 생성

```{bash}
kubectl create -f ./liveness-probe-pod.yaml
```

### 7.2 Pod 확인

```{bash}
kubectl get pod
```

아래

```{txt}
NAME            READY   STATUS    RESTARTS   AGE
liveness-http   1/1     Running   0          5s

NAME            READY   STATUS    RESTARTS   AGE
liveness-http   1/1     Running   1          26s

NAME            READY   STATUS    RESTARTS   AGE
liveness-http   1/1     Running   3          68s

NAME            READY   STATUS             RESTARTS   AGE
liveness-http   0/1     CrashLoopBackOff   3          81s

NAME            READY   STATUS             RESTARTS   AGE
liveness-http   0/1     CrashLoopBackOff   5          2m50s
```

### 7.3 Pod 로그 이벤트 확인

```{bash}
kubectl describe pod liveness-http
```

```{txt}
Name:         liveness-http
Namespace:    default
Priority:     0
Node:         worker02.acorn.com/192.168.56.110
Start Time:   Wed, 01 Apr 2020 05:54:29 +0000
Labels:       test=liveness
Annotations:  <none>
Status:       Running
IP:           10.36.0.1
IPs:
  IP:  10.36.0.1
Containers:
  liveness:
    Container ID:  docker://0f1ba830b830d5879fe99776cd0db5f3678bf52a11e3ccb1a1e9c65460957817
    Image:         k8s.gcr.io/liveness
    Image ID:      docker-pullable://k8s.gcr.io/liveness@sha256:1aef943db82cf1370d0504a51061fb082b4d351171b304ad194f6297c0bb726a
    Port:          <none>
    Host Port:     <none>
    Args:
      /server
    State:          Running
      Started:      Wed, 01 Apr 2020 06:01:15 +0000
    Last State:     Terminated
      Reason:       Error
      Exit Code:    2
      Started:      Wed, 01 Apr 2020 05:58:16 +0000
      Finished:     Wed, 01 Apr 2020 05:58:32 +0000
    Ready:          True
    Restart Count:  7
    Liveness:       http-get http://:8080/healthz delay=3s timeout=1s period=3s #success=1 #failure=3
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-zshgs (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  default-token-zshgs:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-zshgs
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason     Age                    From                         Message
  ----     ------     ----                   ----                         -------
  Normal   Scheduled  <unknown>              default-scheduler            Successfully assigned default/liveness-http to worker02.acorn.com
  Normal   Pulled     6m14s (x3 over 6m53s)  kubelet, worker02.acorn.com  Successfully pulled image "k8s.gcr.io/liveness"
  Normal   Created    6m14s (x3 over 6m52s)  kubelet, worker02.acorn.com  Created container liveness
  Normal   Started    6m14s (x3 over 6m52s)  kubelet, worker02.acorn.com  Started container liveness
  Normal   Pulling    5m55s (x4 over 6m54s)  kubelet, worker02.acorn.com  Pulling image "k8s.gcr.io/liveness"
  Warning  Unhealthy  5m55s (x9 over 6m40s)  kubelet, worker02.acorn.com  Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    5m55s (x3 over 6m34s)  kubelet, worker02.acorn.com  Container liveness failed liveness probe, will be restarted
  Warning  BackOff    108s (x17 over 5m36s)  kubelet, worker02.acorn.com  Back-off restarting failed container
```

로그이벤트를 보면 Liveness Probe 가 실패해서 컨테이너를 재가동 하는 메시지가 보입니다.

뿐만아니라, 재가동 시에서 Pull image 를 통해 이미지를 다시 가져 와서 재가동 시키는 것을 볼 수 있습니다.

## 8. Replication Controller

### 8.1 Replication Controller 생성

아래와 같이 template를 작성합니다.

```{yaml}
apiVersion: v1
kind: ReplicationController
metadata:
  name: goapp-rc
spec:
  replicas: 3
  selector:
    app: goapp
  template:
    metadata:
      name: goapp-pod
      labels:
        tier: forntend
        app: goapp
        env: prod
        priority:  high
    spec:
      containers:
      - name: goapp-container
        image: dangtong/goapp
        ports:
        - containerPort: 8080
```

### 8.2 Pod 생성

```{bash}
kubectl create -f ./rc-goapp.yaml
```

### 8.3 Pod 생성 확인

```{bash}
kubectl get po

NAME             READY   STATUS    RESTARTS   AGE
goapp-rc-9q689   1/1     Running   0          39s
goapp-rc-d5rnf   1/1     Running   0          39s
goapp-rc-fm7kr   1/1     Running   0          39s
```

### 8.4 Replication Controller 확인

```{bash}
kubectl get rc

NAME       DESIRED   CURRENT   READY   AGE
goapp-rc   3         3         3       58s

kubectl get rc -o wide

NAME       DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES           SELECTOR
goapp-rc   3         3         3       72s   goapp-container   dangtong/goapp   app=goapp
```

### 8.5 특정 Pod 삭제하고 변화 확인하기

아래와 같이 3개의 Pod 중에 하나를 선택해서 삭제 합니다.

- 첫번째 터미널에서 pod 모니터링

```{bash}
kubectl get pod -w

NAME             READY   STATUS                            RESTARTS   AGE
goapp-rc-d5rnf   1/1     Running                           0          2m
goapp-rc-fm7kr   1/1     Running                           0          2m
goapp-rc-szv2r   1/1     ContainerCreating       0          6s
```

- 두번째 터미널에서 Pod 삭제

```{bash}
kubectl delete pod goapp-rc-9q689
```

기존 컨테이너를 Terminating 하고 새로운 컨테이너를 생성하는 것을 볼 수 있습니다.

### 8.6 Pod 정보를 라벨과 함께 출력해보기

```{bash}
kubectl get pod --show-labels

NAME             READY   STATUS    RESTARTS   AGE     LABELS
goapp-rc-d5rnf   1/1     Running   0          7m26s   app=goapp
goapp-rc-fm7kr   1/1     Running   0          7m26s   app=goapp
goapp-rc-szv2r   1/1     Running   0          4m51s   app=goapp
```

### 8.7 특정 Pod 라벨을 변경해보기

- 첫번째 터미널에서 Pod 상태 모니터링 하기

```{bash}
kubectl get po -w

NAME             READY   STATUS              RESTARTS   AGE
goapp-rc-d5rnf   1/1     Running             0          8m49s
goapp-rc-fm7kr   1/1     Running             0          8m49s
goapp-rc-mmn2b   0/1     ContainerCreating   0          5s
goapp-rc-szv2r   1/1     Running             0          6m14s
```

- Pod의 라벨 변경하기

​    기존 "app=nginx" 라는 label 을 "app=goapp-exit" 로 변경 합니다.

```{bash}
kubectl label pod goapp-rc-szv2r app=goapp-exit --overwrite
```

- 첫번째 터미널에서 Pod 변화 확인하기

기존 3개의 Pod 중 하나의 Label을 변경하면 기존 app=goapp 에는 2개의 Pod 만 남기 때문에 Replication Controller 는 **추가적으로 하나의 Pod 를 생성** 합니다.

```{bash}
goapp-rc-6ldbn   1/1     Running   0          6m20s
goapp-rc-6ldbn   1/1     Running   0          6m20s
goapp-rc-l9cnd   0/1     Pending   0          0s
goapp-rc-l9cnd   0/1     Pending   0          0s
goapp-rc-l9cnd   0/1     ContainerCreating   0          0s
goapp-rc-l9cnd   1/1     Running             0          3s
```

### 8.8 Pod Template 변경 해보기

아래와 같이 Pod Template의 spec ➢ spec ➢ containers ➢ image 항목을 dangtong/goapp-v2 로 변경 합니다.

```{bash}
kubectl edit rc nginx
```

```{yaml}
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: ReplicationController
metadata:
  creationTimestamp: "2020-04-01T09:32:23Z"
  generation: 1
  labels:
    app: goapp
  name: goapp-rc
  namespace: default
  resourceVersion: "405444"
  selfLink: /api/v1/namespaces/default/replicationcontrollers/goapp-rc
  uid: 17198300-d964-4de6-a160-825a7a9c16bf
spec:
  replicas: 3
  selector:
    app: goapp
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: goapp
      name: goapp-pod
    spec:
      containers:
      - image: dangtong/goapp-v2 # 이부분을 변경 합닏다.(기존 : dangtong/goapp)
        imagePullPolicy: Always
        name: goapp-container
        ports:
        - containerPort: 80
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 3
  fullyLabeledReplicas: 3
  observedGeneration: 1
  readyReplicas: 3
  replicas: 3
```

저장후 편집기를 종료 합니다.

> 리눅스 편집기에는 다양한 종류가 있습니다. 만약 기본 편집기를 변경하고 싶으면
> 
> KUBE_EDITOR="/bin/nano" 를 $HOME/.bashrc 파일에 선언 해주면 원하는 편집기를 사용 할수 있습니다.

### 8.9 Pod Template를 적용하기 위해 임의의 Pod 삭제하기

- 첫번째 터미널에서 Pod 모니터링

```{bash}
kubectl get pod -w

goapp-rc-fdsbk   1/1     Running   0          3h6m    10.36.0.2   worker02.acorn.com
goapp-rc-vzjds  1/1     Running   0          6m26s   10.32.0.2   worker01.acorn.com
goapp-rc-l9cnd   1/1     Running   0          3h6m    10.36.0.1   worker02.acorn.com
```

- 두번째 터미널에서 Pod 삭제

```{bash}
kubectl delete pod goapp-rc-fdsbk

pod "goapp-rc-fdsbk" deleted
```

- Pod 확인

```{bash}
goapp-rc-fdsbk   1/1     Terminating         0          21m
goapp-rc-zc9s4   0/1     Pending             0          0s
goapp-rc-zc9s4   0/1     Pending             0          0s
goapp-rc-zc9s4   0/1     ContainerCreating   0          0s
goapp-rc-fdsbk   0/1     Terminating         0          21m
goapp-rc-fdsbk   0/1     Terminating         0          21m
goapp-rc-fdsbk   0/1     Terminating         0          21m
goapp-rc-fdsbk   0/1     Terminating         0          21m
goapp-rc-zc9s4   1/1     Running             0          8s
```

- 로그 확인

```{bash}
# dangtong/goapp
kubectl logs goapp-rc-l9cnd

Starting GoApp Server......

# dangtong/goapp-v3
kubectl logs goapp-rc-zc9s4

Starting GoApp Server V2......
```

여기서 알수 있는 중요한 사실은 이미지를 변경 하더라도 **바로 적용 되는 것이 아니라**, **Pod 를 반드시 재시작** 해야 한다는 것입니다.

### 8.10 Pod 스케일링

- Template 변경을 통한 스케일링
  
  아래와 같이 goapp-rc 를 edit 명령으로 수정 합니다. (replicas 항목을 3에서 4로 수정)

```{bash}
kubectl edit rc goapp-rc
```

```{yaml}
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: ReplicationController
metadata:
  creationTimestamp: "2020-04-01T09:51:49Z"
  generation: 3
  labels:
    app: goapp
  name: goapp-rc
  namespace: default
  resourceVersion: "416408"
  selfLink: /api/v1/namespaces/default/replicationcontrollers/goapp-rc
  uid: 23f58f51-88ab-4828-9a76-cde8a646fff4
spec:
  replicas: 4  # 이부분을 변경 합니다. (기존 : 3)
  selector:
    app: goapp
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: goapp
      name: goapp-pod
    spec:
      containers:
      - image: dangtong/goapp-v2
        imagePullPolicy: Always
        name: goapp-container
        ports:
```

저장 한다음 Pod 및 RC 확인

```{bash}
kubectl get pod

NAME             READY   STATUS              RESTARTS   AGE
goapp-rc-bf2xk   1/1     Running             0          19m
goapp-rc-mr6kb   0/1     ContainerCreating   0          7s
goapp-rc-qkrpw   1/1     Running             0          26m
goapp-rc-x6q4d   1/1     Running             0          3h26m
```

```{bash}
kubectl get rc

NAME       DESIRED   CURRENT   READY   AGE
goapp-rc   4         4         4       4h17m
```

- 명령어를 통한 스케일링

명령어를 이용해서 스케일링을 수행 할 수 있습니다.

```{bash}
kubectl scale rc goapp-rc --replicas=5
```

실제로 Pod 가 늘어 났는지 확인해봅니다.

```{bash}
kubectl get pod

NAME             READY   STATUS              RESTARTS   AGE
goapp-rc-bf2xk   1/1     Running             0          72m
goapp-rc-dlgfc   0/1     ContainerCreating   0          4s
goapp-rc-mr6kb   1/1     Running             0          53m
goapp-rc-qkrpw   1/1     Running             0          79m
goapp-rc-x6q4d   1/1     Running             0          4h19m
```

### 8.11 Replication Controller 삭제

Replication Controller 와 POD 모두 삭제

```{bash}
kubectl delete rc goapp-rc
```

Replication Controller 만 삭제. POD 는 그대로 유지 합니다.

```{bash}
kubectl delete rc goapp-rc --cascade=orphan
```

## 9.ReplicaSet

### 9.1 RS 생성

Selector 를 작성 할때 **ForntEnd** 이고 **운영계** 이면서 중요도가 **High** 인 POD 에 대해 RS 를 생성 합니다.

```{yaml}
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
    matchExpressions:
      - {key: env, operator: In, values: [prod]}
      - {key: priority, operator: NotIn, values: [low]}
  template:
    metadata:
      labels:
        tier: frontend
        env: prod
        priority: high
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
```

### 9.2 RS 확인

```{bash}
$ kubectl get pod -o wide

NAME             READY   STATUS    RESTARTS   AGE   IP          NODE
frontend-bstms   1/1     Running   0          53s   10.32.2.7   gke-gke1-default-pool-ad44d907-cq8j
frontend-d4znb   1/1     Running   0          53s   10.32.2.9   gke-gke1-default-pool-ad44d907-cq8j
frontend-rv9bl   1/1     Running   0          53s   10.32.2.8   gke-gke1-default-pool-ad44d907-cq8j
```

```{bash}
$ kubectl get rs -o wide

AME             READY   STATUS    RESTARTS   AGE   IP          NODE
frontend-bstms   1/1     Running   0          68s   10.32.2.7   gke-gke1-default-pool-ad44d907-cq8j
frontend-d4znb   1/1     Running   0          68s   10.32.2.9   gke-gke1-default-pool-ad44d907-cq8j
frontend-rv9bl   1/1     Running   0          68s   10.32.2.8   gke-gke1-default-pool-ad44d907-cq8j
```

```{bash}
$ kubectl get pod --show-labels

NAME             READY   STATUS    RESTARTS   AGE    LABELS
frontend-bstms   1/1     Running   0          107s   env=prod,priority=high,tier=frontend
frontend-d4znb   1/1     Running   0          107s   env=prod,priority=high,tier=frontend
frontend-rv9bl   1/1     Running   0          107s   env=prod,priority=high,tier=frontend
```

### [연습문제 9-1]

1. nginx:1.9.1 Pod 3개로 구성된 Replication Controller를 작성 하세요
2. Replication Controller 만 삭제 하세요 (Pod 는 유지)
3. 남겨진 nginx Pod를 관리하는 ReplicaSet 을 작성하된 replica 4개로 구성 하세요
4. nginx Pod 를 6개로 Scale Out 하세요

## 10.DaemonSet

### 10.1 데몬셋 생성

goapp-ds.yaml 이라는 이름으로 아래 파일을 작성 합니다.

```{yaml}
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: goapp-on-ssd
spec:
  selector:
    matchLabels:
      app: goapp-pod
  template:
    metadata:
      labels:
        app: goapp-pod
    spec:
      nodeSelector:
        disk: ssd
      containers:
      - name: goapp-container
        image: dangtong/goapp
```

데몬셋을 생성 합니다.

```{bash}
$ kubectl create -f ./goapp-ds.yaml
```

Pod 와 데몬셋을 조회 합니다.

```{bash}
$ kubectl get pod

$ kubectl get ds

NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
goapp-on-ssd   0         0         0       0            0           disk=ssd        <nome>
```

조회 하면 Pod 도 존재하지 않고 데몬셋 정보를 조회 해도 모두 0 으로 나옵닏다. 노드에 disk=ssd 라벨이 없기 때문입니다.

이제 라벨을 추가 합니다.

```{bash}
$ kubectl label node worker01.acorn.com disk=ssd

$ kubectl get pod
NAME                 READY   STATUS    RESTARTS   AGE
goapp-on-ssd-vwvks   1/1     Running   0          7s

$ kubectl label node worker02.acorn.com disk=ssd

$ kubectl get pod
NAME                 READY   STATUS    RESTARTS   AGE
goapp-on-ssd-nbnwz   1/1     Running   0          7s
goapp-on-ssd-vwvks   1/1     Running   0          36s

$ kubectl get ds -o wide
AME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
goapp-on-ssd   2         2         2       2            2           disk=ssd        10m
```

### [연습문제 10-1]

1. 데몬셋은 어떤 용도로 사용되는지 생각해봅니다.
2. 현재 쿠버네티스에서 DaemonSet 으로 실행중인 Pod를 찾아 봅니다

## 11.Deployment

### 11.1 Deployment 생성

아래와 같이 nginx 를 서비스 하고 replica 가 3개인 Deployment 를 작성합니다.(nginx-deploy.yaml)

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
  strategy:
    type: RollingUpdate # Recreate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.1
        ports:
        - containerPort: 80
```

```{bash}
kubectl apply -f ./nginx-deploy.yaml
```

### 11.2 Deployment 확인

```{bash}
kubectl get pod,rs,deploy
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-54f57cf6bf-dpsn4   1/1     Running   0          30s
pod/nginx-deployment-54f57cf6bf-ghfwm   1/1     Running   0          30s
pod/nginx-deployment-54f57cf6bf-rswwk   1/1     Running   0          30s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-54f57cf6bf   3         3         3       30s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   3/3     3            3           30s
```

### 11.3 이미지 업데이트

- yaml 파일 변경

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
  strategy:
    type: RollingUpdate # Recreate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.9.1 # 버전 변경
        ports:
        - containerPort: 80
```

- 새창 열어 모니터링

```{bash}
kubectl get po -w
```

- 적용

```{bash}
kubectl apply -f ./nginx-deply.yaml
```

- yaml 파일 수정

```{bash}
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
  strategy:
    type: RollingUpdate # Recreate
    rollingUpdate:
      maxUnavailable: 2 # 변경 부분 
      maxSurge: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.9.1
        ports:
        - containerPort: 80
```

- 이미지를 명령어로 변경

```{yaml}
kubectl set image deployment.apps/nginx-deployment nginx=nginx:latest
```

> --record 옵션은 향후 deprecated 될 예정임

- Annotation으로  히스토리 기록하기

```{bash}
kubectl annotate deployment nginx-deployment kubernetes.io/change-cause="change maxUnavailable to 2 and updated image to nginx:latest" 
```

- rollout History 조회

```shell
$ kubectl rollout history deploy nginx-deployment
```

```{text}
[output]
REVISION  CHANGE-CAUSE
1         <none>
3         updated image to nginx:1.9.1
4         change maxUnavailable to 2 and updated image to nginx:latest
```

- rollback 수행

```{bash}
$ kubectl rollout undo deploy nginx-deployment --to-revision=1
```

### 11.4 Deployment ScaleOut

- Pod 5개 까지 확장하기

```{bash}
kubectl scale deployment nginx-deployment --replicas=5
deployment.apps/nginx-deployment scaled
```

```{txt}
[output]
deployment.apps/nginx-deployment scaled
```

- 확장된 Pod 확인하기

```{bash}
kubectl get po
```

```{txt}
[output]
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-9d6cbcc65-j4qx6   1/1     Running   0          22s
nginx-deployment-9d6cbcc65-l4dsd   1/1     Running   0          22s
nginx-deployment-9d6cbcc65-mlq7s   1/1     Running   0          2m35s
nginx-deployment-9d6cbcc65-nhmjj   1/1     Running   0          2m35s
nginx-deployment-9d6cbcc65-rbvgn   1/1     Running   0          2m35s
```

### 11.4 deployment 상태 확인 하기

```{bash}
kubectl describe deploy nginx-deployment
```

```{txt}
[output]
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Sun, 14 Jul 2024 17:14:09 +0900
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision: 5
Selector:               app=nginx
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  2 max unavailable, 1 max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx:1.7.9
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deployment-54b6f7ddf9 (0/0 replicas created), nginx-deployment-7ffd5c8dc9 (0/0 replicas created)
NewReplicaSet:   nginx-deployment-9d6cbcc65 (5/5 replicas created)
Events:
  Type    Reason             Age                From                   Message
  ----    ------             ----               ----                   -------
  Normal  ScalingReplicaSet  53m                deployment-controller  Scaled up replica set nginx-deployment-9d6cbcc65 to 3
  Normal  ScalingReplicaSet  52m                deployment-controller  Scaled up replica set nginx-deployment-54b6f7ddf9 to 1
  Normal  ScalingReplicaSet  52m                deployment-controller  Scaled down replica set nginx-deployment-9d6cbcc65 to 2 from 3
  Normal  ScalingReplicaSet  52m                deployment-controller  Scaled up replica set nginx-deployment-54b6f7ddf9 to 2 from 1
  Normal  ScalingReplicaSet  52m                deployment-controller  Scaled down replica set nginx-deployment-9d6cbcc65 to 1 from 2
  Normal  ScalingReplicaSet  52m                deployment-controller  Scaled up replica set nginx-deployment-54b6f7ddf9 to 3 from 2
  Normal  ScalingReplicaSet  52m                deployment-controller  Scaled down replica set nginx-deployment-9d6cbcc65 to 0 from 1
  Normal  ScalingReplicaSet  42m                deployment-controller  Scaled up replica set nginx-deployment-7ffd5c8dc9 to 1
  Normal  ScalingReplicaSet  42m                deployment-controller  Scaled down replica set nginx-deployment-54b6f7ddf9 to 2 from 3
  Normal  ScalingReplicaSet  42m                deployment-controller  Scaled up replica set nginx-deployment-7ffd5c8dc9 to 2 from 1
```

### [연습문제 11 -1]

1. 아래 조건에 맞는 Deployment 를 생성 하세요
- Deployment 사양

| 항목       | 내용               |
| -------- | ---------------- |
| kind     | Deployment       |
| image    | httpd:2.3-alpine |
| replicas | 5                |

- 서비스 조건

| 항목             | 내용  |
| -------------- | --- |
| 최소 서비스 인스턴스 개수 | 2개  |
| 최대 인스턴스수 제한    | 7개  |

- maxSurge: 2, maxUnavailable: 3 // 5 + 2 = 7, 5 - 3 = 2
2. Deployemnt 의 image 를 httpd:2.4-appine 으로 변경하세요

3. 변경 사유를 Rollout History 에 남기세요
   
   - kubectl annotate deployment nginx-deployment kubernetes.io/change-cause="updated image to httpd:2.4-appine"

4. 전체 인스턴스 개수를 7개 까지 확장하세요
