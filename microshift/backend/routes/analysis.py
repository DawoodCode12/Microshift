from fastapi import APIRouter, HTTPException
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
import storage
from logic.analyzer import analyze

router = APIRouter()

@router.get("/run")
def run_analysis():
    monolith = storage.load("monolith.json")
    services = storage.load("services.json")
    if not monolith:
        raise HTTPException(status_code=400, detail="No monolith data. Please save monolith first.")
    if not services:
        services = {"services": []}
    result = analyze(monolith, services)
    storage.save("analysis.json", result)
    return result

@router.get("/load")
def load_analysis():
    data = storage.load("analysis.json")
    if not data:
        raise HTTPException(status_code=404, detail="No analysis found. Run /analysis/run first.")
    return data
