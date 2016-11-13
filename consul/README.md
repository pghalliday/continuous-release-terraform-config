# consul

Initialise from remote state with

```
terraform remote config \
    -backend=s3 \
    -backend-config="bucket=continuous-release-terraform" \
    -backend-config="key=consul/terraform.tfstate" \
    -backend-config="region=eu-west-1" \
    -backend-config="encrypt=true" \
    -backend-config="kms_key_id=arn:aws:kms:eu-west-1:735561797792:key/1370ee9f-0821-4035-8524-909190defc7e" \
    -backend-config="profile=crt"
```

Apply with

```
terraform apply
```
