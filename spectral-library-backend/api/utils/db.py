import pymysql
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = (
    "mysql+pymysql://avnadmin:AVNS_PrqutowVLsZLpooUFLJ@"
    "spectraldb-emirozturk3-59c8.j.aivencloud.com:28938/defaultdb?charset=utf8mb4"
)
timeout = 10

engine = create_engine(
    DATABASE_URL,
    connect_args={
        "connect_timeout": timeout,
        "read_timeout": timeout,
        "write_timeout": timeout,
        # Remove "cursorclass": pymysql.cursors.DictCursor
    }
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_session():
    return SessionLocal()
