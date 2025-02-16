# routes/category_routes.py
from flask import Blueprint, request, jsonify, abort
from datetime import datetime

from flask_jwt_extended import get_jwt_identity, jwt_required
from utils.db import get_session
from models.models import Category, User

category_bp = Blueprint("category_bp", __name__, url_prefix="/categories")


@category_bp.get("")
@jwt_required()
def get_categories():
    try:
        session = get_session()
        
        categories = session.query(Category).filter(Category.deleted_at==None).all()
        response = {
            "isSuccess": True,
            "body": [
                {
                    'id': category.id,
                    'name_en': category.name_en,
                    'name_tr': category.name_tr,
                    'created_at': category.created_at.isoformat() if category.created_at else None,
                    'deleted_at': category.deleted_at.isoformat() if category.deleted_at else None,
                    'subcategories': [
                        {
                            'id': subcat.id,
                            'name_en': subcat.name_en,
                            'name_tr': subcat.name_tr,
                            'created_at': subcat.created_at.isoformat() if subcat.created_at else None,
                            'deleted_at': subcat.deleted_at.isoformat() if subcat.deleted_at else None,
                            'category_id': subcat.category_id
                        } for subcat in category.subcategories if subcat.deleted_at==None
                    ]
                } for category in categories
            ]
        }
        return jsonify(response), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()



@category_bp.get("/<int:category_id>")
@jwt_required()
def get_category(category_id):
    try:
        session = get_session()
        category = session.query(Category).filter(
            Category.id == category_id).first()
        if not category:
            abort(404, description="Category not found")
        result = jsonify({
            'isSuccess': True,
            'body': {
                'id': category.id,
                'name_en': category.name_en,
                'name_tr': category.name_tr,
                'created_at': category.created_at.isoformat() if category.created_at else None,    
            }
        }), 200
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@category_bp.post("")
@jwt_required()
def create_category():
    try:
        data = request.json
        name_en = data["name"]
        if not name_en:
            abort(400, description="Missing required field 'name_en'")
        session = get_session()

        user_email = get_jwt_identity()
        user = get_session().query(User).filter(User.email == user_email).first()
        if user.type != "admin":
            return jsonify({
                "isSuccess": False,
                "body": "Unauthorized"
            }), 401
            
        new_category = Category(
            name_en=name_en,
            name_tr=name_en,#name_tr,
            created_at=datetime.now()
        )
        session.add(new_category)
        session.commit()
        session.refresh(new_category)
        result = {
            'id': new_category.id,
            'name_en': new_category.name_en,
            'name_tr': new_category.name_tr,
            'created_at': new_category.created_at.isoformat() if new_category.created_at else None,
            'deleted_at': new_category.deleted_at.isoformat() if new_category.deleted_at else None,
        }
        return jsonify(result), 201
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@category_bp.put("")
@jwt_required()
def update_category():
    try:
        data = request.json
        category_id = data.get('id')
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
        category.name_en = data["name"]
        category.name_tr = data["name"]        
        session.commit()
        result = {
            'id': category.id,
            'name_en': category.name_en,
            'name_tr': category.name_tr,
            'created_at': category.created_at.isoformat() if category.created_at else None,
            'deleted_at': category.deleted_at.isoformat() if category.deleted_at else None,
        }
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@category_bp.delete("/<int:category_id>")
@jwt_required()
def delete_category(category_id):
    try:
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
        for subcategory in category.subcategories:
            subcategory.deleted_at = datetime.now()
        category.deleted_at = datetime.now()
        session.commit()
        return jsonify({"message": "Category deleted"}), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()
