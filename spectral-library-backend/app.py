# app.py
from flask import Flask
from config import Config
from models.models import Base
from utils.db import engine
from routes import category_routes, user_routes,auth_router
from flask_jwt_extended import JWTManager


app = Flask(__name__)
app.config.from_object(Config)
app.config["JWT_SECRET_KEY"] = "emirozturkandspectrallibrary"

Base.metadata.create_all(bind=engine)

jwt = JWTManager(app)

app.register_blueprint(category_routes.category_bp)
app.register_blueprint(user_routes.user_bp)
app.register_blueprint(auth_router.auth_bp)

if __name__ == '__main__':
    app.run(debug=Config.DEBUG)