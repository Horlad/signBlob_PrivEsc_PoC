import requests
import hashlib
from datetime import timedelta

from google import auth
from google.cloud.storage import Client

credentials, project_id = auth.default()
if credentials.token is None:
		credentials.refresh(auth.transport.requests.Request())

client = Client()

bucket_name = f"signurl_testing_{project_id}"
exp = timedelta(hours=6)

def parse_header(string):
    res = string.partition(":")
    if res[1]:
        return {res[0].strip(): res[2].strip()}
    return {}


def proxy_downloader(request):
    if request.args and 'url' in request.args:
        #Download a file from URL
        res = requests.get(request.args["url"], headers = parse_header(request.args.get("auth", "")))
        file_bytes = res.content
        content_type = res.headers["content-type"]
        hashsum = hashlib.sha256(file_bytes).hexdigest()

        #Uploading a file to a bucket
        bucket = client.get_bucket(bucket_name)
        blob = bucket.blob(hashsum)
        blob.upload_from_string(file_bytes, content_type=content_type)

        #Generating Signed URLs for the uploaded file
        signed_url = blob.generate_signed_url(
            version="v4",
            expiration=exp,
            service_account_email=credentials.service_account_email,
            access_token=credentials.token,
            method="GET"
        )
        print(signed_url)
        return signed_url
    else:
        return f'Use "url" parameter to specify a location of file to download and "auth" parameter for required Authorization headers.'