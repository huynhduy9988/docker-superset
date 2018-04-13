build:
	docker build -f Dockerfile -t kyligence/superset:latest .

run:
	docker run -d -p 8088:8088 --name superset kyligence/superset

init-db:
	docker exec -it superset superset-init

publish:
	docker push kyligence/superset:latest
