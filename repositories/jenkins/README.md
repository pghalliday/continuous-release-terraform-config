# jenkins

Docker container to run Jenkins

## Usage

Run the docker command to authenticate docker with the registry

```
$(aws ecr get-login --region eu-west-1)
```

Build

```
docker build -t jenkins .
```

Tag and push to the registry

```
REPOSITORY=$(cd .. && terraform output jenkins | sed 's/https:\/\///')
docker tag jenkins:latest $REPOSITORY:latest
docker push $REPOSITORY:latest
```
