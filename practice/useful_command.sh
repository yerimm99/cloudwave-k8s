# get credential of EKS
aws eks update-kubeconfig --region ap-northeast-2 --name cwave

# test aws cli
aws s3 ls
aws sts get-caller-identity

# aws default profile
aws configure --profile cwave
export AWS_PROFILE=cwave

# kubectl rename context-name
kubectl config rename-context old-name new-name
#kubectl config rename-context arn:aws:eks:ap-northeast-2:533267441482:cluster/cwave eks
#kubectl config rename-context kind-cwave-cluster local

# create docker volume
docker volume create --name local_code --opt type=none --opt device=C:\Users\kdt\cwave-kkk\local_code --opt o=bind
docker volume create --name remote_code --opt type=none --opt device=C:\Users\kdt\cwave-kkk\remote_code --opt o=bind
docker volume create --name cofig --opt type=none --opt device=C:\Users\kdt\cwave-kkk\cofig --opt o=bind