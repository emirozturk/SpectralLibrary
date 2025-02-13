from flask import Blueprint, request, jsonify, abort
from flask_jwt_extended import create_access_token
from utils.db import get_session
from models.models import User

auth_bp = Blueprint("auth_bp", __name__, url_prefix="/auth")

@auth_bp.post("/login")
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        abort(400, description="Email and password are required.")

    session = get_session()
    try:
        user = session.query(User).filter(User.email == email).first()
        if not user or not user.password == password:
            abort(401, description="Invalid credentials")

        access_token = create_access_token(identity=user.id)
        return jsonify(user_with_token={"user":user,"token":access_token}), 200
    finally:
        session.close()
