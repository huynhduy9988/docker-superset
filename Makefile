SUPERSET_VERSION=0.23
REGION=cn

build:
	@docker build -f Dockerfile -t incubator-superset:$(SUPERSET_VERSION) --build-arg REGION=$(REGION) --build-arg SUPERSET_VERSION=$(SUPERSET_VERSION) .

run:
	@docker run -d -p 8088:8088 --name superset incubator-superset:$(SUPERSET_VERSION) runserver -p 8088 -a 0.0.0.0

clean:
	@docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi >/dev/null 2>&1
