from flask import Blueprint, request, jsonify, abort
from datetime import datetime
from utils.db import get_session
from models.models import User
from flask_jwt_extended import jwt_required, get_jwt_identity

user_bp = Blueprint("user_bp", __name__, url_prefix="/users")


@user_bp.get("")
@jwt_required()
def get_users():
    session = get_session()
    try:
        users = session.query(User).filter(User.deleted_at.is_(None)).all()
        result = jsonify({
            "isSuccess": True,
            "body": [{
                    'id': u.id,
                    'email': u.email,
                    'type': u.type,
                    'is_confirmed': u.is_confirmed,
                    'company': u.company,
                    'created_at': u.created_at.isoformat() if u.created_at else None,
                } for u in users if u.deleted_at == None]
            
        }), 200
        return result
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@user_bp.get("/<int:user_id>")
@jwt_required()
def get_user(user_id):
    session = get_session()
    try:
        user = session.query(User).filter(User.id == user_id,User.deleted_at.is_(None)).first()
        if not user:
            abort(404, description="User not found")
        result = {
            'id': user.id,
            'email': user.email,
            'type': user.type,
            'is_confirmed': user.is_confirmed,
            'company': user.company,
            'created_at': user.created_at.isoformat() if user.created_at else None,
        }
        return jsonify({
            "isSuccess": True,
            "body": result
        }), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@user_bp.post("/register")
def add_user():
    session = get_session()
    try:
        data = request.json
        user = User(
            email=data['email'],
            password=data['password'],
            type="user",
            company=data['company'],
            created_at=datetime.now(),
            is_confirmed=False
        )
        session.add(user)
        session.commit()
        return jsonify({
            'isSuccess': True,
            'body': {
                "id": user.id,
                "email": user.email,
                "type": user.type,
                "company": user.company,
            }
        }), 201
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@user_bp.post("")
@jwt_required()
def add_user_admin():
    email = get_jwt_identity()
    user = get_session().query(User).filter(User.email == email,User.deleted_at.is_(None)).first()
    if user.type != "admin":
        return jsonify({
            "isSuccess": False,
            "body": "Unauthorized"
        }), 401

    session = get_session()
    try:
        data = request.json
        user = User(
            email=data['email'],
            password="123",
            type="user",
            company=data['company'],
            created_at=datetime.now(),
            is_confirmed=True
        )
        session.add(user)
        session.commit()
        return jsonify({
            'isSuccess': True,
            'body': {
                "id": user.id,
                "email": user.email,
                "type": user.type,
                "company": user.company,
            }
        }), 201
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@user_bp.put("")
@jwt_required()
def update_user():
    try:
        session = get_session()
        data = request.json
        user_email = get_jwt_identity()
        user = session.query(User).filter(User.email == user_email,User.deleted_at.is_(None)).first()

        if user.type != "admin":
            return jsonify({
                "isSuccess": False,
                "body": "Unauthorized"
            }), 401
        
        user = session.query(User).filter(User.email == data['email'],User.deleted_at.is_(None)).first()

        user.email = data['email']
        user.company = data['company']
        if data.get('is_confirmed') != None:
            user.is_confirmed = data['is_confirmed']
        if data.get('password'):
            user.password = data['password']

        session.commit()
        return jsonify({
            'isSuccess': True,
            'body': {
                "id": user.id,
                "email": user.email,
                "type": user.type,
                "company": user.company,
                "is_confirmed":user.is_confirmed,

            }
        }), 201
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@user_bp.post("/forgot-password")
def forgot_password():
    session = get_session()
    try:
        data = request.json
        email = data.get("email")
        if not email:
            return jsonify({
                "isSuccess": False,
                "body": "Email is required."
            }), 400

        user = session.query(User).filter(User.email == email,User.deleted_at.is_(None)).first()

        if not user:
            return jsonify({
                "isSuccess": False,
                "body": "User not found."
            }), 404

        user.password = "202cb962ac59075b964b07152d234b70"
        session.commit()

        return jsonify({
            "isSuccess": True,
            "body": "Password reset."
        }), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()

@user_bp.delete("/<int:user_id>")
@jwt_required()
def delete_user(user_id):
    user_email = get_jwt_identity()
    user = get_session().query(User).filter(User.email == user_email,User.deleted_at.is_(None)).first()
    if user.type != "admin":
        return jsonify({
            "isSuccess": False,
            "body": "Unauthorized"
        }), 401
    
    session = get_session()
    try:
        user = session.query(User).filter(User.id == user_id,User.deleted_at.is_(None)).first()
        if not user:
            abort(404, description="User not found")
        user.deleted_at = datetime.now()
        session.commit()
        return jsonify({
            "isSuccess": True,
            "body": "User deleted."
        }), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()