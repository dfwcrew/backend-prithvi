## Prithvi Backend

Features:
- REST API for frontend to visualize natural disaster data

## Build

`docker build -t "prithvi-app:dev" .` 

## Run

`docker run --rm -p 8000:8000 prithvi-app:dev`

## Test

`ab -c 1 -n 100 http://127.0.0.1:8000/index`
