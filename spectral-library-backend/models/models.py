# models.py
from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Index,
    UniqueConstraint
)
from sqlalchemy.orm import relationship, declarative_base
from datetime import datetime

Base = declarative_base()

class Category(Base):
    __tablename__ = 'categories'
    __table_args__ = (
        UniqueConstraint('name_en', name='name_en'),
        UniqueConstraint('name_tr', name='name_tr'),
        Index('ix_categories_id', 'id'),
    )
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name_en = Column(String(255), nullable=False)
    name_tr = Column(String(255), nullable=True)
    created_at = Column(DateTime, nullable=True, default=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # A category can have many subcategories.
    subcategories = relationship("Subcategory", back_populates="category")


class Subcategory(Base):
    __tablename__ = 'subcategories'
    __table_args__ = (
        Index('category_id', 'category_id'),
        Index('ix_subcategories_id', 'id'),
    )
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    category_id = Column(Integer, ForeignKey('categories.id'), nullable=False)
    name_en = Column(String(255), nullable=False)
    name_tr = Column(String(255), nullable=True)
    created_at = Column(DateTime, nullable=True, default=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships: each subcategory belongs to a category, and can have many spectfiles.
    category = relationship("Category", back_populates="subcategories")
    spectfiles = relationship("SpectFile", back_populates="subcategory")


class User(Base):
    __tablename__ = 'users'
    __table_args__ = (
        Index('ix_users_id', 'id'),
    )
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    email = Column(String(255), nullable=False, unique=True)
    password = Column(String(255), nullable=False)
    type = Column(String(50), nullable=False)
    is_confirmed = Column(Boolean, nullable=False)
    company = Column(String(100), nullable=True)
    created_at = Column(DateTime, nullable=True, default=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    has_auth_for_public = Column(Integer,nullable=True)
    # A user can own many folders and can be associated with many shared files.
    folders = relationship("Folder", back_populates="owner")
    shared_files = relationship("SharedFile", back_populates="user")


class Folder(Base):
    __tablename__ = 'folders'
    __table_args__ = (
        Index('ix_folders_id', 'id'),
        Index('owner_id', 'owner_id'),
    )
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    owner_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    created_at = Column(DateTime, nullable=True, default=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Each folder is owned by a user and can contain many spectfiles.
    owner = relationship("User", back_populates="folders")
    spectfiles = relationship("SpectFile", back_populates="folder")


class SpectFile(Base):
    __tablename__ = 'spectfiles'
    __table_args__ = (
        Index('folder_id', 'folder_id'),
        Index('ix_spectfiles_id', 'id'),
        Index('subcategory_id', 'subcategory_id'),
    )
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=True)
    folder_id = Column(Integer, ForeignKey('folders.id'), nullable=False)
    subcategory_id = Column(Integer, ForeignKey('subcategories.id'), nullable=False)
    description = Column(String(1024), nullable=True)
    is_public = Column(Boolean, nullable=False)
    created_at = Column(DateTime, nullable=True, default=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Each spectfile belongs to a folder and a subcategory.
    folder = relationship("Folder", back_populates="spectfiles")
    subcategory = relationship("Subcategory", back_populates="spectfiles")
    # A spectfile can have many data entries and can be shared in many shared file records.
    data = relationship("Data", back_populates="spectfile")
    shared_files = relationship("SharedFile", back_populates="spectfile")


class Data(Base):
    __tablename__ = 'data'
    __table_args__ = (
        Index('file_id', 'file_id'),
        Index('ix_data_id', 'id'),
    )
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    file_id = Column(Integer, ForeignKey('spectfiles.id'), nullable=False)
    x = Column(Float, nullable=False)
    y = Column(Float, nullable=False)
    
    # Each data entry is linked to a spectfile.
    spectfile = relationship("SpectFile", back_populates="data")


class SharedFile(Base):
    __tablename__ = 'sharedfiles'
    __table_args__ = (
        Index('file_id', 'file_id'),
        Index('ix_sharedfiles_id', 'id'),
        Index('user_id', 'user_id'),
    )
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    file_id = Column(Integer, ForeignKey('spectfiles.id'), nullable=False)
    created_at = Column(DateTime, nullable=True, default=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Each shared file record links a user with a spectfile.
    user = relationship("User", back_populates="shared_files")
    spectfile = relationship("SpectFile", back_populates="shared_files")