# Foodini

#### 1. Running migration
``` bash
cd Foodini
python -m backend.core.migrate
```


#### 2. Running the backend
``` bash
cd Foodini
uvicorn backend.main:app --reload
```

#### 1. Running the frontend
``` bash
cd Foodini/frontend
python ./run.py
```