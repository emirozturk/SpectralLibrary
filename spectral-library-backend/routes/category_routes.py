# routes/category_routes.py
from flask import Blueprint, request, jsonify, abort
from datetime import datetime
from utils.db import get_session
from models.models import Category

category_bp = Blueprint("category_bp", __name__, url_prefix="/categories")

@category_bp.get("")
def get_categories():
    session = get_session()
    try:
        categories = session.query(Category).all()
        result = jsonify({
            "isSuccess": True,
            "body": {
                categories: [{
                    'id': c.id,
                    'name_en': c.name_en,
                    'name_tr': c.name_tr,
                    'created_at': c.created_at.isoformat() if c.created_at else None,
                    'deleted_at': c.deleted_at.isoformat() if c.deleted_at else None,
                } for c in categories]
            }
        }), 200
        return result
    finally:
        session.close()


@category_bp.get("/<int:category_id>")
def get_category(category_id):
    session = get_session()
    try:
        category = session.query(Category).filter(Category.id == category_id).first()
        if not category:
            abort(404, description="Category not found")
        result = jsonify({
            'isSuccess': True,
            'body': {
                'id': category.id,
                'name_en': category.name_en,
                'name_tr': category.name_tr,
                'created_at': category.created_at.isoformat() if category.created_at else None,
                'deleted_at': category.deleted_at.isoformat() if category.deleted_at else None,
            }
        }), 200
        return jsonify(result), 200
    finally:
        session.close()

@category_bp.post("")
def create_category():
    name_en = request.form.get("name_en")
    name_tr = request.form.get("name_tr")
    if not name_en:
        abort(400, description="Missing required field 'name_en'")
    session = get_session()
    try:
        new_category = Category(
            name_en=name_en,
            name_tr=name_tr,
            created_at=datetime.utcnow()
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
    finally:
        session.close()

@category_bp.post("/<int:category_id>/update")
def update_category(category_id):
    session = get_session()
    try:
        category = session.query(Category).filter(Category.id == category_id).first()
        if not category:
            abort(404, description="Category not found")
        name_en = request.form.get("name_en")
        name_tr = request.form.get("name_tr")
        deleted_at_str = request.form.get("deleted_at")
        if name_en:
            category.name_en = name_en
        if name_tr:
            category.name_tr = name_tr
        if deleted_at_str:
            try:
                category.deleted_at = datetime.fromisoformat(deleted_at_str)
            except Exception:
                abort(400, description="Invalid datetime format for 'deleted_at'")
        session.commit()
        result = {
            'id': category.id,
            'name_en': category.name_en,
            'name_tr': category.name_tr,
            'created_at': category.created_at.isoformat() if category.created_at else None,
            'deleted_at': category.deleted_at.isoformat() if category.deleted_at else None,
        }
        return jsonify(result), 200
    finally:
        session.close()

@category_bp.post("/<int:category_id>/delete")
def delete_category(category_id):
    session = get_session()
    try:
        category = session.query(Category).filter(Category.id == category_id).first()
        if not category:
            abort(404, description="Category not found")
        session.delete(category)
        session.commit()
        return jsonify({"message": "Category deleted"}), 200
    finally:
        session.close()