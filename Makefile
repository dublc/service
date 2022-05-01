SHELL := /bin/bash

VERSION := 1.0

all: service

run:
	go run main.go

build:
	go build -ldflags "-X main.build=$(VERSION)"

service:
	docker build \
		-f deployment/docker/Dockerfile \
		-t service:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		.

# ==============================================================================
# Running within k8s/kind

KIND_CLUSTER := service-cluster

kind-up:
	kind create cluster --name $(KIND_CLUSTER) \
		--config deployment/kubernetes/kind/kind-config.yaml
	kubectl config set-context --current --namespace=service-system

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-load:
	kind load docker-image service:$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	kustomize build deployment/kubernetes/kind/service-pod | kubectl apply -f -

kind-restart:
	kubectl rollout restart deployment service-pod

kind-status:
	kubectl get node
	kubectl get service
	kubectl get pod --watch

kind-status-service:
	kubectl get pod --watch

kind-describe:
	kubectl describe pod -l app=service

kind-logs:
	kubectl logs -l app=service --all-containers=true -f --tail=100

kind-update-restart: service kind-load kind-restart

kind-update-apply: service kind-load kind-apply

# ==============================================================================
# Moudule support

tidy:
	go mod tidy
	go mod vendor