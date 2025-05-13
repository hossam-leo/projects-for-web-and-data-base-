from src.models import db # Import db from src.models

class Category(db.Model):
    __tablename__ = "Categories"
    CategoryID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    CategoryName = db.Column(db.Text, nullable=False, unique=True)
    Description = db.Column(db.Text)
    # Relationship to Products (optional, but good for ORM features)
    products = db.relationship("Product", backref="category", lazy=True)

    def to_dict(self):
        return {
            "CategoryID": self.CategoryID,
            "CategoryName": self.CategoryName,
            "Description": self.Description
        }

