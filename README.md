# 🛠️ Tinkerpad - Collection of personal dotfile/notes/scripts

A collection of useful scripts and snippets for development workflows across Python, macOS, Gradle, and Temporal. This repository is designed to streamline your local environment setup, automate repetitive tasks, and organize common design patterns.

## 📁 Project Structure

```

utilities/
├── gist/
│   └── build-static-analysis.gradle     # Gradle snippet for static code analysis
├── scripts/
│   ├── design.sh                        # System design diagram generator (text-to-diagram)
│   ├── macos/                           # macOS-specific automation or config scripts
│   ├── pyproject.sh                     # Bootstrap script for Python Poetry projects
│   └── temporal.sh                      # Helper for managing Temporal project scaffolding
├── .gitignore
└── README.md

````

## 📦 Components Overview

### `gist/build-static-analysis.gradle`
> A reusable Gradle build script fragment for static code analysis tooling (e.g., Checkstyle, PMD, SpotBugs).  
🔧 **Usage:** Import it into your `build.gradle` files for unified code linting across modules.


### `scripts/design.sh`
> Shell script to convert system design descriptions into visual diagrams (likely using `draw.io`, `mermaid`, or similar engines).  
🧠 Ideal for: Converting plaintext system architecture into shareable visuals.


### `scripts/macos/`
> Reserved for macOS-specific scripts such as default setup, environment tweaks, and automation helpers.  
🍏 Useful for: Onboarding new Macs or setting up dev environments consistently.


### `scripts/pyproject.sh`

> Automates the creation of a new Python project using Poetry.  
🐍 Features:
- Creates folder structure
- Initializes `pyproject.toml`
- Sets up virtualenv and installs dependencies  
✅ Run this to rapidly scaffold new Poetry projects.

### `scripts/temporal.sh`
> Script to bootstrap or manage a Temporal.io microservice.  

- Generate service scaffolding
- Manage workflow workers
- Connect with Temporal server locally


## 🧪 Local Development

This repository is intended to be cloned and used on-demand:

```bash
git clone https://github.com/itspkannan/tinkerpad.git
cd utilities
chmod +x scripts/*.sh
````

Then run the script of your choice:

```bash
./scripts/pyproject.sh my-new-project
./scripts/temporal.sh init
```

