#!/usr/bin/env bash
set -euo pipefail

########################################
# Base setup
########################################
init_base_files() {
  echo "📁 Creating base files..."

  cat <<EOF > .gitignore
.gradle/
build/
.idea/
out/
*.iml
*.class
*.log
*.jar
.env
.DS_Store
EOF

  cat <<EOF > .editorconfig
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
EOF

  mkdir -p .vscode
  cat <<EOF > .vscode/settings.json
{
  "java.format.enabled": true,
  "editor.formatOnSave": true
}
EOF
}

########################################
# Root Gradle (Groovy DSL)
########################################
init_gradle_root() {
  echo "🔧 Creating root Gradle files..."

  cat <<EOF > settings.gradle
rootProject.name = '$1'
include 'commons:shared-lib'
EOF

  cat <<EOF > build.gradle
buildscript {
  ext {
    springBootVersion = '3.2.5'
  }
  repositories {
    mavenCentral()
  }
  dependencies {
    classpath "org.springframework.boot:spring-boot-gradle-plugin:\${springBootVersion}"
  }
}

subprojects {
  apply plugin: 'java'
  apply plugin: 'groovy'

  group = 'com.example'
  version = '0.1.0'

  repositories {
    mavenCentral()
  }

  test {
    useJUnitPlatform()
  }
}
EOF

  cat <<EOF > gradle.properties
org.gradle.jvmargs=-Xmx2G
EOF
}

########################################
# Commons module
########################################
init_commons_module() {
  mkdir -p commons/shared-lib/src/main/groovy
  mkdir -p commons/shared-lib/src/test/groovy

  cat <<EOF > commons/shared-lib/build.gradle
apply plugin: 'java-library'
apply plugin: 'groovy'

dependencies {
  implementation 'org.codehaus.groovy:groovy'
  testImplementation 'org.spockframework:spock-core:2.4-M1-groovy-4.0'
  testImplementation 'org.junit.jupiter:junit-jupiter:5.10.2'
  testImplementation 'org.mockito:mockito-core:5.12.0'
}
EOF
}

########################################
# Add service module
########################################
create_service_module() {
  local SERVICE_NAME="$1"
  local SERVICE_DIR="services/$SERVICE_NAME"
  local PACKAGE_PATH="com/example/${SERVICE_NAME}"

  mkdir -p "$SERVICE_DIR/src/main/groovy/$PACKAGE_PATH"
  mkdir -p "$SERVICE_DIR/src/test/groovy/$PACKAGE_PATH"

  echo "include 'services:$SERVICE_NAME'" >> settings.gradle

  cat <<EOF > "$SERVICE_DIR/build.gradle"
apply plugin: 'groovy'
apply plugin: 'org.springframework.boot'
apply plugin: 'io.spring.dependency-management'

dependencies {
  implementation 'org.springframework.boot:spring-boot-starter-web'
  implementation 'org.codehaus.groovy:groovy'
  implementation project(':commons:shared-lib')

  testImplementation 'org.spockframework:spock-core:2.4-M1-groovy-4.0'
  testImplementation 'org.junit.jupiter:junit-jupiter:5.10.2'
  testImplementation 'org.mockito:mockito-core:5.12.0'
}
EOF

  cat <<EOF > "$SERVICE_DIR/src/main/groovy/$PACKAGE_PATH/Application.groovy"
package com.example.${SERVICE_NAME}

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
class Application {
  static void main(String[] args) {
    SpringApplication.run(Application, args)
  }
}
EOF
}

########################################
# Root Makefile
########################################
init_makefile() {
  cat <<'EOF' > Makefile
.DEFAULT_GOAL := help

help: ## Show available commands
	@echo "\n🛠️  Available Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'

build-all: ## Build all modules
	./gradlew build

test-all: ## Run all tests
	./gradlew test

clean: ## Clean all builds
	./gradlew clean
EOF
}

########################################
# Bootstrap the monorepo
########################################
bootstrap_monorepo() {
  local NAME="$1"
  mkdir -p "$NAME"
  cd "$NAME"

  init_base_files
  init_gradle_root "$NAME"
  init_commons_module
  init_makefile

  echo "✅ Monorepo '$NAME' created!"
  echo "👉 To add services, run: ./add.service.sh <service-name>"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <monorepo-name>"
    exit 1
  fi
  bootstrap_monorepo "$1"
fi
