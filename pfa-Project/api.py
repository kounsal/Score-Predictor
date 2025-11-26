# api.py - REST API for Study Score Predictor
from flask import Flask, request, jsonify
from flask_cors import CORS
from dm import add_record, load_data, get_training_data
from model import train_model, predict_score, get_model_info
import os

app = Flask(__name__)
CORS(app) 

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        'status': 'success',
        'message': 'Study Score Predictor API is running'
    })
# get all rec
@app.route('/api/records', methods=['GET'])
def get_records():
    try:
        data = load_data()
        return jsonify({
            'status': 'success',
            'count': len(data),
            'data': data
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
# add rec
@app.route('/api/records', methods=['POST'])
def create_record():
 
    try:
      
        data = request.get_json()
        
        if not data:
            return jsonify({
                'status': 'error',
                'message': 'No data provided'
            }), 400
        
        hours = data.get('hours')
        attendance = data.get('attendance')
        score = data.get('score')
        
        if hours is None or attendance is None or score is None:
            return jsonify({
                'status': 'error',
                'message': 'Missing required fields: hours, attendance, score'
            }), 400
        
        # Validate data types and ranges
        try:
            hours = float(hours)
            attendance = float(attendance)
            score = float(score)
        except ValueError:
            return jsonify({
                'status': 'error',
                'message': 'All fields must be numbers'
            }), 400
        
        if not (0 <= attendance <= 100):
            return jsonify({
                'status': 'error',
                'message': 'Attendance must be between 0 and 100'
            }), 400
        
        if not (0 <= score <= 100):
            return jsonify({
                'status': 'error',
                'message': 'Score must be between 0 and 100'
            }), 400
        
        # Add record
        add_record(hours, score, attendance)
        
        return jsonify({
            'status': 'success',
            'message': 'Record added successfully',
            'data': {
                'hours': hours,
                'attendance': attendance,
                'score': score
            }
        }), 201
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# data stats
@app.route('/api/records/stats', methods=['GET'])
def get_stats():

    try:
        data = get_training_data()
        
        if not data:
            return jsonify({
                'status': 'success',
                'message': 'No data available'
            }), 200
        
        hours = [rec['hours'] for rec in data]
        attendance = [rec['attendance'] for rec in data]
        scores = [rec['score'] for rec in data]
        
        stats = {
            'total_records': len(data),
            'hours': {
                'min': min(hours),
                'max': max(hours),
                'avg': sum(hours) / len(hours)
            },
            'attendance': {
                'min': min(attendance),
                'max': max(attendance),
                'avg': sum(attendance) / len(attendance)
            },
            'scores': {
                'min': min(scores),
                'max': max(scores),
                'avg': sum(scores) / len(scores)
            }
        }
        
        return jsonify({
            'status': 'success',
            'data': stats
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# train mmmodel
@app.route('/api/model/train', methods=['POST'])
def train():
   
    try:
        training_data = get_training_data()
        
        if len(training_data) < 2:
            return jsonify({
                'status': 'error',
                'message': 'Not enough data to train. Need at least 2 records.'
            }), 400
        
        model = train_model()
        
        if model is None:
            return jsonify({
                'status': 'error',
                'message': 'Model training failed'
            }), 500
        
        model_info = get_model_info()
        
        return jsonify({
            'status': 'success',
            'message': 'Model trained successfully',
            'data': {
                'r2_score': model_info.get('r2_score', 'N/A'),
                'n_samples': model_info.get('n_samples', 'N/A'),
                'coefficients': model_info.get('coefficients', []).tolist() if hasattr(model_info.get('coefficients', []), 'tolist') else []
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/model/info', methods=['GET'])
def model_info():
    try:
        info = get_model_info()
        
        if info is None:
            return jsonify({
                'status': 'error',
                'message': 'No trained model found'
            }), 404
        
        return jsonify({
            'status': 'success',
            'data': {
                'r2_score': info.get('r2_score', 'N/A'),
                'n_samples': info.get('n_samples', 'N/A'),
                'coefficients': info.get('coefficients', []).tolist() if hasattr(info.get('coefficients', []), 'tolist') else []
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
# predict score 
@app.route('/api/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'status': 'error',
                'message': 'No data provided'
            }), 400
        
        hours = data.get('hours')
        attendance = data.get('attendance')
        
        if hours is None or attendance is None:
            return jsonify({
                'status': 'error',
                'message': 'Missing required fields: hours, attendance'
            }), 400
        
        try:
            hours = float(hours)
            attendance = float(attendance)
        except ValueError:
            return jsonify({
                'status': 'error',
                'message': 'Hours and attendance must be numbers'
            }), 400
        
        if not (0 <= attendance <= 100):
            return jsonify({
                'status': 'error',
                'message': 'Attendance must be between 0 and 100'
            }), 400
        
        predicted_score = predict_score(hours, attendance)
        
        if predicted_score is None:
            return jsonify({
                'status': 'error',
                'message': 'No trained model found. Please train the model first.'
            }), 400
        
        return jsonify({
            'status': 'success',
            'data': {
                'hours': hours,
                'attendance': attendance,
                'predicted_score': round(predicted_score, 2)
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/predict/batch', methods=['POST'])
def predict_batch():
    try:
        data = request.get_json()
        
        if not data or 'students' not in data:
            return jsonify({
                'status': 'error',
                'message': 'No student data provided. Expected format: {"students": [{"hours": x, "attendance": y}, ...]}'
            }), 400
        
        students = data['students']
        predictions = []
        
        for idx, student in enumerate(students):
            hours = student.get('hours')
            attendance = student.get('attendance')
            
            if hours is None or attendance is None:
                predictions.append({
                    'index': idx,
                    'error': 'Missing hours or attendance'
                })
                continue
            
            try:
                hours = float(hours)
                attendance = float(attendance)
                
                if not (0 <= attendance <= 100):
                    predictions.append({
                        'index': idx,
                        'error': 'Attendance must be between 0 and 100'
                    })
                    continue
                
                predicted_score = predict_score(hours, attendance)
                
                if predicted_score is None:
                    predictions.append({
                        'index': idx,
                        'error': 'Model not trained'
                    })
                    continue
                
                predictions.append({
                    'index': idx,
                    'hours': hours,
                    'attendance': attendance,
                    'predicted_score': round(predicted_score, 2)
                })
                
            except ValueError:
                predictions.append({
                    'index': idx,
                    'error': 'Invalid number format'
                })
        
        return jsonify({
            'status': 'success',
            'data': predictions
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)