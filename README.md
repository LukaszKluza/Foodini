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
dart run build_runner build
```

## 🚀 AWS Deployment Guide

### 🧩 Frontend (Flutter Web)

#### 1️⃣ Build frontend locally:

1. Go to frontend directory `cd Foodini/frontend`
2. Run `flutter build web --dart-define-from-file=config/prd-web.json`

#### 2️⃣ Migrate built frontend to EC2 instance:

1. Please contact with admins to generate SSh keys.
2. Download the keys
3. Connect to EC2 via git bash console

``` 
cd <DIRECTORY_WITH_PEM_FILE>
ssh -i "Foodini key 1.pem" ubuntu@ec2-13-48-229-7.eu-north-1.compute.amazonaws.com
```
4. If required
```shell
chmod 400 "Foodini key 1.pem"
```

5. From local machine (not EC2 instance) run to migrate build files to EC2 instance:

```shell
scp -r -i <ABSOLTE_PATH_OF_GENREATES_SSH_KEYS> frontend/build/web ubuntu@13.48.229.7:~/Foodini/frontend/.build
```

5. On EC2 instance run to reload caddy server:

```shell
sudo systemctl reload caddy
```

### ⚙️Backend

1. Login to EC2 console
2. Commit changes (if you want to edit .env file, migrate in the sam way as FE)
3. git pull
4. Restart backend service

```shell
sudo systemctl restart foodini-backend
```

5. Restart caddy server

```
sudo systemctl reload caddy
```