ARG IMAGE_PYTHON_VERSION=3.12-slim-bookworm \
    PIP_VERSION=25.1 \
    SETUPTOOLS_VERSION=80.0.0 \
    POETRY_VERSION=2.1.1

FROM python:${IMAGE_PYTHON_VERSION} AS python-base
ARG PIP_VERSION
ARG SETUPTOOLS_VERSION
ARG POETRY_VERSION
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV POETRY_VERSION=${POETRY_VERSION} PIP_VERSION=${PIP_VERSION} SETUPTOOLS_VERSION=${SETUPTOOLS_VERSION}

RUN  apt-get update -q && \
    apt-get install -y --no-install-recommends -y locales && \
    apt-get remove -y ncurses-base --allow-remove-essential && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log} && \
    pip3 --disable-pip-version-check install --no-cache-dir --upgrade  "pip==${PIP_VERSION}" "setuptools==${SETUPTOOLS_VERSION}"

FROM python-base AS app-builder
ENV POETRY_VERSION=${POETRY_VERSION} PIP_VERSION=${PIP_VERSION} SETUPTOOLS_VERSION=${SETUPTOOLS_VERSION}

WORKDIR /app
COPY pyproject.toml poetry.lock ./
ENV PYTHONPATH=/app


RUN pip3 --disable-pip-version-check install --no-cache-dir --upgrade "pip==${PIP_VERSION}" "setuptools==${SETUPTOOLS_VERSION}" && \
    pip3 --disable-pip-version-check install --no-cache-dir "poetry==${POETRY_VERSION}"  && \
    poetry config virtualenvs.in-project true && \
    poetry config installer.max-workers 10 && \
    poetry install --no-root --only main --no-interaction --no-ansi

FROM python-base AS production
WORKDIR /app
COPY --from=app-builder /app/.venv /app/.venv/

# COPY <add python source copy>
# COPY <any configuration file copy>
# if not copying in your configmap and deployment,yaml mnount folder for your app to load

RUN groupadd -r microservice --gid=10000 && \
    useradd --no-create-home -s /bin/false -r -g microservice --uid=999 microservice && \
    id -u microservice | xargs -I{} chown -R {}:{} /app

USER microservice

ENV LANG=en_US.utf8 \
    PATH=/app/.venv/bin:/app:${PYTHONPATH}:${PATH}

EXPOSE 8000 8081
ENTRYPOINT ["python" , "-u", "main.py"]