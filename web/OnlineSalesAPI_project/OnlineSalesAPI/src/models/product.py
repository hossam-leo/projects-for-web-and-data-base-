from src.models import db # Import db from src.models
from sqlalchemy.sql import func # For CURRENT_TIMESTAMP

class Product(db.Model):
    __tablename__ = "Products"
    ProductID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    ProductName = db.Column(db.Text, nullable=False)
    Description = db.Column(db.Text)
    CategoryID = db.Column(db.Integer, db.ForeignKey("Categories.CategoryID"), nullable=True)
    UnitPrice = db.Column(db.Float, nullable=False) # SQLite uses REAL for DECIMAL
    ImageURL = db.Column(db.Text)
    DateAdded = db.Column(db.DateTime, default=func.now()) # Use func.now() for default
    LastUpdated = db.Column(db.DateTime, onupdate=func.now()) # Use func.now() for onupdate

    def to_dict(self, include_category=False):
        data = {
            "ProductID": self.ProductID,
            "ProductName": self.ProductName,
            "Description": self.Description,
            "CategoryID": self.CategoryID,
            "UnitPrice": self.UnitPrice,
            "ImageURL": self.ImageURL,
            "DateAdded": self.DateAdded.isoformat() if self.DateAdded else None,
            "LastUpdated": self.LastUpdated.isoformat() if self.LastUpdated else None
        }
        if include_category and self.category:
            data["CategoryName"] = self.category.CategoryName
        return data

