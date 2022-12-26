# README

## AUTHENTICATE TERRAFORM:
To authenticate terraform:
```
gcloud auth application-default login
```

## AUTHENTICATE DOCKER:
To authenticate docker:
```
gcloud auth login
```

## DEPLOY ADMIN
To deploy admin:
```
cd admin
terraform init
terraform plan
terraform apply
```

## DEPLOY INFRAS
To deploy infras:
```
lpass show --notes pers/infras/env > .env
source .env
cd infras
terraform init
terraform plan
terraform apply
```
## BUILD, PUSH, DEPLOY CONTAINER LOCALLY
To build and push container locally:
```
cd container
docker build -t auth .
docker rm -f auth
docker run -d --name auth -p 5080:80 -p 5000:5000 auth
```

## BUILD, PUSH, DEPLOY CONTAINER REMOTELY
To build and push container remotely:
```
cd container
docker build -t auth .
docker tag auth gcr.io/djpb-1313/auth:latest
docker push gcr.io/djpb-1313/auth:latest
gcloud --project=djpb-1313 run services update auth --region=europe-west1 --image=gcr.io/djpb-1313/auth:latest
```

## OTHER COMMANDS
```
docker exec -it gateway bash
gcloud --project djpb-1313 compute instances stop gateway
gcloud --project djpb-1313 compute instances start gateway
gcloud --project djpb-1313 compute ssh gateway
pip install google-api-python-client
pip install google-cloud-compute
```
