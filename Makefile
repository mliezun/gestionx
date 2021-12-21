build:
	docker-compose up -d

clean:
	docker container rm $(docker container ls --all | grep "mliezun/generic-build-and-deploy:latest" | awk '{print $1}')
	docker volume rm gestionx_datavolume
