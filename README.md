# Nix for Hermes on Oracle Cloud
This project creat a Nix instance on Oracle Cloud
## Config .env
Creat a `.env` file from the `.env.example` and modify and apply it.
```bash
cp .env.example .env
source .env
```
## Create network
```bash
cd network
terraform init
terraform plan
terraform apply
```

## Create a Nix instance
```bash
cd compute
terraform init
terraform plan
terraform apply
```