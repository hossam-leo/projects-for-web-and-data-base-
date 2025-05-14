import sqlite3
from flask import Flask, jsonify, request, g
from flask_cors import CORS
import os

app = Flask(__name__, static_folder='static', static_url_path='')
CORS(app)  # Enable CORS for all routes

DATABASE = 'C:/Users/masr franca/Downloads/web2/online_sales.db'
@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

@app.route('/api/products', methods=['GET'])
def get_products():
    try:
        conn = sqlite3.connect(DATABASE)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute("""
            SELECT p.ProductID, p.ProductName, p.Description, p.UnitPrice, p.ImageURL, c.CategoryName
            FROM Products p
            LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
        """)
        products = [dict(row) for row in cursor.fetchall()]
        conn.close()
        return jsonify(products)
    except Exception as e:
        print(f"Error fetching products: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/categories', methods=['GET'])
def get_categories():
    try:
        conn = sqlite3.connect(DATABASE)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute("SELECT CategoryID, CategoryName FROM Categories")
        categories = [dict(row) for row in cursor.fetchall()]
        conn.close()
        return jsonify(categories)
    except Exception as e:
        print(f"Error fetching categories: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/products', methods=['POST'])
def add_product():
    try:
        data = request.get_json()
        product_name = data.get('productName')
        description = data.get('description')
        unit_price = data.get('unitPrice')
        category_id = data.get('categoryID')
        image_url = data.get('imageURL')

        if not all([product_name, unit_price, category_id]):
            return jsonify({'error': 'Missing required fields: productName, unitPrice, categoryID'}), 400

        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO Products (ProductName, Description, UnitPrice, CategoryID, ImageURL)
            VALUES (?, ?, ?, ?, ?)
        """, (product_name, description, float(unit_price), int(category_id), image_url))
        conn.commit()
        product_id = cursor.lastrowid
        conn.close()
        return jsonify({'message': 'Product added successfully', 'productID': product_id}), 201
    except sqlite3.IntegrityError as e:
         print(f"Database integrity error: {e}")
         return jsonify({'error': 'Failed to add product due to a database constraint (e.g., category does not exist).', 'details': str(e)}), 400
    except Exception as e:
        print(f"Error adding product: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    try:
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Products WHERE ProductID = ?", (product_id,))
        conn.commit()
        if cursor.rowcount == 0:
            conn.close()
            return jsonify({'error': 'Product not found or already deleted'}), 404
        conn.close()
        return jsonify({'message': f'Product {product_id} deleted successfully'}), 200
    except Exception as e:
        print(f"Error deleting product {product_id}: {e}")
        return jsonify({'error': str(e)}), 500

# Serve static files (HTML, CSS, JS)
@app.route('/')
def index():
    return app.send_static_file('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

