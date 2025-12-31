# st2-lakehouse
Monorepo containing projects related to the [Strategic Tech Team (ST2)](https://faspd.atlassian.net/wiki/spaces/st2/overview) lakehouse.

## Quickstart
### Local Development
1. Checkout the repo locally 
(first [generate an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) if needed):
    ```bash
    git clone git@github.com:StrategicProductDevelopment/st2-lakehouse.git
    ```

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) via JAMF->Self Service->Developer->Docker Desktop (on a Mac) or download from [here](https://www.docker.com/get-started/).  Once installed, start the Docker Desktop process in the background.

1. Confirm success by running the [unit test suite](#testing) on an example service.

## <a name="testing"></a>Testing
### Databricks services
Run Databricks unit tests for a specific service locally:
```bash
docker compose -f docker/pytest-runner/compose.yaml build
docker compose -f docker/pytest-runner/compose.yaml run test services/example_service
```

To limit execution to a single test module:
```bash
docker compose -f  docker/pytest-runner/compose.yaml run test services/example_service/test/test_example.py
```

To limit execution to a single test method:
```bash
docker compose -f  docker/pytest-runner/compose.yaml run test services/example_service/test/test_example.py::test_add_row_hash
```
