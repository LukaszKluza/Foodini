# Foodini

#### 1. Running migration
``` bash
cd Foodini
python -m backend.core.migrate
```

#### 2. Running the backend
``` bash
cd Foodini
uvicorn backend.main:app --reload --log-config backend/logging_config.yaml --port 8000
```

#### 3. Running the frontend
``` bash
cd Foodini/frontend
python ./run.py
```

#### Generating translation
``` bash
cd Foodini/frontend
flutter gen-l10n                  
```

#### Generating frontend mocks
``` bash
cd Foodini/frontend
flutter pub run build_runner build
```
