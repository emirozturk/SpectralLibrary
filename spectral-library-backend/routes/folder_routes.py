# routes/category_routes.py
from flask import Blueprint, request, jsonify, abort
from datetime import datetime

from flask_jwt_extended import jwt_required,get_jwt_identity
from utils.db import get_session
from models.models import Folder, User

folder_bp = Blueprint("folder_bp", __name__, url_prefix="/folders")


@folder_bp.get("")
@jwt_required()
def get_folders():
    user_email = get_jwt_identity()
    session = get_session()
    try:
        user = session.query(User).filter(
            User.email == user_email,
            User.deleted_at.is_(None)
        ).first()

        if not user:
            abort(404, description="User not found.")
     
        folders = [folder for folder in user.folders if folder.deleted_at is None]

        response = {
            "isSuccess": True,
            "body": [
                {
                    "id": folder.id,
                    "name": folder.name,
                    "created_at": folder.created_at.isoformat() if folder.created_at else None,
                }
                for folder in folders if folder.deleted_at is None
            ]
        }
        return jsonify(response), 200
    finally:
        session.close()


@folder_bp.post("")
@jwt_required()
def add_folder():
    user_email = get_jwt_identity()
    session = get_session()
    try:
        user = session.query(User).filter(
            User.email == user_email,
            User.deleted_at.is_(None)
        ).first()

        if not user:
            abort(404, description="User not found.")

        data = request.json
        name = data.get("name")

        if not name:
            abort(400, description="Name is required.")

        folder = Folder(name=name, owner_id=user.id)
        session.add(folder)
        session.commit()

        response = {
            "isSuccess": True,
            "body": {
                "id": folder.id,
                "name": folder.name,
                "created_at": folder.created_at.isoformat() if folder.created_at else None,
            }
        }
        return jsonify(response), 201
    finally:
        session.close()

@folder_bp.put("")
@jwt_required()
def update_folder():
    user_email = get_jwt_identity()
    session = get_session()
    try:
        user = session.query(User).filter(
            User.email == user_email,
            User.deleted_at.is_(None)
        ).first()

        if not user:
            abort(404, description="User not found.")

        data = request.json
        folder_id = data.get("id")
        name = data.get("name")

        if not folder_id:
            abort(400, description="Folder id is required.")
        if not name:
            abort(400, description="Name is required.")

        folder = session.query(Folder).filter(
            Folder.id == folder_id,
            Folder.owner_id == user.id,
            Folder.deleted_at.is_(None)
        ).first()

        if not folder:
            abort(404, description="Folder not found.")

        folder.name = name
        session.commit()

        response = {
            "isSuccess": True,
            "body": {
                "id": folder.id,
                "name": folder.name,
                "created_at": folder.created_at.isoformat() if folder.created_at else None,
            }
        }
        return jsonify(response), 200
    finally:
        session.close()

@folder_bp.delete("<int:folder_id>")
@jwt_required()
def delete_folder(folder_id):
    user_email = get_jwt_identity()
    session = get_session()
    try:
        user = session.query(User).filter(
            User.email == user_email,
            User.deleted_at.is_(None)
        ).first()

        if not user:
            abort(404, description="User not found.")

        if not folder_id:
            abort(400, description="Folder id is required.")

        folder = session.query(Folder).filter(
            Folder.id == folder_id,
            Folder.owner_id == user.id,
            Folder.deleted_at.is_(None)
        ).first()

        if not folder:
            abort(404, description="Folder not found.")

        if folder.owner_id != user.id:
            abort(403, description="You are not authorized to delete this folder.")

        folder.deleted_at = datetime.now()
        session.commit()

        response = {
            "isSuccess": True,
            "body": {
                "id": folder.id,
                "name": folder.name,
                "created_at": folder.created_at.isoformat() if folder.created_at else None,
            }
        }
        return jsonify(response), 200
    finally:
        session.close()