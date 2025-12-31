#!/bin/zsh

############################################
# Install Base Environment #
############################################

source /home/vscode/.zshrc \
    && pyenv install 3.12 --skip-existing \
    && pyenv virtualenv 3.12 langchain-course \
    && pyenv activate langchain-course \
    && pyenv local langchain-course


################################
# Install Service Environments #
################################

# # Service: data-ingestion
# source /home/vscode/.zshrc \
#     && cd /workspaces/st2-lakehouse/services/data_ingestion \
#     && pyenv install 3.10.2 --skip-existing \
# 	&& pyenv virtualenv 3.10.2 data-ingestion \
#     && pyenv local data-ingestion \
#     && pyenv activate data-ingestion  \
#     && pip install --upgrade pip \
#     && pip install -r requirements-dev.txt

# # Set-up Spark for use with Unity Catalog
# if [[ "${COMPOSE_PROFILES}" =~ "unity-catalog" ]]; then
#     export SPARK_HOME=$(find_spark_home.py) \
#         && mkdir -p $SPARK_HOME/conf/. \
#         && cp $HOME/spark-defaults.conf $SPARK_HOME/conf/. \
#         && sudo chown -R vscode $UNITY_DATA_PATH \
#         && sudo chgrp -R vscode $UNITY_DATA_PATH
# fi

# Activate the base environment before exiting.
pyenv activate langchain-course