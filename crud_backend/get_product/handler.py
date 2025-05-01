import json
from db import get_product_by_id

def lambda_handler(event, context):
    try:
        product_id = int(event['pathParameters']['id'])
        product = get_product_by_id(product_id)
        if not product:
            return {'statusCode': 404, 'body': json.dumps({'error': 'Producto no encontrado'})}
        return {'statusCode': 200, 'body': json.dumps(product)}
    except Exception as e:
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}