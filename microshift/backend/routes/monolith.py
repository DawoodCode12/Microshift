from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
import storage

router = APIRouter()

class Module(BaseModel):
    id: str
    name: str
    description: Optional[str] = ""
    layer: Optional[str] = "business"  # ui, business, data, integration
    complexity: Optional[str] = "medium"  # low, medium, high

class Dependency(BaseModel):
    from_module: str
    to_module: str
    type: Optional[str] = "uses"  # uses, calls, reads, writes
    strength: Optional[str] = "medium"  # low, medium, high

class MonolithInput(BaseModel):
    system_name: str
    description: Optional[str] = ""
    modules: List[Module]
    dependencies: List[Dependency]

@router.post("/save")
def save_monolith(data: MonolithInput):
    storage.save("monolith.json", data.dict())
    return {"status": "saved", "modules": len(data.modules), "dependencies": len(data.dependencies)}

@router.get("/load")
def load_monolith():
    data = storage.load("monolith.json")
    if not data:
        raise HTTPException(status_code=404, detail="No monolith data found")
    return data

@router.delete("/clear")
def clear_monolith():
    storage.save("monolith.json", {})
    return {"status": "cleared"}

@router.get("/sample")
def get_sample():
    """Returns a sample monolith input to help users get started."""
    return {
        "system_name": "Library Management System",
        "description": "A legacy monolithic library system handling books, members, loans, and reporting.",
        "modules": [
            {"id": "auth", "name": "Authentication", "description": "Login, sessions, user roles", "layer": "business", "complexity": "medium"},
            {"id": "catalog", "name": "Book Catalog", "description": "Book inventory and metadata", "layer": "business", "complexity": "high"},
            {"id": "members", "name": "Member Management", "description": "Member registration and profiles", "layer": "business", "complexity": "medium"},
            {"id": "loans", "name": "Loan Management", "description": "Issue, return and renew books", "layer": "business", "complexity": "high"},
            {"id": "notifications", "name": "Notifications", "description": "Email and SMS alerts", "layer": "integration", "complexity": "low"},
            {"id": "reports", "name": "Reporting", "description": "Usage stats and overdue reports", "layer": "business", "complexity": "medium"},
            {"id": "db", "name": "Shared Database", "description": "Single PostgreSQL database", "layer": "data", "complexity": "high"},
            {"id": "ui", "name": "Web UI", "description": "Frontend web application", "layer": "ui", "complexity": "medium"}
        ],
        "dependencies": [
            {"from_module": "ui", "to_module": "auth", "type": "calls", "strength": "high"},
            {"from_module": "ui", "to_module": "catalog", "type": "calls", "strength": "high"},
            {"from_module": "ui", "to_module": "members", "type": "calls", "strength": "high"},
            {"from_module": "ui", "to_module": "loans", "type": "calls", "strength": "high"},
            {"from_module": "ui", "to_module": "reports", "type": "calls", "strength": "medium"},
            {"from_module": "loans", "to_module": "catalog", "type": "reads", "strength": "high"},
            {"from_module": "loans", "to_module": "members", "type": "reads", "strength": "high"},
            {"from_module": "loans", "to_module": "notifications", "type": "calls", "strength": "medium"},
            {"from_module": "reports", "to_module": "loans", "type": "reads", "strength": "high"},
            {"from_module": "reports", "to_module": "catalog", "type": "reads", "strength": "medium"},
            {"from_module": "auth", "to_module": "db", "type": "reads", "strength": "high"},
            {"from_module": "catalog", "to_module": "db", "type": "writes", "strength": "high"},
            {"from_module": "members", "to_module": "db", "type": "writes", "strength": "high"},
            {"from_module": "loans", "to_module": "db", "type": "writes", "strength": "high"},
            {"from_module": "reports", "to_module": "db", "type": "reads", "strength": "high"}
        ]
    }
