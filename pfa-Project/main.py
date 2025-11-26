# gui_main.py
import tkinter as tk
from tkinter import messagebox
from dm import add_record, load_data
from model import train_model, predict_score


class StudyApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Study Tracker & Score Predictor")

        # ---------- Add Record Section ----------
        add_frame = tk.LabelFrame(root, text="Add Study Record", padx=10, pady=10)
        add_frame.pack(fill="x", padx=10, pady=5)

        tk.Label(add_frame, text="Hours studied:").grid(row=0, column=0, sticky="w")
        self.hours_entry = tk.Entry(add_frame, width=10)
        self.hours_entry.grid(row=0, column=1, padx=5)

        tk.Label(add_frame, text="Attendance %:").grid(row=0, column=2, sticky="w", padx=(10, 0))
        self.attendance_entry = tk.Entry(add_frame, width=10)
        self.attendance_entry.grid(row=0, column=3, padx=5)

        tk.Label(add_frame, text="Score:").grid(row=0, column=4, sticky="w", padx=(10, 0))
        self.score_entry = tk.Entry(add_frame, width=10)
        self.score_entry.grid(row=0, column=5, padx=5)

        add_btn = tk.Button(add_frame, text="Add Record", command=self.add_record)
        add_btn.grid(row=0, column=6, padx=(10, 0))

        # ---------- Records Section ----------
        records_frame = tk.LabelFrame(root, text="Study Records", padx=10, pady=10)
        records_frame.pack(fill="both", expand=True, padx=10, pady=5)

        self.records_listbox = tk.Listbox(records_frame, height=8)
        self.records_listbox.pack(side="left", fill="both", expand=True)

        scrollbar = tk.Scrollbar(records_frame, orient="vertical", command=self.records_listbox.yview)
        scrollbar.pack(side="right", fill="y")
        self.records_listbox.config(yscrollcommand=scrollbar.set)

        refresh_btn = tk.Button(root, text="Refresh Records", command=self.load_records)
        refresh_btn.pack(pady=(0, 5))

        # ---------- Model & Prediction Section ----------
        model_frame = tk.LabelFrame(root, text="Model & Prediction", padx=10, pady=10)
        model_frame.pack(fill="x", padx=10, pady=5)

        train_btn = tk.Button(model_frame, text="Train Model", command=self.train_model)
        train_btn.grid(row=0, column=0, padx=5, pady=5)

        tk.Label(model_frame, text="Hours:").grid(row=0, column=1, sticky="w", padx=(10, 0))
        self.predict_hours_entry = tk.Entry(model_frame, width=10)
        self.predict_hours_entry.grid(row=0, column=2, padx=5)

        tk.Label(model_frame, text="Attendance %:").grid(row=0, column=3, sticky="w", padx=(10, 0))
        self.predict_attendance_entry = tk.Entry(model_frame, width=10)
        self.predict_attendance_entry.grid(row=0, column=4, padx=5)

        predict_btn = tk.Button(model_frame, text="Predict Score", command=self.predict)
        predict_btn.grid(row=0, column=5, padx=5)

        self.result_label = tk.Label(model_frame, text="Predicted score: -")
        self.result_label.grid(row=1, column=0, columnspan=6, sticky="w", pady=(5, 0))

        # Load records on start
        self.load_records()

    # ---------- Callbacks ----------
    def add_record(self):
        hours_text = self.hours_entry.get().strip()
        attendance_text = self.attendance_entry.get().strip()
        score_text = self.score_entry.get().strip()

        if not hours_text or not attendance_text or not score_text:
            messagebox.showwarning("Input Error", "Please enter hours, attendance, and score.")
            return

        try:
            hours = float(hours_text)
            attendance = float(attendance_text)
            score = float(score_text)
            
            if not (0 <= attendance <= 100):
                messagebox.showerror("Input Error", "Attendance must be between 0 and 100.")
                return
        except ValueError:
            messagebox.showerror("Input Error", "All fields must be numbers.")
            return

        add_record(hours, score, attendance)
        messagebox.showinfo("Success", "Record added successfully!")

        self.hours_entry.delete(0, tk.END)
        self.attendance_entry.delete(0, tk.END)
        self.score_entry.delete(0, tk.END)
        self.load_records()

    def load_records(self):
        self.records_listbox.delete(0, tk.END)
        data = load_data()
        if not data:
            self.records_listbox.insert(tk.END, "No records yet. Add some!")
            return

        # Show last 20 records only (to avoid UI clutter with large dataset)
        display_data = data[-20:] if len(data) > 20 else data
        
        if len(data) > 20:
            self.records_listbox.insert(tk.END, f"--- Showing last 20 of {len(data)} records ---")
        
        for i, rec in enumerate(display_data, start=max(1, len(data) - 19)):
            # Support both old and new data format
            hours = rec.get("Study_Hours_per_Week") or rec.get("hours", 'N/A')
            attendance = rec.get("Attendance_Rate") or rec.get("attendance", 'N/A')
            score = rec.get("Final_Exam_Score") or rec.get("score", 'N/A')
            student_id = rec.get("Student_ID", f"#{i}")
            
            # Format attendance to 1 decimal place if it's a float
            if isinstance(attendance, float):
                attendance = f"{attendance:.1f}"
            
            text = f"{student_id}: {hours}h/week | {attendance}% | Score: {score}"
            self.records_listbox.insert(tk.END, text)

    def train_model(self):
        from dm import get_training_data
        from model import get_model_info
        
        training_data = get_training_data()
        if len(training_data) < 2:
            messagebox.showwarning("Training", "Not enough data to train. Add at least 2 records.")
            return
            
        model = train_model()
        if model is None:
            messagebox.showwarning("Training", "Failed to train model. Please check your data.")
        else:
            model_info = get_model_info()
            if model_info and 'r2_score' in model_info:
                r2 = model_info['r2_score']
                n_samples = model_info['n_samples']
                messagebox.showinfo("Training Success", 
                    f"Model trained successfully!\n\n"
                    f"Training samples: {n_samples}\n"
                    f"R² Score: {r2:.4f}\n\n"
                    f"You can now predict scores.")
            else:
                messagebox.showinfo("Training", "Model trained successfully! You can now predict scores.")

    def predict(self):
        hours_text = self.predict_hours_entry.get().strip()
        attendance_text = self.predict_attendance_entry.get().strip()
        
        if not hours_text or not attendance_text:
            messagebox.showwarning("Input Error", "Please enter both hours and attendance to predict.")
            return

        try:
            hours = float(hours_text)
            attendance = float(attendance_text)
            
            if not (0 <= attendance <= 100):
                messagebox.showerror("Input Error", "Attendance must be between 0 and 100.")
                return
        except ValueError:
            messagebox.showerror("Input Error", "Hours and attendance must be numbers.")
            return

        predicted = predict_score(hours, attendance)
        if predicted is None:
            messagebox.showwarning("Model", "No trained model found. Train the model first.")
            return

        self.result_label.config(text=f"Predicted score: {predicted:.2f}")


def main():
    root = tk.Tk()
    app = StudyApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
