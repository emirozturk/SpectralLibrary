# app.py
from flask import Flask
from config import Config
from models import Base  # This ensures all models are imported.
from utils.db import engine
from routes import category_routes, user_routes

app = Flask(__name__)
app.config.from_object(Config)

Base.metadata.create_all(bind=engine)

app.register_blueprint(category_routes.category_bp)
app.register_blueprint(user_routes.user_bp)

if __name__ == '__main__':
    app.run(debug=Config.DEBUG)