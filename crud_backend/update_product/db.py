import pymysql
import os

def get_connection():
    return pymysql.connect(
        host=os.environ['DB_HOST'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD'],
        database=os.environ['DB_NAME'],
        cursorclass=pymysql.cursors.DictCursor
    )

def insert_product(product):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO products (name, description, price)
                VALUES (%s, %s, %s)
            """, (product.name, product.description, product.price))
            conn.commit()
    finally:
        conn.close()

def get_product_by_id(product_id):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM products WHERE id = %s", (product_id,))
            return cursor.fetchone()
    finally:
        conn.close()

def update_product_by_id(product_id, product):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                UPDATE products
                SET name = %s, description = %s, price = %s
                WHERE id = %s
            """, (product.name, product.description, product.price, product_id))
            conn.commit()
            return cursor.rowcount > 0
    finally:
        conn.close()

def delete_product_by_id(product_id):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("DELETE FROM products WHERE id = %s", (product_id,))
            conn.commit()
            return cursor.rowcount > 0
    finally:
        conn.close()
