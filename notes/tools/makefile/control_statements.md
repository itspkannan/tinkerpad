# Makefile Control Structures

Make supports **two types** of control structures:

*  **Native Makefile Control Structures** — evaluated **at parse time**
*  **Shell Control Structures** — executed **at runtime** inside targets


##  Native Makefile Control Structures

- These are used **outside target recipes** to control variable assignment, rule inclusion, and file generation.
- Parse-Time Logic

### 1. `ifeq` / `ifneq`

```makefile
PYTHON_VERSION := 3.11

ifeq ($(PYTHON_VERSION),3.11)
  VENV_DIR := .venv-311
else
  VENV_DIR := .venv
endif
```

###2. `ifdef` / `ifndef`

```makefile
ifdef DEBUG
  CFLAGS := -g -DDEBUG
else
  CFLAGS := -O2
endif
```

### 3. `foreach` (loop over a list)

```makefile
PROJECTS := service1 service2 service3

all:
	@$(foreach proj,$(PROJECTS),echo "Building $(proj)";)
```

## 4. `filter` (used with `foreach` for conditional loop content)

```makefile
PROJECTS := service1 legacy service2

build:
	@$(foreach proj,$(PROJECTS), \
		$(if $(filter legacy,$(proj)), \
			echo "Skipping legacy $(proj)";, \
			echo "Building $(proj)";))
```


## Shell Control Structures 

- Shell logic is written **inside recipe blocks** 
- Evaluated at execution time (just like a shell script)

### 1. Shell `if-else` inside a rule

```makefile
check:
	@VERSION=3.12; \
	if [ "$$VERSION" = "3.12" ]; then \
		echo "Matched version"; \
	else \
		echo "Other version"; \
	fi
```

### 2. Shell `for` loop

```makefile
loop:
	@for dir in service1 service2; do \
		echo "Processing $$dir"; \
		cd $$dir && make build; \
	done
```

### 3. Shell `while` loop

```makefile
count:
	@count=0; \
	while [ $$count -lt 3 ]; do \
		echo "Count is $$count"; \
		count=$$((count + 1)); \
	done
```


## 📊 Comparison Summary

| Feature              | Native Makefile (`ifeq`, `foreach`) | Shell Control (`if`, `for`, `while`) |
| -------------------- | ----------------------------------- | ------------------------------------ |
| Evaluation Time      | Parse-time                          | Runtime (during target execution)    |
| Scope                | Global (affects targets/vars)       | Per target (inside recipe only)      |
| Loop Support         | `foreach` only                      | `for`, `while`, `until` via shell    |
| Conditional Branch   | `ifeq`, `ifdef`                     | `if [ ... ]; then ... fi`            |
| Reuse Inside Targets |  Not allowed                       |  Yes                                |


## Best Practices

* Use **Makefile-native logic** (`ifeq`, `foreach`) for variable control and target inclusion.
* Use **shell logic** for loops and conditions that depend on runtime system state.
* Never mix the two in the same context — use `@` and `$$` carefully inside shell logic.

