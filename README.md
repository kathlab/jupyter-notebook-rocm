# jupyter-notebook
Dockerized jupyter notebook with VS Code and ROCm support. Installs tensorflow and pytorch.

Tested on AMD RX 5700 XT GPU.

Build docker image
---

```
$ docker build -f Dockerfile -t local/jupyternotebookrocm:latest .
```

Create and run docker container
---

```
$ docker compose up -f docker-compose.yaml -d
```

Check pytorch environment
---

```
HSA_OVERRIDE_GFX_VERSION=10.3.0 python -m torch.utils.collect_env
```

Run VS Code inside docker container
---

1. Open VS Code workspace
2. (optional) Add ports forwarding of 8888 and 8889 in VS Code (for Juypter Notebook web app)
3. Dev Containers: Reopen in Container
4. Install VS Code extensions as needed