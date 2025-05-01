import json
from model import ProductCreate
from db import update_product_by_id
from pydantic import ValidationError

def lambda_handler(event, context):
    try:
        product_id = int(event['pathParameters']['id'])
        data = json.loads(event['body'])
        product = ProductCreate(**data)
        updated = update_product_by_id(product_id, product)
        if not updated:
            return {'statusCode': 404, 'body': json.dumps({'error': 'Producto no encontrado'})}
        return {'statusCode': 200, 'body': json.dumps({'message': 'Producto actualizado'})}
    except ValidationError as e:
        return {'statusCode': 400, 'body': json.dumps({'error': e.errors()})}
    except Exception as e:
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}