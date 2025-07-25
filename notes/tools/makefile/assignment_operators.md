
# Assignment Operators

| Operator   | Type               | Evaluation Time                | Use Case                                                               |
| ---------- | ------------------ | ------------------------------ | ---------------------------------------------------------------------- |
| `=`        | Recursive (Lazy)   | When variable is used          | Use when value might change or depend on other variables defined later |
| `:=`       | Simple (Immediate) | When variable is assigned      | Use when value must be fixed immediately                               |
| `?=`       | Conditional        | When variable is unset         | Use to set a default value unless overridden externally                |
| `+=`       | Append             | Depends on original assignment | Use to build up flags, file lists, etc.                                |
| `override` | Force assignment   | Ignores CLI overrides          | Use when Makefile should enforce a value                               |

## Examples

### `=` (Recursive / Lazy)

```makefile
FOO = $(BAR)
BAR = hello

print:
	echo $(FOO)  # Outputs: hello
```

> `FOO` is evaluated when used, so it sees the updated `BAR`.


### `:=` (Simple / Immediate)

```makefile
FOO := $(BAR)
BAR = hello

print:
	echo $(FOO)  # Outputs: (empty)
```

> `FOO` is fixed at assignment time — before `BAR` is set.


### `?=` (Conditional / Default)

```makefile
PYTHON_VERSION ?= 3.11

setup:
	python$(PYTHON_VERSION) -m venv .venv
```

> You can override this from CLI: `make PYTHON_VERSION=3.12`


### `+=` (Append)

```makefile
FLAGS := -Wall
FLAGS += -O2

build:
	gcc $(FLAGS) main.c
```

> Builds up a variable across multiple lines.


### `override` (Force value)

```makefile
override ENV = production
```

> Ignores `make ENV=dev`, always uses `production`.


## Summary

Each assignment style offers power and flexibility for different automation needs:

* Use `:=` when the value should not change.
* Use `=` when values are dynamic.
* Use `?=` to support user overrides.
* Use `+=` for flag lists or aggregation.
* Use `override` sparingly to enforce strict config.
