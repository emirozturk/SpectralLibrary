from flask import Blueprint, request, jsonify, abort
from flask_jwt_extended import create_access_token
from utils.db import get_session
from models.models import User

auth_bp = Blueprint("auth_bp", __name__, url_prefix="/auth")


@auth_bp.post("/login")
def login():
    try:
        data = request.get_json()
        email = data.get("email")
        password = data.get("password")

        if not email or not password:
            abort(400, description="Email and password are required.")

        session = get_session()
        user = session.query(User).filter(User.email == email).first()
        if not user or not user.password == password:
            abort(401, description="Invalid credentials")

        access_token = create_access_token(identity=user.email)
        return jsonify(
            {
                'isSuccess': True,
                'body': {
                    "user": {"id": user.id,
                             "email": user.email,
                             "type": user.type,
                             "company": user.company, 
                             },
                    "token": access_token
                }
            }), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()
