up:
	docker compose up

down:
	docker compose down

produce:
	rpk connect run ${PWD}/rpk/connect/benthos.json.kafka.local.yaml