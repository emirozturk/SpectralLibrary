# app.py
from flask import Flask
from models.models import Base
from utils.db import engine
from routes import category_routes, dashboard_routes, folder_routes, spectfile_routes, subcategory_routes, user_routes,auth_router
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from datetime import timedelta

app = Flask(__name__)
CORS(app)
app.config["JWT_SECRET_KEY"] = "emirozturkandspectrallibrary"
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=4)

Base.metadata.create_all(bind=engine)

jwt = JWTManager(app)

app.register_blueprint(category_routes.category_bp)
app.register_blueprint(user_routes.user_bp)
app.register_blueprint(auth_router.auth_bp)
app.register_blueprint(dashboard_routes.dashboard_bp)
app.register_blueprint(subcategory_routes.subcategory_bp)
app.register_blueprint(folder_routes.folder_bp)
app.register_blueprint(spectfile_routes.spectfile_bp)