import json
import os

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
os.makedirs(DATA_DIR, exist_ok=True)

def _path(filename: str) -> str:
    return os.path.join(DATA_DIR, filename)

def load(filename: str) -> dict:
    p = _path(filename)
    if not os.path.exists(p):
        return {}
    with open(p, "r") as f:
        return json.load(f)

def save(filename: str, data: dict):
    with open(_path(filename), "w") as f:
        json.dump(data, f, indent=2)

def load_list(filename: str) -> list:
    p = _path(filename)
    if not os.path.exists(p):
        return []
    with open(p, "r") as f:
        return json.load(f)

def save_list(filename: str, data: list):
    with open(_path(filename), "w") as f:
        json.dump(data, f, indent=2)
