# config.py
import os

class Config:
    # For example, you might use an environment variable or default value.
    DATABASE_URL = os.getenv("DATABASE_URL", "mysql+pymysql://root:erty4567@localhost:3306/spectraldb")
    DEBUG = True