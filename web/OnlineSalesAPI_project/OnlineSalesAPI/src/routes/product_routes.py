from flask import Blueprint, request, jsonify
from src.models import db # Import db from src.models
from src.models.product import Product # Import Product model
from src.models.category import Category # Import Category model

product_bp = Blueprint("product_bp", __name__)

@product_bp.route("/products", methods=["GET"])
def get_products():
    try:
        products = Product.query.all()
        return jsonify([product.to_dict(include_category=True) for product in products]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@product_bp.route("/products/<int:product_id>", methods=["GET"])
def get_product(product_id):
    try:
        product = Product.query.get(product_id)
        if product:
            return jsonify(product.to_dict(include_category=True)), 200
        else:
            return jsonify({"message": "Product not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@product_bp.route("/products", methods=["POST"])
def create_product():
    try:
        data = request.get_json()
        if not data or not data.get("ProductName") or data.get("UnitPrice") is None:
            return jsonify({"message": "Missing required fields: ProductName and UnitPrice"}), 400
        
        new_product = Product(
            ProductName=data["ProductName"],
            Description=data.get("Description"),
            UnitPrice=data["UnitPrice"],
            ImageURL=data.get("ImageURL")
        )
        
        if data.get("CategoryID"):
            category = Category.query.get(data.get("CategoryID"))
            if not category:
                return jsonify({"message": f"Category with ID {data.get('CategoryID')} not found."}), 400
            new_product.CategoryID = data.get("CategoryID")

        db.session.add(new_product)
        db.session.commit()
        return jsonify(new_product.to_dict(include_category=True)), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@product_bp.route("/products/<int:product_id>", methods=["DELETE"])
def delete_product(product_id):
    try:
        product = Product.query.get(product_id)
        if product:
            db.session.delete(product)
            db.session.commit()
            return jsonify({"message": "Product deleted successfully"}), 200
        else:
            return jsonify({"message": "Product not found"}), 404
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@product_bp.route("/categories", methods=["GET"])
def get_categories():
    try:
        categories = Category.query.all()
        return jsonify([category.to_dict() for category in categories]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

