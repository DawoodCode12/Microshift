from fastapi import APIRouter, HTTPException
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
import storage
from logic.planner import generate_plan

router = APIRouter()

@router.get("/generate")
def generate_migration():
    monolith = storage.load("monolith.json")
    services = storage.load("services.json")
    analysis = storage.load("analysis.json")
    if not monolith:
        raise HTTPException(status_code=400, detail="No monolith data. Please save monolith first.")
    if not services:
        services = {"services": []}
    if not analysis:
        from logic.analyzer import analyze
        analysis = analyze(monolith, services)
        storage.save("analysis.json", analysis)
    plan = generate_plan(monolith, services, analysis)
    storage.save("migration_plan.json", plan)
    return plan

@router.get("/load")
def load_plan():
    data = storage.load("migration_plan.json")
    if not data:
        raise HTTPException(status_code=404, detail="No migration plan. Run /migration/generate first.")
    return data
