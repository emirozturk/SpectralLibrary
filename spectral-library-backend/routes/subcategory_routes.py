# routes/category_routes.py
from flask import Blueprint, request, jsonify, abort
from datetime import datetime

from flask_jwt_extended import get_jwt_identity, jwt_required
from utils.db import get_session
from models.models import Category,Subcategory, User

subcategory_bp = Blueprint("subcategory_bp", __name__, url_prefix="/subcategories")


@subcategory_bp.post("")
@jwt_required()
def add_subcategory():
    try:
        data = request.json
        category_id = data.get('categoryId')
        session = get_session()

        user_email = get_jwt_identity()
        user = get_session().query(User).filter(User.email == user_email).first()
        if user.type != "admin":
            return jsonify({
                "isSuccess": False,
                "body": "Unauthorized"
            }), 401
        

        category = session.query(Category).filter(
            Category.id == category_id).first()
        if not category:
            abort(404, description="Category not found")
        new_subcategory = Subcategory(
            name_en=data["name"],
            name_tr=data["name"],
            created_at=datetime.now(),
            category_id=category_id
        )
        session.add(new_subcategory)
        session.commit()
        return jsonify({
            "isSuccess": True,
            "body": {
                'id': new_subcategory.id,
                'name_en': new_subcategory.name_en,
                'name_tr': new_subcategory.name_tr,
                'created_at': new_subcategory.created_at.isoformat() if new_subcategory.created_at else None,
                'category_id': new_subcategory.category_id
            }
        }), 201
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@subcategory_bp.put("")
@jwt_required()
def update_category():
    try:
        data = request.json
        subcategory_id = data.get('id')
        session = get_session()

        user_email = get_jwt_identity()
        user = get_session().query(User).filter(User.email == user_email).first()
        if user.type != "admin":
            return jsonify({
                "isSuccess": False,
                "body": "Unauthorized"
            }), 401
        subcategory = session.query(Subcategory).filter(
            Subcategory.id == subcategory_id).first()
        if not subcategory:
            abort(404, description="Subategory not found")
        subcategory.category_id = data["categoryId"]
        subcategory.name_en = data["name"]
        subcategory.name_tr = data["name"]        
        session.commit()
        result = {
            'id': subcategory.id,
            'name_en': subcategory.name_en,
            'name_tr': subcategory.name_tr,
            'created_at': subcategory.created_at.isoformat() if subcategory.created_at else None,
            'deleted_at': subcategory.deleted_at.isoformat() if subcategory.deleted_at else None,
        }
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@subcategory_bp.delete("<int:subcategory_id>")
@jwt_required()
def delete_subcategory(subcategory_id):
    try:
        session = get_session()
        user_email = get_jwt_identity()
        user = get_session().query(User).filter(User.email == user_email).first()
        if user.type != "admin":
            return jsonify({
                "isSuccess": False,
                "body": "Unauthorized"
            }), 401
        subcategory = session.query(Subcategory).filter(
            Subcategory.id == subcategory_id).first()
        if not subcategory:
            abort(404, description="Subcategory not found")
        subcategory.deleted_at = datetime.now()
        session.commit()
        return jsonify({"message": "Subcategory deleted"}), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()