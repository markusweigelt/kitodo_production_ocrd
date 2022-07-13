build: ./build-resources

./build-resources:
	docker-compose -f ./docker-compose.yml -f ./docker-compose-builder.yml up --build kitodo-builder
	docker-compose -f ./docker-compose.yml -f ./docker-compose-builder.yml down

up: ./build-resources
	docker-compose up -d --build

down:
	docker-compose down

stop:
	docker-compose stop

clean:
	rm -rf ./build-resources
