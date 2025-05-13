import os
import sys
# DON'T CHANGE THIS !!!
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from flask import Flask, send_from_directory
from src.models import db # Import db from src.models

app = Flask(__name__, static_folder=os.path.join(os.path.dirname(__file__), 'static'))
app.config['SECRET_KEY'] = 'asdf#FGSgvasgf$5$WGT'

# Configure SQLite database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////home/ubuntu/OnlineSalesDB.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize the app with the db instance
db.init_app(app)

# Import models here to ensure they are registered with SQLAlchemy
# before any app context that might need them (e.g., db.create_all() or first request)
# These imports are now safe after db.init_app(app)
from src.models.product import Product
from src.models.category import Category

# Import blueprints for routes
from src.routes.product_routes import product_bp
app.register_blueprint(product_bp, url_prefix='/api')

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    static_folder_path = app.static_folder
    if static_folder_path is None:
            return "Static folder not configured", 404

    if path != "" and os.path.exists(os.path.join(static_folder_path, path)):
        return send_from_directory(static_folder_path, path)
    else:
        index_path = os.path.join(static_folder_path, 'index.html')
        if os.path.exists(index_path):
            return send_from_directory(static_folder_path, 'index.html')
        else:
            return "index.html not found in static folder. Ensure it's placed there.", 404

if __name__ == '__main__':
    with app.app_context():
        # db.create_all() # Uncomment if models define tables not in the SQL script
        pass
    app.run(host='0.0.0.0', port=5000, debug=True)

