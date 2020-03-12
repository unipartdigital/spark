# Start with Python base as reliably installing the same Python version e.g not
# just 'python3' package) is more work than installing openjdk8 correctly
FROM python:3.7-alpine

# Path to Spark dist package to copy into container
# built with ./dev/make-distribution.sh --tgz <other args>
ARG SPARK_PACKAGE
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

COPY run.sh /
RUN chmod +x /run.sh

COPY ${SPARK_PACKAGE} /tmp

WORKDIR ${SPARK_HOME}

RUN echo "==> Unpacking Spark package ${SPARK_PACKAGE} to ${SPARK_HOME}" \
    && tar -xvzf /tmp/${SPARK_PACKAGE} --strip-components=1

# Non-root
USER ${SPARK_USER}

CMD ["/run.sh"]