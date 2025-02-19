import base64
from flask import Blueprint, request, jsonify, abort
from flask_jwt_extended import get_jwt_identity, jwt_required
from datetime import datetime
from models.models import SharedFile, SpectFile, Data, User  # adjust imports as needed
from utils.db import get_session  # adjust the import for your session maker
from sqlalchemy import not_

spectfile_bp = Blueprint("spectfile_bp", __name__, url_prefix="/spectfiles")


@spectfile_bp.post("/upload")
@jwt_required()
def upload_spectfile():
    data = request.get_json()
    if not data:
        abort(400, description="Missing JSON payload.")

    folder_id = data.get("folder_id")
    subcategory_id = data.get("subcategory_id")
    description = data.get("description", "")
    # If is_public is sent as a boolean, this will work.
    is_public = data.get("is_public", False)
    file_name = data.get("file_name")
    file_content_b64 = data.get("file_content")

    # Validate required fields.
    if not folder_id or not subcategory_id or not file_name or not file_content_b64:
        abort(400, description="Missing required fields: folder_id, subcategory_id, file_name, and file_content are required.")

    # Decode the file content.
    try:
        file_bytes = base64.b64decode(file_content_b64)
        file_text = file_bytes.decode("utf-8")
    except Exception as e:
        abort(400, description="Error decoding file content: " + str(e))

    # Parse file content: each nonempty line is expected to have two comma-separated numbers.
    data_points = []
    for line in file_text.splitlines():
        if not line.strip():
            continue
        parts = line.split(",")
        if len(parts) < 2:
            continue  # or handle error if desired
        try:
            x = float(parts[0].strip())
            y = float(parts[1].strip())
        except ValueError:
            continue  # or handle error if desired
        data_points.append(Data(x=x, y=y))

    session = get_session()
    try:
        new_file = SpectFile(
            name=file_name,
            folder_id=folder_id,
            subcategory_id=subcategory_id,
            description=description,
            is_public=is_public,
            created_at=datetime.utcnow()
        )
        session.add(new_file)
        session.commit()
        session.refresh(new_file)

        # Add data points linking to this file.
        for dp in data_points:
            dp.file_id = new_file.id
            session.add(dp)
        session.commit()

        result = {
            "id": new_file.id,
            "name": new_file.name,
            "folder_id": new_file.folder_id,
            "subcategory_id": new_file.subcategory_id,
            "description": new_file.description,
            "is_public": new_file.is_public,
            "created_at": new_file.created_at.isoformat() if new_file.created_at else None,
        }
        return jsonify({"isSuccess": True, "body": result}), 201
    except Exception as e:
        session.rollback()
        abort(500, description=str(e))
    finally:
        session.close()


@spectfile_bp.get("")
@jwt_required()
def get_owned_files():
    user_email = get_jwt_identity()
    session = get_session()
    try:
        user = session.query(User).filter(
            User.email == user_email,
            User.deleted_at.is_(None)
        ).first()
        if not user:
            abort(404, description="User not found.")
        owned_files = []
        for folder in user.folders:
            if folder.deleted_at is None and folder.spectfiles:
                for s in folder.spectfiles:
                    if s.deleted_at is None:
                        owned_files.append(s)
        return jsonify({
            "isSuccess": True,
            "body": [{
                "id": s.id,
                "name": s.name,
                "folder": s.folder.name if s.folder else None,
                "subcategory": s.subcategory.name_en if s.subcategory else None,
                "category": s.subcategory.category.name_en if s.subcategory and s.subcategory.category else None,
                "description": s.description,
                "is_public": s.is_public,
                "shared_with": (
                    [sf.user.email for sf in s.shared_files if sf.deleted_at is None]
                    if s.shared_files else []
                ),
                "created_at": s.created_at.isoformat() if s.created_at else None,
            } for s in owned_files]
        }), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@spectfile_bp.get("/shared")
@jwt_required()
def get_shared_files():
    user_email = get_jwt_identity()
    session = get_session()
    try:
        user = session.query(User).filter(
            User.email == user_email,
            User.deleted_at.is_(None)
        ).first()
        if not user:
            abort(404, description="User not found.")
        shared_records = session.query(SharedFile).filter(
            SharedFile.user_id == user.id,
            SharedFile.deleted_at.is_(None)
        ).all()
        shared_files = []
        for record in shared_records:
            if record.spectfile and record.spectfile.deleted_at is None:
                shared_files.append(record.spectfile)
        return jsonify({
            "isSuccess": True,
            "body": [{
                "id": s.id,
                "name": s.name,
                "folder": s.folder.name if s.folder else None,
                "subcategory": s.subcategory.name_en if s.subcategory else None,
                "category": s.subcategory.category.name_en if s.subcategory and s.subcategory.category else None,
                "description": s.description,
                "is_public": s.is_public,
                "shared_with": (
                    [sf.user.email for sf in s.shared_files if sf.deleted_at is None]
                    if s.shared_files else []
                ),
                "created_at": s.created_at.isoformat() if s.created_at else None,
            } for s in shared_files]
        }), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@spectfile_bp.get("/public")
@jwt_required()
def get_public_files():
    session = get_session()
    try:
        public_files = session.query(SpectFile).filter(
            SpectFile.deleted_at.is_(None),
            SpectFile.is_public == True
        ).all()
        return jsonify({
            "isSuccess": True,
            "body": [{
                "id": s.id,
                "name": s.name,
                "folder": s.folder.name if s.folder else None,
                "subcategory": s.subcategory.name_en if s.subcategory else None,
                "category": s.subcategory.category.name_en if s.subcategory and s.subcategory.category else None,
                "description": s.description,
                "is_public": s.is_public,
                "shared_with": (
                    [sf.user.email for sf in s.shared_files if sf.deleted_at is None]
                    if s.shared_files else []
                ),
                "created_at": s.created_at.isoformat() if s.created_at else None,
            } for s in public_files]
        }), 200
    except Exception as e:
        return jsonify({
            "isSuccess": False,
            "body": str(e)
        }), 500
    finally:
        session.close()


@spectfile_bp.put("")
@jwt_required()
def update_spectfile():
    data = request.get_json()
    if not data or not data.get("id"):
        abort(400, description="Missing spectfile id in payload.")
    session = get_session()
    try:
        file_id = data.get("id")
        spectfile = session.query(SpectFile).filter(
            SpectFile.id == file_id,
            SpectFile.deleted_at.is_(None)
        ).first()
        if not spectfile:
            abort(404, description="Spectfile not found.")
        if "is_public" in data:
            spectfile.is_public = data["is_public"]
        if "shared_with" in data:
            # Expect shared_with as a list of user emails.
            # For simplicity, we update a CSV string in a field.
            spectfile.shared_with = ",".join(data["shared_with"])
        if "description" in data:
            spectfile.description = data["description"]
        session.commit()
        session.refresh(spectfile)
        return jsonify({
            "isSuccess": True,
            "body": {"id": spectfile.id,
                     "name": spectfile.name,
                     "folder_id": spectfile.folder_id,
                     "subcategory_id": spectfile.subcategory_id,
                     "category_id": spectfile.subcategory.category_id,
                     "description": spectfile.description,
                     "is_public": spectfile.is_public,
                     "shared_with": (
                         [sf.user.email for sf in spectfile.shared_files if sf.deleted_at is None]
                         if spectfile.shared_files else []
                     ),
                     "created_at": spectfile.created_at.isoformat() if spectfile.created_at else None,
                     }}), 200
    except Exception as e:
        session.rollback()
        abort(500, description=str(e))
    finally:
        session.close()


@spectfile_bp.delete("/<int:file_id>")
@jwt_required()
def delete_spectfile(file_id):
    session = get_session()
    try:
        spectfile = session.query(SpectFile).filter(
            SpectFile.id == file_id,
            SpectFile.deleted_at.is_(None)
        ).first()
        if not spectfile:
            abort(404, description="Spectfile not found.")

        if spectfile.folder.owner.email != get_jwt_identity():
            abort(403, description="You are not authorized to delete this file.")

        spectfile.deleted_at = datetime.now()
        session.commit()
        return jsonify({"isSuccess": True, "body": {"id": file_id}}), 200
    except Exception as e:
        session.rollback()
        abort(500, description=str(e))
    finally:
        session.close()


@spectfile_bp.put("/share")
@jwt_required()
def share_spectfile():
    data = request.get_json()
    shared_with = data.get("shared_with")
    if not data or not data.get("file_id") or shared_with is None:
        abort(400, description="Missing file_id and shared_with in payload.")

    session = get_session()
    try:
        file_id = data.get("file_id")
        spectfile = session.query(SpectFile).filter(
            SpectFile.id == file_id,
            SpectFile.deleted_at.is_(None)
        ).first()
        if not spectfile:
            abort(404, description="Spectfile not found.")

        # Get the current user making the request
        user = session.query(User).filter(
            User.email == get_jwt_identity(),
            User.deleted_at.is_(None)
        ).first()
        if not user:
            abort(404, description="User not found.")

        # Only allow the owner of the file (or its folder) to share it.
        if spectfile.folder.owner.email != user.email:
            abort(403, description="You are not authorized to share this file.")

        # Get User objects corresponding to the provided emails.
        shared_users = session.query(User).filter(
            User.email.in_(shared_with)
        ).all()

        # Remove records for users who are no longer in the new shared_with list.
        shared_to_removal = session.query(SharedFile).filter(
            SharedFile.file_id == file_id,
            not_(SharedFile.user_id.in_([u.id for u in shared_users])),
            SharedFile.deleted_at.is_(None)
        ).all()
        for sf in shared_to_removal:
            sf.deleted_at = datetime.now()

        # Add new shared records for users that are not already shared.
        new_records = []
        for shared in shared_users:
            existing = session.query(SharedFile).filter(
                SharedFile.file_id == file_id,
                SharedFile.user_id == shared.id,
                SharedFile.deleted_at.is_(None)
            ).first()
            if not existing:
                shared_record = SharedFile(
                    file_id=file_id,
                    user_id=shared.id,
                    created_at=datetime.now()
                )
                session.add(shared_record)
                new_records.append(shared_record)

        session.commit()

        return jsonify({
            "isSuccess": True,
            "body": {
                "file_id": file_id,
                "newly_shared_user_ids": [sr.user_id for sr in new_records]
            }
        }), 201

    except Exception as e:
        session.rollback()
        abort(500, description=str(e))
    finally:
        session.close()


@spectfile_bp.get("/draw")
@jwt_required()
def draw_plot():
    user_email = get_jwt_identity()
    ids_param = request.args.get("ids")
    if not ids_param:
        abort(400, description="No file ids provided.")

    try:
        file_ids = [int(x)
                    for x in ids_param.split(",") if x.strip().isdigit()]
    except Exception as e:
        abort(400, description="Invalid file ids provided.")

    session = get_session()
    try:
        # Get current user.
        user = session.query(User).filter(
            User.email == user_email,
            User.deleted_at.is_(None)
        ).first()
        if not user:
            abort(404, description="User not found.")

        # Query for files with the given IDs that are not deleted.
        files = session.query(SpectFile).filter(
            SpectFile.id.in_(file_ids),
            SpectFile.deleted_at.is_(None)
        ).all()

        if not files or len(files) == 0:
            abort(404, description="Files not found.")

        accessible_files = []
        # Check each file for accessibility.
        for f in files:
            owner_email = f.folder.owner.email if f.folder and f.folder.owner else None
            shared_emails = (
                [sf.user.email for sf in f.shared_files if sf.deleted_at is None]
                if f.shared_files else []
            )
            # Accessible if user is the owner, the file is shared with the user, or if it is public.
            if owner_email == user_email or user_email in shared_emails or f.is_public:
                accessible_files.append(f)
            else:
                abort(
                    403, description=f"File with id {f.id} is not accessible to you.")

        return jsonify({
            "isSuccess": True,
            "body": [
                {
                    "id": f.id,
                    "description": f.description,
                    "data": [
                        {"x": d.x, "y": d.y} for d in f.data
                    ]
                } for f in accessible_files
            ]
        }), 200

    except Exception as e:
        session.rollback()
        abort(500, description=str(e))
    finally:
        session.close()
