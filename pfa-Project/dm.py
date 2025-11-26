# data_manager.py
import json

DATA_FILE = "data.json"

def add_record(hours, score, attendance):
    """Add a new study record with hours, score, and attendance."""
    data = load_data()
    # Add record in the format that matches existing data
    new_record = {
        "Student_ID": f"S{len(data) + 1:03d}",
        "Study_Hours_per_Week": hours,
        "Attendance_Rate": attendance,
        "Final_Exam_Score": score,
        "Gender": "Unknown",
        "Past_Exam_Scores": 0,
        "Parental_Education_Level": "Unknown",
        "Internet_Access_at_Home": "Unknown",
        "Extracurricular_Activities": "Unknown",
        "Pass_Fail": "Pass" if score >= 60 else "Fail"
    }
    data.append(new_record)
    
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=4)

def load_data():
    """Load all study records from JSON file."""
    try:
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return []

def get_training_data():
    data = load_data()
    normalized_data = []
    
    for rec in data:
        hours = rec.get("Study_Hours_per_Week") or rec.get("hours", 0)
        attendance = rec.get("Attendance_Rate") or rec.get("attendance", 0)
        score = rec.get("Final_Exam_Score") or rec.get("score", 0)
        
        normalized_data.append({
            "hours": hours,
            "attendance": attendance,
            "score": score
        })
    
    return normalized_data
