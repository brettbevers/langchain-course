ARG DATABRICKS_VERSION="15.4-LTS"
FROM databricksruntime/standard:${DATABRICKS_VERSION}

ADD scripts/run-tests.sh /usr/src/run-tests.sh
RUN chmod +x /usr/src/run-tests.sh

ENV PYARROW_IGNORE_TIMEZONE=1 

# Trigger pytest.  Assumes that a bind mount maps the service under test to /usr/src/services.
WORKDIR /usr/src
ENTRYPOINT ["/usr/src/run-tests.sh"]
