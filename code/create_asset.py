import json
import os
import requests

# local imports
import config
import utils

"""
If you attach your secrets to this capsule, then
uncomment the line below (line 14) and comment out
the line below that (line 15)
"""
# co_api_key_str = f"{os.environ['CUSTOM_KEY']}:"
co_api_key_str = f"{config.co_api_key}:"
co_api_key_base64_str = utils.base64_encode(co_api_key_str)
user = config.user if config.user else "Worksop Attendee"
co_domain = config.co_domain

url = f"https://{co_domain}/api/v1/data_assets"

payload = json.dumps(
    {
        "name": f"{user.capitalize()}'s Fastqs for Coding Workshop",
        "description": "Sample paired end fastq files for the Code Ocean Advanced Coding Workshop",
        "mount": "fastq_paired_end",
        "tags": ["fastq", "workshop"],
        "source": {
            "aws": {
                "bucket": "codeocean-public-data",
                "prefix": "example_datasets/workshop_fastqs/",
            }
        },
    }
)
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Basic {co_api_key_base64_str}",
}

response = requests.request("POST", url, headers=headers, data=payload)

print(response.text)
