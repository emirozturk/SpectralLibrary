from flask import Blueprint, request, jsonify, abort
from sqlalchemy import func
from utils.db import get_session
from models.models import Category, Folder, SpectFile, Subcategory, User
from flask_jwt_extended import jwt_required, get_jwt_identity

dashboard_bp = Blueprint("dashboard_bp", __name__, url_prefix="/dashboard")


@dashboard_bp.get("")
@jwt_required()
def get_dashboard():
    session = get_session()

    user_count = session.query(User).filter(User.deleted_at.is_(None)).count()

    total_folders = session.query(Folder).filter(
        Folder.deleted_at.is_(None)).count()

    total_files = session.query(SpectFile).filter(
        SpectFile.deleted_at.is_(None)).count()

    ratios_data = session.query(
        Category.id,
        func.count(SpectFile.id).label("file_count")
    ).join(Category.subcategories) \
     .join(Subcategory.spectfiles) \
     .filter(
         Category.deleted_at.is_(None),
         Subcategory.deleted_at.is_(None),
         SpectFile.deleted_at.is_(None)
    ) \
        .group_by(Category.id) \
        .all()

    category_file_ratios = []
    for data in ratios_data:
        ratio = data.file_count / total_files if total_files > 0 else 0
        category_file_ratios.append({
            "category_id": data.id,
            "category_name": data.name_en,
            "file_count": data.file_count,
            "ratio": ratio
        })

    return jsonify({
        "isSuccess": True,
        "body": {
            "user_count": user_count,
            "total_folders": total_folders,
            "total_files": total_files,
            "category_file_ratios": category_file_ratios
        }
    }), 200
