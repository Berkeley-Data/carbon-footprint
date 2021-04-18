#!/bin/sh
source venv/bin/activate
exec gunicorn --bind=:8080 --log-level=INFO --workers=2 test-app:app