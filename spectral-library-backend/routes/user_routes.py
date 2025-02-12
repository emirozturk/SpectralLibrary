from flask import Blueprint, request, jsonify, abort
from datetime import datetime
from utils.db import get_session
from models.user import User

user_bp = Blueprint("user_bp", __name__, url_prefix="/users")

@user_bp.get("/")
def get_users():
    session = get_session()
    try:
        users = session.query(User).all()
        result = [{
            'id': u.id,
            'email': u.email,
            'type': u.type,
            'is_confirmed': u.is_confirmed,
            'company': u.company,
            'created_at': u.created_at.isoformat() if u.created_at else None,
            'deleted_at': u.deleted_at.isoformat() if u.deleted_at else None,
        } for u in users]
        return jsonify(result), 200
    finally:
        session.close()

@user_bp.get("/<int:user_id>")
def get_user(user_id):
    session = get_session()
    try:
        user = session.query(User).filter(User.id == user_id).first()
        if not user:
            abort(404, description="User not found")
        result = {
            'id': user.id,
            'email': user.email,
            'type': user.type,
            'is_confirmed': user.is_confirmed,
            'company': user.company,
            'created_at': user.created_at.isoformat() if user.created_at else None,
            'deleted_at': user.deleted_at.isoformat() if user.deleted_at else None,
        }
        return jsonify(result), 200
    finally:
        session.close()

# Additional endpoints (POST, update, delete) for users can be added here following a similar pattern.