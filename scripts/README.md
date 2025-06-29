## Helper shell scripts

This folder contains a collection of developer-friendly shell scripts to streamline workflows involving AWS LocalStack, JWT handling, Temporal, macOS Docker shortcuts, and project scaffolding.


## 📦 Structure Overview

```plaintext
scripts/
├── aws_localstack_utils.sh   # AWS SQS/SNS management via LocalStack
├── design.sh                 # Project or system design scaffolding helper
├── jwt_utils.sh              # Decode and inspect JWTs (JSON Web Tokens)
├── macos/
│   └── docker.sh             # Docker automation tools for macOS users
├── pyproject.sh              # Project scaffolding using Python + Poetry
└── temporal.sh               # Temporal.io CLI automation and workflow helpers
```

## 🛠️ Script Descriptions

| Script                    | Description                                                                                                                                                              |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `aws_localstack_utils.sh` | Manage SQS queues and SNS topics in LocalStack with helpers like `purge_sqs`, `receive_sqs_message`, `get_sqs_attributes`, and more. Highly configurable via parameters. |
| `design.sh`               | Initializes project design documentation or structure. Can be adapted for architecture diagrams, decision records, or templates.                                         |
| `jwt_utils.sh`            | Decode JWT tokens into readable header and payload using `jq`. Also extracts expiry times in human-readable format.                                                      |
| `macos/docker.sh`         | macOS-specific Docker helpers — starts containers, handles cleanup, etc.                                                                                                 |
| `pyproject.sh`            | Scaffolds a Python project using `pyproject.toml`, sets up Poetry environments, and standard folder structures.                                                          |
| `temporal.sh`             | Provides CLI wrappers or helpers for interacting with Temporal workflows, namespace registration, and worker tasks.                                                      |


## ✅ Prerequisites

* `bash` or `zsh`
* [`aws-cli`](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [`jq`](https://stedolan.github.io/jq/)
* [`poetry`](https://python-poetry.org/) (for `pyproject.sh`)
* [`docker`](https://docs.docker.com/) (for relevant scripts)
* [`temporal-cli`](https://docs.temporal.io/) (for `temporal.sh`)


## 🚀 Usage

To integrate to your shell provide include this in either `.bashrc` or `zshrc`. Note this script were only tested in `MacOS` zsh

**or**

```bash
source scripts/aws_localstack_utils.sh
```

Once this is available in your shell , you can use the helper scripts as

```bash

jwt.token.expiry "your.jwt.token.here"


purge_sqs "http://localhost:4566/000000000000/my-queue"
```


