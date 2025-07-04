#  Gradle 

## 🌀 Build Phases

Gradle organizes builds into **three internal phases**:

1. **Initialization Phase**
   → Sets up the project and included builds.

2. **Configuration Phase**
   → Configures the task graph (evaluates all `build.gradle.kts` or `build.gradle` files).

3. **Execution Phase**
   → Executes tasks (and their dependencies) as requested.


## ✅ Core Gradle Tasks (Java/General)

| Task               | Description                                      |
| ------------------ | ------------------------------------------------ |
| `clean`            | Deletes the build directory (`build/`).          |
| `compileJava`      | Compiles Java source files.                      |
| `processResources` | Copies resources into `build/`.                  |
| `test`             | Runs unit tests.                                 |
| `jar`              | Packages compiled code into a `.jar`.            |
| `build`            | Compiles, tests, and packages the project.       |
| `run`              | Runs the main application class (if configured). |


## 🌱 Spring Boot Tasks

> Apply plugin: `org.springframework.boot`

```kotlin
plugins {
    id("org.springframework.boot") version "3.2.0"
}
```

| Task             | Description                                 |
| ---------------- | ------------------------------------------- |
| `bootRun`        | Starts Spring Boot app (hot reload).        |
| `bootJar`        | Creates a self-contained executable `.jar`. |
| `bootBuildImage` | Builds an OCI image using Buildpacks.       |


## ⚡ Quarkus Tasks

> Apply plugin: `io.quarkus`

```kotlin
plugins {
    id("io.quarkus") version "3.10.0"
}
```

| Task                 | Description                                  |
| -------------------- | -------------------------------------------- |
| `quarkusDev`         | Dev mode with live reload.                   |
| `quarkusBuild`       | Builds a JVM-mode app.                       |
| `quarkusBuildNative` | Builds a native image using GraalVM/Mandrel. |


## 🐳 Docker Image Build (without Docker daemon)

> Apply plugin: `com.google.cloud.tools.jib`

```kotlin
plugins {
    id("com.google.cloud.tools.jib") version "3.4.0"
}
```

### Example Configuration

```kotlin
jib {
    from {
        image = "eclipse-temurin:21-jdk"
    }
    to {
        image = "gcr.io/my-project/my-app"
        tags = setOf("latest", "v1.0.0")
    }
    container {
        jvmFlags = listOf("-Dspring.profiles.active=prod")
        ports = listOf("8080")
    }
}
```

### Common Tasks:

| Task             | Description                                          |
| ---------------- | ---------------------------------------------------- |
| `jib`            | Builds and pushes image (if `to.image` is set).      |
| `jibDockerBuild` | Builds image to local Docker daemon (if needed).     |
| `jibBuildTar`    | Builds a `.tar` image that can be loaded via Docker. |

---

## ☸️ Kubernetes Deployment via Helm

> Apply plugin: `io.kokuwa.gradle.helm`

```groovy
plugins {
    id("io.kokuwa.gradle.helm") version "6.7.1"
}
```

### Example Configuration

```groovy
helm {
    chartsDir.set(file("helm/"))
    kubeconfig.set(file("$System.env.HOME/.kube/config"))
}

helm.commands {
    register("deploy") {
        dependsOn("helmInstall")
    }
}

tasks.register("helmInstall", io.kokuwa.gradle.helm.task.HelmInstall::class) {
    releaseName.set("myapp")
    chart.set(file("helm/myapp"))
    namespace.set("default")
    values.put("image.tag", "v1.0.0")
}
```

### Common Tasks:

| Task          | Description                      |
| ------------- | -------------------------------- |
| `helmInstall` | Installs a chart to Kubernetes.  |
| `helmUpgrade` | Upgrades an existing release.    |
| `helmLint`    | Lints Helm chart.                |
| `helmPackage` | Packages Helm chart.             |
| `helmDelete`  | Deletes release from Kubernetes. |


## 🔍 Static Analysis and Testing

| Tool          | Plugin                        | Tasks                              |
| ------------- | ----------------------------- | ---------------------------------- |
| Checkstyle    | `checkstyle`                  | `checkstyleMain`, `checkstyleTest` |
| SpotBugs      | `com.github.spotbugs`         | `spotbugsMain`, `spotbugsTest`     |
| JaCoCo        | `jacoco`                      | `jacocoTestReport`                 |
| Spock / JUnit | via `testImplementation` deps | `test`                             |

```groovy

plugins {
    id 'java'
    id 'jacoco'                              
    id 'checkstyle'                          
    id 'com.github.spotbugs' version '5.2.5'
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
    testImplementation 'org.codehaus.groovy:groovy-all:3.0.20'
    testImplementation('org.spockframework:spock-core:2.3-groovy-3.0') {
        exclude group: 'org.codehaus.groovy', module: 'groovy'
    }
}

test {
    useJUnitPlatform()
    testLogging {
        events 'PASSED', 'FAILED', 'SKIPPED'
    }
}

jacoco {
    toolVersion = '0.8.10'
}

jacocoTestReport {
    dependsOn test
    reports {
        xml.required = true
        html.required = true
    }
}

checkstyle {
    toolVersion = '10.12.3'
    configDirectory = file("$rootDir/config/checkstyle") // Optional: use your own rules
}

spotbugs {
    toolVersion = '4.8.3'
    effort = 'max'
    reportLevel = 'low'
}

tasks.withType(com.github.spotbugs.snom.SpotBugsTask).configureEach {
    reports {
        html.required = true
        html.outputLocation = file("$buildDir/reports/spotbugs/spotbugs.html")
    }
}

```

## 💻 Full Dev Workflow Examples

```bash
# Clean and build
./gradlew clean build

# Run dev server (Spring or Quarkus)
./gradlew bootRun           # for Spring Boot
./gradlew quarkusDev        # for Quarkus

# Run tests and code checks
./gradlew test checkstyleMain jacocoTestReport

# Build Kubernetes-ready image (no Docker daemon)
./gradlew jib

# Deploy via Helm
./gradlew helmInstall
```


## 📁 Suggested Project Layout

### Single Service layout 

```bash
my-app/
├── build.gradle
├── settings.gradle
├── src/
│   ├── main/java/
│   └── test/java/
├── helm/
│   └── myapp/
│       ├── templates/
│       └── values.yaml
└── Dockerfile (optional, if not using Jib)
```

### Monorepo Layout 

```bash
my-platform/
├── build.gradle              # Root build file (version catalogs, common config)
├── settings.gradle           # Includes all modules
├── gradle/                       # Gradle wrapper files
│   └── wrapper/
├── helm/                         # Shared Helm charts
│   ├── myapp/
│   │   ├── templates/
│   │   └── values.yaml
│   └── commons/
├── commons/                      # Shared code libraries
│   └── build.gradle
│   └── src/main/java/...
├── services/
│   ├── service-spring/           # A Spring Boot service
│   │   ├── build.gradle
│   │   └── src/main/java/...
│   ├── service-quarkus/          # A Quarkus service
│   │   ├── build.gradle
│   │   └── src/main/java/...
│   └── service-shared-lib/       # Optional shared domain models, DTOs
│       └── build.gradle
│       └── src/main/java/...
├── deployment/                   # Kubernetes manifests, Makefiles, secrets
│   ├── k8s/
│   └── Makefile
└── .editorconfig                 # Optional: unified code style
```

**settings.gradle**

```bash
rootProject.name = "my-platform"

include(
    "commons",
    "services:service-spring",
    "services:service-quarkus",
    "services:service-shared-lib"
)

```

** Build Command **

```bash
# Build all modules
./gradlew clean build

# Run specific service
./gradlew :services:service-spring:bootRun
./gradlew :services:service-quarkus:quarkusDev

# Build Jib image
./gradlew :services:service-spring:jib

# Deploy using Helm
./gradlew helmInstall
```