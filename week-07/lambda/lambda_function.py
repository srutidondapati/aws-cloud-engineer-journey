import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Properties')

def _default(o):
    if isinstance(o, Decimal):
        return int(o) if o % 1 == 0 else float(o)
    raise TypeError

def lambda_handler(event, context):
    listing_id = event['pathParameters']['id']
    resp = table.get_item(Key={'L_ListingID': listing_id})
    item = resp.get('Item')
    if not item:
        return {'statusCode': 404, 'body': json.dumps({'error': 'not found'})}
    return {'statusCode': 200, 'body': json.dumps(item, default=_default)}
