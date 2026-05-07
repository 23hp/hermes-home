# Secret Management
Following steps are not mandatory if you don't use the secrets in this project. Just rename the secret files `*.sops.yaml` to `*.yaml` and set plain secret into them.

To use the secret in `*.sops.yaml` in this project. You need:
1. Intall SOPS and AGE for secret (en/de)cryption
2. Generate the AGE key
3. Setup Bitwarden Secret Manager and store the key with name `SOPS_AGE_KEY`
4. Install Bitwarden Secret Manager CLI to use `bws` command

## Quickly view/change secrets
```bash
bws run -- sops  localhost.sops.yml
```
## In-place encryption
```bash
bws run -- sops -e -i localhost.sops.yml
```