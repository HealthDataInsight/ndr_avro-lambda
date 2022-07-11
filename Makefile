image:
	docker build -t lambda-avro-ruby2.7 .

shell:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-avro-ruby2.7

clean:
	rm -rf .bundle/
	rm -rf vendor/
	
docker-tagpush:
	docker tag lambda-avro-ruby2.7:latest 034508241938.dkr.ecr.eu-west-2.amazonaws.com/lambda-avro-ruby2.7:latest
	docker push 034508241938.dkr.ecr.eu-west-2.amazonaws.com/lambda-avro-ruby2.7:latest

docker-login:
	aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 034508241938.dkr.ecr.eu-west-2.amazonaws.com
