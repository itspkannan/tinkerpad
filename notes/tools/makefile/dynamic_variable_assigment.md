
# Dynamic Variable Assignment Patterns


## 1. `$(eval ...)` with `$(shell ...)` (Multi-line Target — Runtime Safe)

This is the **recommended** way to assign a shell-evaluated value at runtime and reuse it within the same rule.

```makefile
set-python:
	$(eval PYTHON_VERSION=$(shell asdf list python | grep '3.12' | tr -d '*[:space:]' | sort -V | tail -1 | xargs))
	@echo "Using Python version: $(PYTHON_VERSION)"
	asdf install python $(PYTHON_VERSION)
```

**Pro**: Reusable later in the same target
**Con**: Must use inside a target — not usable globally at file load time.

## 2. Single-line Shell Variable (Scoped)

Another common shell idiom is to **do everything in one `@(...)` block**, passing variables via shell scope:

```makefile
set-python:
	@PYTHON_VERSION=$$(asdf list python | grep '3.12' | tr -d '*[:space:]' | sort -V | tail -1 | xargs); \
	echo "Using Python version: $$PYTHON_VERSION"; \
	asdf install python $$PYTHON_VERSION
```

**Pro**: Clean and shell-like
**Con**: You cannot reuse `PYTHON_VERSION` outside this `@` block


##  3. Inline `:=` if You Don’t Need Late Evaluation

Use `:=` only if the shell command will return correct value **at parse time** (e.g., `which python`):

```makefile
PYTHON_PATH := $(shell which python3)

show:
	@echo $(PYTHON_PATH)
```

**Pro**: Good for static paths or pre-known output
**Con**: Not safe for values that may change dynamically (e.g., `asdf list`)


## 4. Using a Function or Macro

If you want to **reuse logic**, wrap it in a custom Make macro:

```makefile
get-latest-python = $(shell asdf list python | grep '3.12' | tr -d '*[:space:]' | sort -V | tail -1 | xargs)

set-python:
	$(eval PYTHON_VERSION=$(call get-latest-python))
	@echo "Version: $(PYTHON_VERSION)"
```

**Pro**: DRY and clean
**Con**: Still must be `eval`-ed within the target


## Summary

| Pattern                      | Scope             | Reusable? | Best For                          |
| ---------------------------- | ----------------- | --------- | --------------------------------- |
| `$(eval VAR = $(shell ...))` | Target runtime    | Yes     | Dynamic setup reused in same rule |
| `@VAR=...; do something`     | Shell-only        | No      | Quick logic in one step           |
| `VAR := $(shell ...)`        | Global parse-time | Yes     | Static shell values               |
| `$(call my-func)` + `eval`   | Target runtime    | Yes     | Reusable macro logic              |

