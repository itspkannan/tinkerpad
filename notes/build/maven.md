# Maven 

## 🔄 1. **Default Lifecycle** (Build & Deployment)

This is the main lifecycle that handles your project from compilation to deployment.

### Key Phases (in order):

| Phase                     | Description                                                              |
| ------------------------- | ------------------------------------------------------------------------ |
| `validate`                | Validates the project is correct and all information is available.       |
| `initialize`              | Initializes the build state, e.g., set properties or create directories. |
| `generate-sources`        | Generates source code (from WSDL, XSD, etc.).                            |
| `process-sources`         | Processes the source code, e.g., filtering.                              |
| `generate-resources`      | Generates resources like property files.                                 |
| `process-resources`       | Copies and processes resources to `target/classes`.                      |
| `compile`                 | Compiles the source code of the project.                                 |
| `process-classes`         | Post-processing of compiled class files.                                 |
| `generate-test-sources`   | Generates test source code.                                              |
| `process-test-sources`    | Processes test source code.                                              |
| `generate-test-resources` | Generates test resources.                                                |
| `process-test-resources`  | Copies and processes test resources.                                     |
| `test-compile`            | Compiles the test source code.                                           |
| `test`                    | Runs tests using a testing framework (e.g., JUnit).                      |
| `prepare-package`         | Prepares for packaging (e.g., code instrumentation).                     |
| `package`                 | Packages the compiled code into a JAR, WAR, etc.                         |
| `pre-integration-test`    | Setup before running integration tests.                                  |
| `integration-test`        | Runs integration tests.                                                  |
| `post-integration-test`   | Cleanup after integration tests.                                         |
| `verify`                  | Runs checks on results of integration tests.                             |
| `install`                 | Installs the package into the local repository.                          |
| `deploy`                  | Deploys the final artifact to a remote repository.                       |

---

## 🧪 2. **Clean Lifecycle** (Cleanup)

Used to clean up the project directory before or after builds.

### Phases:

| Phase        | Description                       |
| ------------ | --------------------------------- |
| `pre-clean`  | Executed before the actual clean. |
| `clean`      | Deletes the `target/` directory.  |
| `post-clean` | Executed after the clean.         |

---

## 📦 3. **Site Lifecycle** (Documentation & Reporting)

Used to generate documentation for the project.

### Phases:

| Phase         | Description                                 |
| ------------- | ------------------------------------------- |
| `pre-site`    | Executes before site generation.            |
| `site`        | Generates the project’s documentation.      |
| `post-site`   | Executes after site generation.             |
| `site-deploy` | Deploys the generated site to a web server. |

---

## 💡 Common Maven Commands Using These Phases

```bash
mvn clean install           # clean → default up to install
mvn verify                  # run unit + integration tests
mvn site-deploy            # build and publish documentation
```


