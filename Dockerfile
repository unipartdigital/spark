# Start with Python base as reliably installing the same Python version e.g not
# just 'python3' package) is more work than installing openjdk8 correctly
FROM python:3.7-alpine

ARG SPARK_HOME=/opt/spark
ARG SPARK_USER=spark
ARG SPARK_GROUP=spark
ARG UID=1001
ARG GID=1001

ENV SPARK_HOME=${SPARK_HOME}
ENV SPARK_LOG_DIR=${SPARK_HOME}/logs
ENV PATH="${SPARK_HOME}/bin:${SPARK_HOME}:sbin:$PATH"

RUN echo "==> Updating distro packages..."  \
    && apk update \
    && echo "==> Installing dependencies..." \
    && apk add --no-cache \
     openjdk8-jre \
     # Required by Spark scripts for additional flags/options
     bash procps coreutils

RUN echo "==> Setting up users and groups..." \
    && addgroup ${SPARK_GROUP} \
        --gid "$GID" \
    && adduser \
        --disabled-password \
        --home "$(pwd)" \
        --ingroup ${SPARK_GROUP} \
        # Enable
        --ingroup tty \
        --uid "$UID" \
        --no-create-home \
        ${SPARK_USER}

RUN echo "==> Setting up SPARK_HOME..." \
    && mkdir -p ${SPARK_HOME} \
    && chown -R ${SPARK_USER}:${SPARK_GROUP} ${SPARK_HOME} \
    && chmod -R 755 ${SPARK_HOME}

COPY docker-run.sh /
RUN chmod +x /docker-run.sh

COPY dist/* ${SPARK_HOME}/

WORKDIR ${SPARK_HOME}

# Non-root
USER ${SPARK_USER}

CMD ["/docker-run.sh"]