import os
import fitz  # PyMuPDF
import re
from datetime import datetime,timezone

from models.exam import Exam

def read_schedule(schedule_txt_path: str) -> dict:
    schedule_dict = {}

    with open(schedule_txt_path, 'r', encoding='utf-8') as file:
        for line in file:
            parts = line.strip().split(',')
            if len(parts) == 2:  # Ensure there are exactly two parts
                key = parts[0].strip()  # First part as key
                value = parts[1].strip()  # Second part as value
                schedule_dict[key] = value  # Add to dictionary

    return schedule_dict

def read_exams(pdf_path:str,schedule_dict:str) -> list[Exam]:
    exams = []
    for root, dirs, files in os.walk(pdf_path):
        for file in files:
            if file.endswith('.pdf') and '_class' not in file and '_student_papers' not in file:
                pdf_path = os.path.join(root, file)
                print(f"Processing: {pdf_path}")
                text = ""
                with fitz.open(pdf_path) as doc:
                    for page in doc:
                        text += page.get_text()
                exam_name_match = re.search(r'Dersin Adi:\s*(.*?)\n', text)
                exam_name = exam_name_match.group(1).strip() if exam_name_match else None

                students = []
                lines = text.replace("Chameleon © Trakya Üniversitesi - Bilgisayar Mühendisligi - 2023\n","").split("\n")
                counter = 0
                while(lines[counter]!="Sinav Yeri"):
                    counter+=1
                    continue     
                counter+=1               
                while(counter+4<len(lines)):
                    id = lines[counter]                    
                    student_id = lines[counter+1]
                    student_name = lines[counter+2]
                    class_name = lines[counter+3]
                    counter += 4
                    students.append({student_id: class_name})

                exams.append(Exam(None,exam_name,datetime.strptime(schedule_dict[exam_name], "%d.%m.%Y %H:%M").replace(tzinfo=timezone.utc),students))
    return exams