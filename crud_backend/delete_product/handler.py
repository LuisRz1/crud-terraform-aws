import json
from db import delete_product_by_id

def lambda_handler(event, context):
    try:
        product_id = int(event['pathParameters']['id'])
        deleted = delete_product_by_id(product_id)
        if not deleted:
            return {'statusCode': 404, 'body': json.dumps({'error': 'Producto no encontrado'})}
        return {'statusCode': 200, 'body': json.dumps({'message': 'Producto eliminado'})}
    except Exception as e:
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
