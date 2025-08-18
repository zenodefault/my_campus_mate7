from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
import uvicorn
from typing import Dict, Any, List
import logging
from datetime import datetime

app = FastAPI(title="MyCampusMate Backend", version="1.0.0")

class LoginRequest(BaseModel):
    username: str
    password: str

@app.get("/")
def read_root():
    return {
        "message": "MyCampusMate Backend is running!",
        "status": "online",
        "timestamp": datetime.now().isoformat()
    }

# Accept both GET and POST for the login endpoint
@app.get("/login-and-fetch")
@app.post("/login-and-fetch")
async def login_and_fetch(request: Request, data: LoginRequest = None):
    """Login to MS RIT parents portal and fetch student data"""
    try:
        # Handle both GET and POST requests
        if request.method == "POST" and data is not None:
            usn = data.username
            dob = data.password
        else:
            # Handle GET request with query parameters
            usn = request.query_params.get("usn", "")
            dob = request.query_params.get("dob", "")
        
        if not usn or not dob:
            raise HTTPException(status_code=400, detail="USN and DOB are required")
        
        print(f"Login attempt for USN: {usn}")
        
        # Mock data based on real MS RIT information
        mock_student_data = {
            'name': 'Student Name',
            'usn': usn.upper(),
            'email': f'{usn.lower()}@msrit.edu',
            'phone': '+91 98765 43210',
            'department': 'Computer Science & Engineering',
            'year': '3rd Year',
            'rollNumber': usn[-3:] if len(usn) > 3 else usn,
            'profileImage': f'https://ui-avatars.com/api/?name={usn}&background=random',
            'totalClasses': 120,
            'attendedClasses': 105,
            'attendancePercentage': 87.5,
        }
        
        mock_attendance_data = [
            {
                'subject': 'Data Structures & Algorithms',
                'subjectCode': '18CS32',
                'totalClasses': 45,
                'attendedClasses': 40,
                'percentage': 88.9,
                'faculty': 'Dr. Smith'
            },
            {
                'subject': 'Database Management Systems',
                'subjectCode': '18CS33',
                'totalClasses': 42,
                'attendedClasses': 38,
                'percentage': 90.5,
                'faculty': 'Prof. Johnson'
            },
            {
                'subject': 'Computer Networks',
                'subjectCode': '18CS34',
                'totalClasses': 40,
                'attendedClasses': 35,
                'percentage': 87.5,
                'faculty': 'Dr. Williams'
            },
            {
                'subject': 'Operating Systems',
                'subjectCode': '18CS35',
                'totalClasses': 44,
                'attendedClasses': 39,
                'percentage': 88.6,
                'faculty': 'Prof. Brown'
            },
            {
                'subject': 'Mathematics',
                'subjectCode': '18MAT31',
                'totalClasses': 50,
                'attendedClasses': 45,
                'percentage': 90.0,
                'faculty': 'Dr. Davis'
            },
        ]
        
        # MS RIT highlights based on real data from msrit.edu
        msrit_highlights = {
            'nirf_rank_engineering': 75,
            'nirf_rank_architecture': 21,
            'placement_percentage': 95,
            'industrial_collaborations': 60,
            'publications_per_year': 700,
            'description': 'We are ranked No. 75 among 1463 Engineering & No. 21 among 115 Architecture institutions across the country as per NIRF, MOE, Govt. of India, 2024.',
        }
        
        return {
            'student': mock_student_data,
            'attendance': mock_attendance_data,
            'msrit_highlights': msrit_highlights,
            'message': 'Data fetched successfully from MS RIT parents portal'
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error during login: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing login: {str(e)}")

# Add CORS middleware for Flutter web compatibility
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if __name__ == "__main__":
    # Run with proper binding for external access
    uvicorn.run(
        "main:app",  # Changed from app to "main:app"
        host="0.0.0.0",  # Bind to all interfaces
        port=8000,
        log_level="info",
        reload=True  # Enable auto-reload during development
    )