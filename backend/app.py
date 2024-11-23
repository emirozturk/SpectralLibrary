from flask import Flask,request,jsonify
from flask_pymongo import PyMongo
import jwt
from functools import wraps
from flask_cors import CORS
from Models.Response import Response
from Models.User import User


app = Flask(__name__)


SECRET_KEY = "spectralsecretkeywithemirozturk"


app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb://localhost:27017/spectraldb"
mongo = PyMongo(app)
CORS(app,resources={r"/*":{"origins":"*"}})  # This will allow all origins by default

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
            current_user_id = decoded_token.get("userId")
        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
            return jsonify({"success": False, "message": "Invalid or expired token"}), 403
        
        return f(current_user_id, *args, **kwargs)
    
    return decorated_function

@app.post("/api/Users/CheckLogin")
def check_login():
    email = request.json.get("email")
    password = request.json.get("password")
    foundMongoUser = mongo.db.users.find_one({"email":email,"password":password})
    if foundMongoUser !=None:
        foundUser = User.from_dict(foundMongoUser)
        return jsonify(Response.success(foundUser)),200
    return jsonify(Response.fail("User Not Found")),404


"""

@app.post('/api/Sinavci/CheckClassroom')
def check_classroom():
    student_id = request.json.get('student_id')    
    
    start_time = datetime.now() - timedelta(minutes=15)
    end_time = datetime.now() + timedelta(minutes=10)
    found_exams = list(mongo.db.exams.find({
            "exam_datetime": {
                "$gte": start_time,
                "$lte": end_time
            }
        }))
    locations = []
    if not found_exams:
        return jsonify({'location': None})
    else:
        location = None
        for exam in found_exams:
            examClass = Exam.from_map(exam)
            location = next((entry[student_id] for entry in examClass.student_dict if student_id in entry), None)
            if location is not None:
                locations.append(location)

    if len(locations) == 0:
        locations = "Bulunamadı"

    return jsonify({'location': " ".join(locations)})


@app.post("/api/Sinavci/AddExams")
@token_required
def sinavci_add_exams(current_user_id):
    if not current_user_id=="7646":
        return "Nooo"
    pdf_path = request.json.get('pdf_path')
    schedule_dict = read_schedule(os.path.join(pdf_path,"schedule.txt"))
    exams = read_exams(pdf_path,schedule_dict)
    for exam in exams:
        mongo_exam = mongo.db.exams.find_one({"name": exam.name,"exam_datetime":exam.exam_datetime})    
        if not mongo_exam:
            mongo.db.exams.insert_one(exam.to_map())
        else:
            mongo.db.users.update_one(
                {"name": exam["name"]},
                {"$set": {
                    "exam_datetime": exam['exam_datetime'],
                    "student_dict": exam['student_dict'],
                }}
            )

    response = jsonify({
        "success": True,
    })
    response.headers.add("Access-Control-Allow-Origin","*")
    return response


@app.post("/api/Users/AddUser")
@token_required
def add_user(current_user_id):
    if current_user_id=="1060203022":
        data = request.json
        
        # Extract user details from the request
        user = User.from_map(data)
        
        # Check if the user already exists
        existing_user = mongo.db.users.find_one({"userId": user.user_id})
        if existing_user:
            return jsonify(Response(False, {}, "User already exists").to_dict()), 400

        # Hash password (not implemented in this example, but should be done in production)
        # user.password = hash_password(user.password)

        # Save new user to MongoDB
        mongo.db.users.insert_one(user.to_map())

        return jsonify(Response(True, user.to_map(), "User successfully created").to_dict()), 201


@app.post("/api/Users/AddResult")
@token_required
def create_selections(current_user_id):
    if current_user_id == "1060203022":
        data = request.json
        username = data.get("name")
        lecturer = data.get("lecturer")

        existing_user = mongo.db.users.find_one({"name": username})
        if existing_user:
            mongo.db.users.update_one(
                {"name": username}, 
                {"$set": {"lecturerResult": lecturer}}
            )
            return jsonify(Response(True, "Success", "User successfully updated").to_dict()), 200
        else:
            return jsonify(Response(False, "Error", "User not found").to_dict()), 404
    else:
        return jsonify(Response(False, "Unauthorized", "Access denied").to_dict()), 403



@app.get("/api/Users/")
@token_required
def get_users(current_user_id):
    if current_user_id=="1060203022":
        users = mongo.db.users.find()     
        user_list=[]   
        for user in users:
            user["transcript"]=None
            userr = User.from_map(user).to_map()
            user_list.append(userr)
        response = jsonify(Response(True,user_list,"").to_dict()) 
        response.headers.add("Access-Control-Allow-Origin","*")
        return response


@app.get("/api/Users/Empty")
@token_required
def get_users_without_gno(current_user_id):
    if current_user_id=="1060203022":
        users = mongo.db.users.find()     
        user_list=[]   
        for user in users:
            if user["gnocheck"]==None:
                user["transcript"]=None
                userr = User.from_map(user).to_map()
                user_list.append({"no":userr["userId"],"adsoyad":userr["name"]})
        response = jsonify(Response(True,user_list,"").to_dict()) 
        response.headers.add("Access-Control-Allow-Origin","*")
        return response


@app.post("/api/Users/CheckUser")
def check_user():
    data = request.json
    user = User.from_map(data)

    user_record = mongo.db.users.find_one({"userId": user.user_id})
    
    if user_record:        
        if user.password==user_record['password']:
            token = jwt.encode({
                'userId': user_record['userId'],
                'exp': datetime.now() + timedelta(hours=1)
            }, SECRET_KEY, algorithm="HS256")
            user = User.from_map(user_record)
            user.transcript = None
            user_with_token = UserWithToken(user, token)
            result = user_with_token.to_map()
            response = jsonify(Response(True, result, "Başarılı").to_dict())
            response.headers.add("Access-Control-Allow-Origin","*")
            return response
        else:
            response = jsonify(Response(False, {}, "Hatalı Şifre").to_dict())
            response.headers.add("Access-Control-Allow-Origin","*")
            return response
    else:
        response = jsonify(Response(False, {}, "Kullanıcı Bulunamadı").to_dict())
        response.headers.add("Access-Control-Allow-Origin","*")
        return response


@app.post("/api/Users/ResetPassword")
def reset_password():
    return Response(True,"Şifre Sıfırlandı","").to_dict()


@app.post("/api/postSelections")
@token_required
def post_selections(current_user_id):
    file = request.files.get('file')
    
    user_with_token = request.form.get('userWithToken')
    selected_lecturers = request.form.get('selectedLecturers')
    gno = request.form.get('gno')

    # Retrieve the current user from MongoDB
    user_record = mongo.db.users.find_one({"userId": current_user_id})
    
    # If the user doesn't exist, return an error
    if not user_record:
        return Response(False,"Kullanıcı Bulunamadı","").to_dict()

    # Convert the MongoDB document into a User object
    user = User.from_map(user_record)

    # Update the user object with new selections and gno
    user_with_token_data = json.loads(user_with_token)
    selected_lecturers_data = json.loads(selected_lecturers)
    
    user.selections = selected_lecturers_data
    user.gno = float(gno)  # Ensure gno is stored as a float

    # Handle file upload and save the transcript to MongoDB
    if file:
        # Read file contents in binary
        file_content = file.read()
        # Store the transcript (binary content) in the user object
        user.transcript = file_content

    # Convert the updated User object back into a dictionary for MongoDB
    updated_user_data = user.to_map()

    # Update the user's record in MongoDB, specifying the fields to update
    mongo.db.users.update_one(
        {"userId": current_user_id},
        {"$set": {
            "selections": updated_user_data['selections'],
            "gno": updated_user_data['gno'],
            "transcript": updated_user_data['transcript']  # Save transcript
        }}
    )

    response = jsonify({
        "success": True,
        "filename": file.filename if file else None,
        "userWithToken": user_with_token_data,
        "selectedLecturers": selected_lecturers_data
    })
    response.headers.add("Access-Control-Allow-Origin","*")
    return response

    
@app.get("/api/getSelections")
@token_required
def get_selections(current_user_id):    
    user_record = mongo.db.users.find_one({"userId": current_user_id})
    if not user_record:
        return Response(False,"Kullanıcı Bulunamadı","").to_dict()


    user = User.from_map(user_record)
    if user.gno == None:
        user.gno = 0
    list_of_lecturers = user.selections+[f"{user.gno}"]
    response = jsonify(Response(True,list_of_lecturers,"").to_dict())   
    response.headers.add("Access-Control-Allow-Origin","*")
    return response 


@app.get("/api/getResultLecturer")
@token_required
def get_result_lecturer(current_user_id):    
    user_record = mongo.db.users.find_one({"userId": current_user_id})
    if not user_record:
        return Response(False,"Kullanıcı Bulunamadı","").to_dict()


    user = User.from_map(user_record)
    response = jsonify(Response(True,user.lecturer_result,"").to_dict())   
    response.headers.add("Access-Control-Allow-Origin","*")
    return response 

    
@app.get("/api/getLecturers")
@token_required
def get_lecturer_names(current_user_id):
    user_record = mongo.db.users.find_one({"userId": current_user_id})    
    if not user_record:
        return Response(False,"Kullanıcı Bulunamadı","").to_dict()

    list_of_lecturers = [
        "",
        "Prof. Dr. Muharrem Tolga SAKALLI",
        "Doç. Dr. Deniz Mertkan GEZGİN",
        "Dr. Öğr. Üyesi Altan MESUT",
        "Dr. Öğr. Üyesi Andaç ŞAHİN MESUT",
        "Dr. Öğr. Üyesi Aydın CARUS",
        "Dr. Öğr. Üyesi Cem TAŞKIN",
        "Dr. Öğr. Üyesi Deniz TAŞKIN",
        "Dr. Öğr. Üyesi Derya ALSANCAK ARDA",
        "Dr. Öğr. Üyesi Emir ÖZTÜRK",
        "Dr. Öğr. Üyesi Fatma BÜYÜKSARAÇOĞLU SAKALLI",
        "Dr. Öğr. Üyesi Özlem AYDIN FİDAN",
        "Dr. Öğr. Üyesi Özlem UÇAR",
        "Dr. Öğr. Üyesi Rembiye KANDEMİR",
        "Dr. Öğr. Üyesi Tarık YERLİKAYA",
        "Dr. Öğr. Üyesi Turgut DOĞAN",
        "Dr. Öğr. Üyesi Gülsüm Gözde YILMAZGÜÇ BAL"
        "Arş. Gör. Dr. Işıl ÇETİNTAV",
        "Arş. Gör. Dr. Ümit Can KUMDERELİ"
    ]
    response = jsonify(Response(True,list_of_lecturers,"").to_dict())
    response.headers.add("Access-Control-Allow-Origin","*")
    return response


"""