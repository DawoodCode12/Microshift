#  MicroShift — Monolith to Microservices Migration Planner
### Software Engineering Project — Group 8 | DUET

A full-stack migration planning and simulation tool that helps engineering teams plan how to break a monolithic system into microservices while maintaining business continuity.



## Project Structure

```
microshift/
├── backend/                        # Python FastAPI backend
│   ├── main.py                     # App entry point, CORS, routers
│   ├── storage.py                  # JSON file persistence helper
│   ├── requirements.txt            # Python dependencies
│   ├── Procfile                    # Railway deployment command
│   ├── nixpacks.toml               # Railway build config
│   ├── .gitignore
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── monolith.py             # POST/GET monolith data
│   │   ├── services.py             # POST/GET microservice definitions
│   │   ├── analysis.py             # GET run + load analysis
│   │   ├── migration.py            # GET generate + load plan
│   │   └── export.py               # GET markdown + JSON export
│   ├── logic/
│   │   ├── __init__.py
│   │   ├── analyzer.py             # Risk scoring, cycle detection
│   │   └── planner.py              # Strangler Fig plan generator
│   └── data/                       # Auto-created, stores JSON files
│       ├── monolith.json
│       ├── services.json
│       ├── analysis.json
│       └── migration_plan.json
│
└── frontend/                       # Flutter cross-platform app
    ├── pubspec.yaml
    ├── .gitignore
    ├── android/
    │   └── app/src/main/
    │       └── AndroidManifest.xml # Internet permission + cleartext
    └── lib/
        ├── main.dart               # App entry, routing, nav shell
        ├── services/
        │   ├── api_service.dart    # All HTTP calls to FastAPI
        │   ├── app_state.dart      # ChangeNotifier state management
        │   └── theme.dart          # Dark theme, colors, fonts
        ├── widgets/
        │   └── common_widgets.dart # SectionCard, RiskBadge, StatBox
        └── screens/
            ├── dashboard_screen.dart   # Home + workflow overview
            ├── monolith_screen.dart    # Input modules & dependencies
            ├── services_screen.dart    # Define target microservices
            ├── analysis_screen.dart    # Risk analysis dashboard
            └── plan_screen.dart        # Migration plan + export

## LOCAL SETUP GUIDE

### Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| Python | 3.10+ | https://python.org |
| pip | latest | (comes with Python) |
| Flutter SDK | 3.19+ | https://flutter.dev |
| Android Studio | latest | For Android emulator |
| VS Code | any | Recommended editor |
| Git | any | https://git-scm.com |

---

### STEP 1: Clone / Set Up the Project

If using Git:
```bash
git clone https://github.com/YOUR_USERNAME/microshift.git
cd microshift
```

Or just copy the `microshift/` folder to your machine.

---

### STEP 2: Run the Backend

Open a terminal and navigate to the backend folder:

```bash
cd microshift/backend
```

Create a virtual environment (recommended):
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS / Linux
python3 -m venv venv
source venv/bin/activate
```

Install dependencies:
```bash
pip install -r requirements.txt
```

Start the server:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```


INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete.
```

Test it: Open http://127.0.0.1:8000 in a browser → should show `{"message":"MicroShift API is running"}`

View API docs: http://127.0.0.1:8000/docs

---

### STEP 3: Run the Flutter Frontend

Open a **new terminal** (keep backend running in the old one):

```bash
cd microshift/frontend
```

Get Flutter packages:
```bash
flutter pub get
```

#### For Android (Emulator or Device):

Make sure an Android emulator is running (or plug in an Android phone with USB debugging on).

```bash
flutter run
```

Or target a specific device:
```bash
flutter devices          # list available devices
flutter run -d emulator-5554
```

#### For Windows Desktop:

```bash
flutter run -d windows
```

#### For Chrome (Web — for quick testing):

```bash
flutter run -d chrome
```

---

### STEP 4: Connect Frontend to Backend

The frontend is pre-configured to connect to `http://127.0.0.1:8000`.

**For Android emulator**: Replace `127.0.0.1` with `10.0.2.2` in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

**For Android physical device**: Replace with your PC's local IP address (find it with `ipconfig` on Windows or `ip addr` on Linux):
```dart
static const String baseUrl = 'http://192.168.1.X:8000';
```

**For Windows Desktop / Chrome**: Keep as `http://127.0.0.1:8000`

---

### STEP 5: Use the App

Follow the 4-step workflow in order:

1. **Monolith Input** — Enter your system's modules and dependencies (or tap SAMPLE to auto-fill)
2. **Service Design** — Define target microservices and map modules to them
3. **Risk Analysis** — Tap RUN to analyze dependencies, risks, and coupling
4. **Migration Plan** — Tap GENERATE to get a Strangler Fig migration plan

Then tap **EXPORT** on the Plan screen to get a full Markdown report.

---

## RAILWAY DEPLOYMENT (Online Hosting)

### Step 1: Create a Railway Account

Go to https://railway.app and sign up (free tier available).

### Step 2: Install Railway CLI (optional but helpful)

```bash
npm install -g @railway/cli
railway login
```

### Step 3: Create a New Railway Project

Option A — Using the Railway Dashboard:
1. Go to https://railway.app/dashboard
2. Click **New Project** → **Deploy from GitHub Repo**
3. Select your GitHub repository
4. Choose the `backend/` folder as the root directory

Option B — Using CLI:
```bash
cd microshift/backend
railway init
railway up
```

### Step 4: Configure Railway

In Railway dashboard → your project → **Settings**:

- **Root Directory**: `backend`
- **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
- **Build Command**: `pip install -r requirements.txt`

Railway automatically sets the `$PORT` environment variable.

### Step 5: Get Your Public URL

After deployment, Railway gives you a URL like:
```
https://microshift-production-xxxx.up.railway.app
```

Test it: Visit `https://your-url.up.railway.app/health` → should return `{"status":"ok"}`

### Step 6: Update Flutter to Use Deployed URL

Edit `frontend/lib/services/api_service.dart`:

```dart
class ApiService {
  // Comment out local URL:
  // static const String baseUrl = 'http://127.0.0.1:8000';
  
  // Use your Railway URL:
  static const String baseUrl = 'https://microshift-production-xxxx.up.railway.app';
```

Then rebuild Flutter:
```bash
flutter run
# or for Android APK:
flutter build apk --release
```

## GITHUB SETUP

### Step 1: Initialize Git

```bash
cd microshift
git init
git add .
git commit -m "Initial commit: MicroShift migration planner"
```

### Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. Name it `microshift`
3. Keep it Public (for Railway free tier)
4. **Don't** initialize with README (we have one)

### Step 3: Push to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/microshift.git
git branch -M main
git push -u origin main
```

---

## COMMON ERRORS & FIXES

### Backend Issues

| Error | Fix |
|-------|-----|
| `ModuleNotFoundError: No module named 'fastapi'` | Run `pip install -r requirements.txt` inside `venv` |
| `Address already in use: port 8000` | Kill process: `lsof -ti:8000 \| xargs kill` (Mac/Linux) or `netstat -ano \| findstr :8000` then `taskkill /PID <PID> /F` (Windows) |
| `404 No monolith data found` | Save monolith data first (Step 1 in the app) |
| `JSONDecodeError` | The `data/` folder JSON got corrupted — delete the `.json` files in `backend/data/` |

### Flutter Issues

| Error | Fix |
|-------|-----|
| `SocketException: Connection refused` | Backend is not running. Start it with `uvicorn main:app --reload` |
| `XMLHttpRequest error` (web) | CORS issue — backend already has CORS `allow_origins=["*"]`. Check that backend is running. |
| `flutter: pub get failed` | Run `flutter clean` then `flutter pub get` |
| Android emulator can't reach backend | Change `127.0.0.1` to `10.0.2.2` in `api_service.dart` |
| `No devices found` | Start Android emulator or run `flutter doctor` to diagnose |
| Windows build fails | Run `flutter config --enable-windows-desktop` first |

### Railway Deployment Issues

| Error | Fix |
|-------|-----|
| Build fails with `No module named X` | Make sure `requirements.txt` is in the `backend/` folder |
| App crashes on startup | Check Railway logs. Ensure `$PORT` is used, not hardcoded port |
| `data/` files not persisting | Railway has ephemeral storage — data resets on redeploy. This is expected for this project. |

---

## 📊 API Endpoints Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| GET | `/health` | Health check JSON |
| POST | `/monolith/save` | Save monolith data |
| GET | `/monolith/load` | Load saved monolith |
| GET | `/monolith/sample` | Get sample monolith data |
| POST | `/services/save` | Save microservice definitions |
| GET | `/services/load` | Load saved services |
| GET | `/services/sample` | Get sample services |
| GET | `/analysis/run` | Run risk analysis |
| GET | `/analysis/load` | Load last analysis |
| GET | `/migration/generate` | Generate migration plan |
| GET | `/migration/load` | Load last plan |
| GET | `/export/markdown` | Export report as Markdown |
| GET | `/export/json` | Export full data as JSON |

Full interactive docs: `http://localhost:8000/docs`

## PROJECT CONCEPTS DEMONSTRATED

This project demonstrates:

1. **Strangler Fig Pattern** — Incremental migration with parallel running of monolith and microservices
2. **Dependency Analysis** — Graph-based risk scoring using in/out coupling and strength metrics
3. **Circular Dependency Detection** — DFS-based cycle detection algorithm
4. **Business Continuity Planning** — Downtime risk flagging and mitigation recommendations
5. **REST API Design** — FastAPI with Pydantic validation, structured JSON responses
6. **State Management** — Flutter Provider pattern with ChangeNotifier
7. **Cross-Platform UI** — Single Flutter codebase for Android + Windows + Web

## | Software Engineering 
