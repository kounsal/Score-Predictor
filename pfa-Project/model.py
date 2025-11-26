# model.py
import numpy as np
import pickle
from dm import get_training_data

MODEL_FILE = "model.pkl"

def train_model():
#    LINEAT REGRESSION
    data = get_training_data()
    if len(data) < 2:
        return None
    
    X = np.array([[rec["hours"], rec["attendance"]] for rec in data])
    y = np.array([rec["score"] for rec in data])

    X_with_intercept = np.column_stack([np.ones(len(X)), X])
    
    try:
        beta = np.linalg.inv(X_with_intercept.T @ X_with_intercept) @ X_with_intercept.T @ y
        
        # Calculate R² score for model evaluation
        y_pred = X_with_intercept @ beta
        ss_res = np.sum((y - y_pred) ** 2)
        ss_tot = np.sum((y - np.mean(y)) ** 2)
        r2_score = 1 - (ss_res / ss_tot)
        
        # Save model coefficients and metadata
        model_data = {
            'beta': beta,
            'r2_score': r2_score,
            'n_samples': len(data)
        }
        
        with open(MODEL_FILE, "wb") as f:
            pickle.dump(model_data, f)
        
        return beta
    except np.linalg.LinAlgError:
        return None

def predict_score(hours, attendance):
    """Predict score based on hours studied and attendance percentage."""
    try:
        with open(MODEL_FILE, "rb") as f:
            model_data = pickle.load(f)
            
        if isinstance(model_data, dict):
            beta = model_data['beta']
        else:
            beta = model_data
            
    except FileNotFoundError:
        return None
    

    prediction = beta[0] + beta[1] * hours + beta[2] * attendance
    return max(0, min(100, prediction)) 

def get_model_info():
    try:
        with open(MODEL_FILE, "rb") as f:
            model_data = pickle.load(f)
            
        if isinstance(model_data, dict):
            return {
                'r2_score': model_data.get('r2_score', 'N/A'),
                'n_samples': model_data.get('n_samples', 'N/A'),
                'coefficients': model_data.get('beta', [])
            }
        else:
            return {
                'r2_score': 'N/A',
                'n_samples': 'N/A',
                'coefficients': model_data
            }
    except FileNotFoundError:
        return None
