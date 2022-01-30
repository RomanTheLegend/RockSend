import mysql.connector
import os
import json

os.environ['LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN'] = '1'


hostname = os.environ['RDS_HOSTNAME']
username = os.environ['RDS_USERNAME']
port = 3306
dbname = os.environ['RDS_DBNAME']
password = os.environ['RDS_PASS']

mydb = mysql.connector.connect(
    host=hostname,
    user=username,
    port=3306,
    password=password,
    database=dbname
)


def lambda_handler(event, context):
    cursor = mydb.cursor(dictionary=True)
    cursor.execute("SELECT id as areaId, name as areaName FROM tb_area order by name")

    data = cursor.fetchall()
    results = {'area': []}
    for x in data:
        results['area'].append({"id": x['areaId'], "name": x['areaName']})

    return json.dumps(results)
