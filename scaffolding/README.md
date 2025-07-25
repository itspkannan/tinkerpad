# Project scaffolding

Scripts and folders are for bootstrapping my personal projects. The project structure and build process followed to be development process that I followed in my previous work experience and aggregation of many ideas obtained from various github projects or articles that I have read.


## 🧪 Python Monorepo Generator - Poetry-based 

This toolkit helps you **bootstrap a modular Python monorepo** using [Poetry](https://python-poetry.org/), with support for `tox`, `pytest`, `mypy`, and `ruff`.

### 📦 Folder Structure

```bash

poetry-monorepo-starter/
├── commons/
├── domains/
├── services/
├── proto/
├── scripts/
│   ├── mono_repo_python.sh
│   ├── mono_repo_helper.sh.inc
│   ├── mono_bootstrap_python.sh.inc
│   └── generators/
│       ├── add_common.sh.inc
│       ├── add_service.sh.inc 
│       ├── add_domain.sh.inc  
│       └── add_api.sh.inc    
├── Makefile

````

### 🚀 Getting Started

#### 1. Clone and Source
```bash
cd monorepo_split/scripts
source mono_repo_python.sh
````

#### 2. Bootstrap Your Monorepo

```bash
monorepo.poetry_package.bootstrap -p poetry-monorepo-starter
```

This creates the base folders:

* `commons/`, `domains/`, `services/`, `proto/`, `scripts/`
* Adds top-level `Makefile` to build/test/lint all modules

#### 3. Add Common Modules

```bash
cd my-monorepo
./scripts/add_common.sh -n persistence
./scripts/add_common.sh -n analytics
```


### 🧪 Module Features

Each module created by `add_common.sh` includes:

* `pyproject.toml` with Poetry setup
* Dev dependencies: `pytest`, `ruff`, `mypy`, `tox`
* `.venv` local virtual environment
* `Makefile` with common targets:

  * `make test`, `make lint`, `make type-check`
* `tox.ini` for multi-environment testing
* `README.md` with module description

### 🧰 Optional Extensions

Add more scripts to `scripts/generators/`:

* `add_service.sh.inc`: scaffold services
* `add_domain.sh.inc`: create domain models
* `add_api.sh.inc`: build Sanic or FastAPI APIs


### 🛠 Global Build

To run tests on all modules:

```bash
make
```
