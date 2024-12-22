from flask import Flask,request,jsonify
from flask_pymongo import PyMongo
import jwt
from functools import wraps
from flask_cors import CORS
from Models import Folder
from Models.Category import Category
from Models.Response import Response
from Models.User import User
from datetime import datetime,timedelta

app = Flask(__name__)


SECRET_KEY = "spectralsecretkeywithemirozturk"


app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb+srv://spectraldbuser:HwqKZrQrcYVJrhbT@cluster0.xi3lw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0/spectraldb"
mongo = PyMongo(app)
CORS(app,resources={r"/*":{"origins":"*"}})

def token_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"success": False, "message": "Token is missing"}), 403
        
        try:
            # Assume token is prefixed with "Bearer "
            token = token.replace("Bearer ", "")
            decoded_token = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            current_user_id = decoded_token.get("email")
        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
            return jsonify({"success": False, "message": "Invalid or expired token"}), 403
        
        return f(current_user_id, *args, **kwargs)
    
    return decorated_function

@app.post("/api/Users/CheckLogin")
def check_login():
    email = request.json.get("email")
    password = request.json.get("password")
    foundMongoUser = mongo.db.users.find_one({"email":email})
    if foundMongoUser !=None:
        if foundMongoUser["password"]== password:
            foundUser = User.from_map(foundMongoUser)
            if foundUser.is_confirmed:
                token = jwt.encode({
                    'email': foundMongoUser['email'],
                    'exp': datetime.now() + timedelta(hours=1)
                }, SECRET_KEY, algorithm="HS256")
                foundUser.token = token
                return jsonify(Response.success(foundUser.to_map()).to_map()),200
            else:
                response = jsonify(Response(False, {}, "User is not confirmed").to_map())
                response.headers.add("Access-Control-Allow-Origin","*")
                return response            
        else:
            response = jsonify(Response(False, {}, "Wrong Password").to_map())
            response.headers.add("Access-Control-Allow-Origin","*")
            return response      
    else:
        response = jsonify(Response(False, {}, "User Not Found").to_map())
        response.headers.add("Access-Control-Allow-Origin","*")
        return response


@app.post("/api/Users/")
def add_user():
        data = request.json
        
        user = User.from_map(data)
        
        existing_user = mongo.db.users.find_one({"email": user.email})
        if existing_user:
            return jsonify(Response(False, {}, "User already exists").to_map()), 400

        mongo.db.users.insert_one(user.to_map())

        return jsonify(Response(True, user.to_map(), "User successfully created").to_map()), 201


@app.put("/api/Users/")
@token_required
def update_user(email):
        data = request.json
        user = User.from_map(data)        
        found_user_m = mongo.db.users.find_one({"email": user.email})        
        if not found_user_m:
            return jsonify(Response(False, {}, "User Not Found").to_map()), 400

        mongo.db.users.replace_one({"email": user.email}, user.to_map())

        return jsonify(Response(True, user.to_map(), "Success").to_map()), 201


@app.delete("/api/Users/<mail>")
@token_required
def delete_user(email,mail):
    # Find user by email
    found_user_m = mongo.db.users.find_one({"email": mail}) # Use email directly
    if not found_user_m:
        return jsonify(Response(False, {}, "User Not Found").to_map()), 400

    # Delete user by email
    mongo.db.users.delete_one({"email": mail})

    return jsonify(Response(True, {}, "User successfully deleted").to_map()), 200

    

@app.post("/api/Users/ResetPassword")
def reset_password():
        data = request.json
        found_user_m = mongo.db.users.find_one({"email": data["email"]})
        if not found_user_m:
            return jsonify(Response(False, {}, "User Not Found").to_map()), 400
        user = User.from_map(found_user_m)
        user.password = "202cb962ac59075b964b07152d234b70"
        mongo.db.users.replace_one({"email": user.email}, user.to_map())

        return jsonify(Response(True, user.to_map(), "Password has been reset").to_map()), 201
    
    
@app.get("/api/Users/")
@token_required
def get_users(email):
    users_m = mongo.db.users.find()
    users = [User.from_map(x) for x in users_m]
    response = jsonify(Response(True,[x.to_map() for x in users],"").to_map()) 
    return response

    
@app.get("/api/SharedFiles")
@token_required
def get_sharedFiles(email):
    found_user_m = mongo.db.users.find_one({"email": email})
    found_user = User.from_map(found_user_m)
     
    file_list = []
    all_users_m = mongo.db.users.find()
    all_users = [User.from_map(x) for x in all_users_m]
    for user in all_users:
        for folder in user.folders:
            for file in folder.files:
                if found_user.email in file.shared_with:
                    file_list.append(file)
      
    response = jsonify(Response(True,[file.to_map() for file in file_list],"").to_map()) 
    return response


@app.get("/api/PublicFiles")
@token_required
def get_publicFiles(email):
    file_list = []
    all_users_m = mongo.db.users.find()
    all_users = [User.from_map(x) for x in all_users_m]
    for user in all_users:
        for folder in user.folders:
            for file in folder.files:
                if file.is_public:
                    file_list.append(file)
      
    response = jsonify(Response(True,[file.to_map() for file in file_list],"").to_map()) 
    return response


@app.get("/api/Categories")
@token_required
def get_categories(email):
    categories_m = mongo.db.categories.find()     
    categories = [Category.from_map(x) for x in categories_m]
    response = jsonify(Response(True,[x.to_map() for x in categories],"").to_map()) 
    return response


@app.post("/api/Categories")
@token_required
def add_category(email):
        data = request.json
        
        category = Category.from_map(data)
        
        existing_category = mongo.db.categories.find_one({"categoryNameTr": category.category_name_tr,"categoryNameEn": category.category_name_en})
        if existing_category:
            return jsonify(Response(False, {}, "Category already exists").to_map()), 400

        mongo.db.categories.insert_one(category.to_map())

        return jsonify(Response(True, category.to_map(), "Category successfully created").to_map()), 201


@app.put("/api/Categories/<oldCNTr>/<oldCNEn>")
@token_required
def update_category(email,oldCNTr,oldCNEn):
        data = request.json        
        category = Category.from_map(data)        
        found_category_m = mongo.db.categories.find_one({"categoryNameTr": oldCNTr,"categoryNameEn":oldCNEn})
        if not found_category_m:
            return jsonify(Response(False, {}, "Category Not Found").to_map()), 400

        mongo.db.categories.replace_one({"categoryNameTr": oldCNTr,"categoryNameEn":oldCNEn}, category.to_map())

        return jsonify(Response(True, category.to_map(), "Category successfully updated").to_map()), 201


@app.delete("/api/Categories")
@token_required
def delete_category(email):
        data = request.json        
        category = Category.from_map(data)        
        found_category_m = mongo.db.categories.find_one({"categoryNameTr": category.category_name_tr,"categoryNameEn": category.category_name_en})
        if not found_category_m:
            return jsonify(Response(False, {}, "Category Not Found").to_map()), 400

        mongo.db.categories.remove({"categoryNameTr":category.category_name_tr}, category.to_map())

        return jsonify(Response(True, category.to_map(), "Category successfully updated").to_map()), 201


@app.get("/api/Admin/UserCount")
@token_required
def get_user_count(email):
    users_m = mongo.db.users.find()
    users = [User.from_map(x) for x in users_m]
    response = jsonify(Response(True,len(users),"").to_map()) 
    return response


@app.get("/api/Admin/FileCount")
@token_required
def get_file_count(email):
    users_m = mongo.db.users.find()
    users = [User.from_map(x) for x in users_m]
    fileCount = 0
    for user in users:
        for folder in user.folders:
            fileCount += len(folder.files)
            
    response = jsonify(Response(True,fileCount,"").to_map()) 
    return response


@app.get("/api/Admin/FolderCount")
@token_required
def get_folder_count(email):
    users_m = mongo.db.users.find()
    users = [User.from_map(x) for x in users_m]
    folderCount = 0
    for user in users:
        folderCount += len(user.folders)
            
    response = jsonify(Response(True,folderCount,"").to_map()) 
    return response


@app.get("/api/Admin/FileCategoryRatios")
@token_required
def get_filecategory_ratios(email):
    users_m = mongo.db.users.find()
    users = [User.from_map(x) for x in users_m]
    category_ratios={}
    for user in users:
        for folder in user.folders:
            for file in folder.files:
                if file.category in category_ratios:
                    category_ratios[file.category]+=1
                else:
                    category_ratios[file.category]=1

    response = jsonify(Response(True,category_ratios,"").to_map()) 
    return response