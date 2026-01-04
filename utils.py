# import
import pandas as pd
import os
import glob
from dotenv import load_dotenv
import re

# Selenium imports
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys  # Added import for Keys
from selenium.webdriver.support.ui import WebDriverWait, Select  # To wait for elements
from selenium.webdriver.support import expected_conditions as EC  # For expected conditions
import time

# AWS imports
import boto3

from selenium import webdriver

# to extract zillow data
def extract_zillow_data(dropdown1_name: str,
                        dropdown2_name: str,
                        dropdown1_value: str,
                        dropdown2_value: str,
                        download_button: str,
                        ):

    """
    Docstring for extract_zillow_data
    
    :param dropdown1_name: Description
    :type dropdown1_name: str
    :param dropdown2_name: Description
    :type dropdown2_name: str
    :param dropdown1_value: Description
    :type dropdown1_value: str
    :param dropdown2_value: Description
    :type dropdown2_value: str
    :param download_button: Description
    :type download_button: str
    :param file_name: Description
    :type file_name: str
    """

    # setting up user agent
    options = webdriver.ChromeOptions()
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")

    # creating chrome webdriver object
    driver = webdriver.Chrome()

    # navtiating to website
    driver.get("https://www.zillow.com/research/data/")

    # maximizing the window
    driver.maximize_window()

    # creating dropdown object after waiting
    dropdown_data = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, dropdown1_name))
    )
    # creating select objet
    select = Select(dropdown_data)

    # select by visible text
    select.select_by_visible_text(dropdown1_value)

    # same thing for second geography dropdown 
    dropdown_geo = WebDriverWait(driver, 10).until(EC.presence_of_element_located(
        (By.ID, dropdown2_name)))
    select = Select(dropdown_geo)
    select.select_by_visible_text(dropdown2_value)

    # finding and clicking on download button
    download_button = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.ID, download_button))
    )

    # clicking the download button
    download_button.click()

    # wait until download complete
    time.sleep(10)

    # closing the driver
    driver.quit()

     # reading the downloaded csv file based on latest modified file in the download directory
    directory_path = r"C:\Users\CharlesYi\Downloads\*.csv"

    list_of_files = glob.glob(directory_path)  # get all csv files in the directory
    latest_file = max(list_of_files, key = os.path.getmtime) # get latest modified file

    # cast to df then save to data folder
    df = pd.read_csv(latest_file)

    # return df
    return df

def save_file(df, file_name: str):
   
    with open(f'data/{file_name}.csv', 'w', newline='', encoding='utf-8') as f:
        df.to_csv(f, index=False)

    print(f"{file_name} data extracted and saved to data folder")

# to upload to aws s3

def upload_to_s3():
    # loading config
    load_dotenv(override=True)
    aws_access_key = os.getenv('AWS_ACCESS_KEY')
    aws_secret_key = os.getenv('AWS_SECRET_KEY')
    bucket=os.getenv('AWS_BUCKET_NAME')

    # creating s3 client
    s3_client = boto3.client('s3',
                            aws_access_key_id=aws_access_key,
                            aws_secret_access_key=aws_secret_key) 

    try:

        file_list = [] # collecting files in data folder

        for root, dirs, files in os.walk("data/"):
            for file in files:
                file_list.append(os.path.join(root, file))

        num_files = len(file_list)
        # check that there is file        
        if num_files > 0:

            # uploading and removing file
            for file in file_list:
                s3_filename= re.sub(r'data/', '', file) # remove directory path
                s3_client.upload_file(file, bucket, s3_filename) # upload to s3
                #os.remove(file) # optional - remove file after uploading to s3

            print(f'Successfully loaded {num_files} file(s) to S3 bucket')
        
        else: 
            print('No files found')

    except Exception as e:
        print(f'Error occured: {e}')
        raise e
