import json
from model import ProductCreate
from db import insert_product
from pydantic import ValidationError

def lambda_handler(event, context):
    try:
        data = json.loads(event['body'])
        product = ProductCreate(**data)
        insert_product(product)
        return {
            'statusCode': 201,
            'body': json.dumps({'message': 'Producto creado correctamente'})
        }
    except ValidationError as e:
        return {'statusCode': 400, 'body': json.dumps({'error': e.errors()})}
    except Exception as e:
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}