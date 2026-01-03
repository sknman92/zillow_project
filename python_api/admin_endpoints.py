from dotenv import load_dotenv
import os
import requests
import pandas as pd

# loading .env file
load_dotenv(override=True)

# config
dbt_pat = os.getenv("dbt_pat") # fetchind dbt PAT
access_url = os.getenv("access_url") # fetching dbt Cloud account URL
dbt_account_id = os.getenv("dbt_account_id") # fetching dbt Cloud account ID

# creating headers
headers = {"Accept": "application/json",
"Authorization": f"Token {dbt_pat}"}

# function for hitting endpoint
def admin_api(endpoint: str, offset: int = 0) -> pd.DataFrame:
    url_formatted = f"{access_url}api/v2/accounts/{dbt_account_id}/{endpoint}/"

    # params for offsetting pagination
    params = {"offset": offset}

    response = requests.get(url = url_formatted, headers=headers, params=params)
    content = response.json()

    # total count
    total_count = content.get("extra", {}).get("pagination", {}).get("total_count", 0)

    df = pd.json_normalize(content['data'])
    return df, total_count

# pagination
df_list = []
offset = 0
while True:
    df, total_count = admin_api("runs", offset=offset)
    df_list.append(df)
    df_final = pd.concat(df_list, ignore_index=True)
    if len(df_final) >= total_count:
        break
    else:
        offset += len(df)
        print(f"Fetched {len(df_final)} of {total_count} records...")


# final df
df_final.to_clipboard()
        
