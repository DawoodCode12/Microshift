from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import monolith, services, analysis, migration, export

app = FastAPI(
    title="MicroShift API",
    description="Migration planning tool: Monolith → Microservices",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(monolith.router, prefix="/monolith", tags=["Monolith"])
app.include_router(services.router, prefix="/services", tags=["Services"])
app.include_router(analysis.router, prefix="/analysis", tags=["Analysis"])
app.include_router(migration.router, prefix="/migration", tags=["Migration"])
app.include_router(export.router, prefix="/export", tags=["Export"])

@app.get("/")
def root():
    return {"message": "MicroShift API is running", "version": "1.0.0"}

@app.get("/health")
def health():
    return {"status": "ok"}
