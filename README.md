# elastic-models-server

This repository contains the Dockerfile and Kubernetes manifests to build and deploy an Elastic model server using Python's built-in HTTP server. The server serves pre-trained model files over HTTP.

## Prerequisites

- Docker
- Kubernetes cluster (e.g., GKE, EKS, AKS)
- kubectl configured to interact with your Kubernetes cluster
- Docker Buildx (for building multi-platform images on MacBook with ARM architecture)

## Building the Docker Image

To build the Docker image, follow these steps:

1. Ensure you have the Dockerfile in your repository.

2. Use Docker Buildx to create a multi-platform image and push it to your container registry:

    ```sh
    docker buildx create --use
    docker buildx build --platform linux/amd64 -t sunmanreg.azurecr.io/elastic-model-server:latest --push .
    ```

## Deploying to Kubernetes

1. Create a Deployment manifest (`elastic-model-server.yaml`):

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: elastic-model-server
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: elastic-model-server
      template:
        metadata:
          labels:
            app: elastic-model-server
        spec:
          securityContext:
            fsGroup: 1000  # file system group
          containers:
          - name: elastic-model-server
            image: sunmanreg.azurecr.io/elastic-model-server:latest
            ports:
            - containerPort: 8000
            securityContext:
              runAsUser: 1000  # non-root user ID
              runAsGroup: 1000 # non-root group ID
    ```

2. Create a Service manifest (`elastic-model-service.yaml`):

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: elastic-model-service
      annotations:
        # Add any specific annotations if needed
      labels:
        app: elastic-model-server
    spec:
      externalTrafficPolicy: Local
      ports:
        - name: http
          port: 80
          protocol: TCP
          targetPort: 8000
      selector:
        app: elastic-model-server
      sessionAffinity: None
      type: LoadBalancer
    ```

3. Apply the manifests to your Kubernetes cluster:

    ```sh
    kubectl apply -f elastic-model-server.yaml
    kubectl apply -f elastic-model-service.yaml
    ```

## Accessing the Service

Once the service is up and running, get the external IP address assigned by the LoadBalancer:

```sh
kubectl get services
