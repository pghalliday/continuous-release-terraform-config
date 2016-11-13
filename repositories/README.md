# repositories

Initialise from remote state with

```
terraform remote config \
    -backend=s3 \
    -backend-config="bucket=continuous-release-terraform" \
    -backend-config="key=repositories/terraform.tfstate" \
    -backend-config="region=eu-west-1" \
    -backend-config="encrypt=true" \
    -backend-config="kms_key_id=arn:aws:kms:eu-west-1:735561797792:key/1370ee9f-0821-4035-8524-909190defc7e" \
    -backend-config="profile=crt"
```

Apply with

```
terraform apply
```

NB. this will create the repositories then build, tag and push the docker containers to them only on initial creation. Updates to the docker containers can then be built and pushed from their respective sub directories as required, following the instructions in their `README.md` files.
