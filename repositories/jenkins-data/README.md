# jenkins-data

Docker volume container to persist Jenkins state

## Usage

Run the docker command to authenticate docker with the registry

```
$(aws ecr get-login --region eu-west-1)
```

Build

```
docker build -t jenkins-data .
```

Tag and push to the registry

```
REPOSITORY=$(cd .. && terraform output jenkins-data | sed 's/https:\/\///')
docker tag jenkins-data:latest $REPOSITORY:latest
docker push $REPOSITORY:latest
```
