from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
import storage

router = APIRouter()

class MicroService(BaseModel):
    id: str
    name: str
    description: Optional[str] = ""
    mapped_modules: List[str]  # list of monolith module IDs
    port: Optional[int] = None
    technology: Optional[str] = "Python/FastAPI"
    priority: Optional[int] = 1  # migration order priority

class ServicesInput(BaseModel):
    services: List[MicroService]

@router.post("/save")
def save_services(data: ServicesInput):
    storage.save("services.json", data.dict())
    return {"status": "saved", "count": len(data.services)}

@router.get("/load")
def load_services():
    data = storage.load("services.json")
    if not data:
        raise HTTPException(status_code=404, detail="No services defined yet")
    return data

@router.delete("/clear")
def clear_services():
    storage.save("services.json", {})
    return {"status": "cleared"}

@router.get("/sample")
def get_sample():
    return {
        "services": [
            {
                "id": "svc-auth",
                "name": "Auth Service",
                "description": "Handles authentication and authorization",
                "mapped_modules": ["auth"],
                "port": 8001,
                "technology": "Python/FastAPI",
                "priority": 1
            },
            {
                "id": "svc-catalog",
                "name": "Catalog Service",
                "description": "Book inventory and search",
                "mapped_modules": ["catalog"],
                "port": 8002,
                "technology": "Python/FastAPI",
                "priority": 2
            },
            {
                "id": "svc-members",
                "name": "Member Service",
                "description": "Member profiles and management",
                "mapped_modules": ["members"],
                "port": 8003,
                "technology": "Python/FastAPI",
                "priority": 3
            },
            {
                "id": "svc-loans",
                "name": "Loan Service",
                "description": "Book lending and returns",
                "mapped_modules": ["loans"],
                "port": 8004,
                "technology": "Python/FastAPI",
                "priority": 4
            },
            {
                "id": "svc-notifications",
                "name": "Notification Service",
                "description": "Email and SMS dispatch",
                "mapped_modules": ["notifications"],
                "port": 8005,
                "technology": "Python/FastAPI",
                "priority": 2
            },
            {
                "id": "svc-reports",
                "name": "Reporting Service",
                "description": "Analytics and reporting",
                "mapped_modules": ["reports"],
                "port": 8006,
                "technology": "Python/FastAPI",
                "priority": 5
            }
        ]
    }
