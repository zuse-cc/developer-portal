# Zuse Systems IDP

This repository represents Zuse Systems' internal developer portal based on [Backstage](https://backstage.io). This is an example application and not intended for production deployments.

## Preconditions

- For the `github` integration get a suitable GitHub personal access token
- See https://backstage.io/docs/integrations/github/locations#configuration

## Running Locally

```sh
yarn install
yarn dev
```

## Local Docker Deployment

Build the application and start it along with a local Postgres instance using Docker Compose:

```sh
make build
docker compose up --build
```

The portal will be available at http://localhost:7007.

## Kubernetes Deployment (Helm)

The Helm chart is in [./charts/developer-portal](./charts/developer-portal/).

### Dev mode (in-cluster Postgres)

**1. Create the namespace:**

```sh
kubectl create namespace backstage
```

**2. Create the image pull secret:**

The image is hosted on GHCR in a private repository. Create a Personal Access Token with `read:packages` scope, then:

```sh
kubectl create secret docker-registry ghcr-login-secret \
  --namespace backstage \
  --docker-server=ghcr.io \
  --docker-username=<your-github-username> \
  --docker-password=<your-github-token>
```

**3. Create the app secrets:**

```sh
# Postgres credentials (dummy values for dev)
kubectl create secret generic postgres-secrets \
  --namespace backstage \
  --from-literal=POSTGRES_USER=backstage \
  --from-literal=POSTGRES_PASSWORD=backstage

# App secrets - replace with a real GitHub token for catalog access
kubectl create secret generic backstage-secrets \
  --namespace backstage \
  --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN}
```

**4. Install the chart:**

```sh
IMAGE_TAG=local
helm upgrade --install backstage charts/developer-portal \
  --set image.tag=latest \
  --namespace backstage
```

This deploys an in-cluster Postgres instance alongside the portal (`postgres.enabled` defaults to `true`).

### Production mode (external Postgres)

```sh
helm install backstage charts/developer-portal \
  --namespace backstage \
  --set image.tag=<image-tag> \
  --set postgres.enabled=false \
  --set postgres.host=<your-db-host>
```

### Additional Options

```sh
helm upgrade --install backstage charts/developer-portal \
  --namespace backstage \
  --set image.tag=latest \
  --set ingress.enabled=true \
  --set ingress.host=backstage.example.local \
  --set ingress.tls.enabled=true
```
