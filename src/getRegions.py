import pymysql
import boto3
import os
import json
import logging

# logger = logging.getLogger()
# logger.setLevel(logging.DEBUG)

hostname = os.environ['RDS_HOSTNAME']
username = os.environ['RDS_USERNAME']
port = 3306
dbname = os.environ['RDS_DBNAME']
region = boto3.session.Session().region_name
os.environ['LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN'] = '1'

client = boto3.client('rds')

# logger.debug( "calling generate_db_auth_token")

token = client.generate_db_auth_token(DBHostname=hostname, Port=port, DBUsername=username)

# logger.debug( "response from generate_db_auth_token")
# logger.debug( token )

rocksend_db_aws = pymysql.connect(
    host=hostname,
    port=port,
    user=username,
    passwd=token,
    db=dbname,
    connect_timeout=2)


def lambda_handler(event, context):
    with rocksend_db_aws.cursor(pymysql.cursors.DictCursor) as cursor:
        area = event['queryStringParameters']['area_id']
        data = cursor.execute(
            """SELECT id, name FROM tb_region where area_id = %s
            order by name;""",
            (area,))

        results = {'regions': []}

        for x in data:
            results['regions'].append({"id": x['id'],
                                       "name": x['name']})

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(results)
        }
