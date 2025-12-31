#!/bin/sh

set -e

# Argument 1 is the path to the Python project.

if [ -z "$1" ]; then
    echo "ERROR: Module path not provided"
    exit 1    
fi

module_path=$1

if [ "$(expr substr "$module_path" 1 1)" != "/" ]; then
    module_path="/usr/src/$module_path"
fi

if [ ! -d "$module_path" ]; then
    echo "ERROR: Module path does not exist"
    exit 1
fi

# All further commands are run from the module path.
cd "$module_path"

# If there is a requirements.txt file, install the dependencies.
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies from requirements.txt"
    /databricks/python3/bin/pip3 install -r requirements.txt
fi

# If there is a requirements-dev.txt file, install the dependencies.
if [ -f "requirements-dev.txt" ]; then
    echo "Installing dependencies from requirements-dev.txt"
    /databricks/python3/bin/pip3 install -r requirements-dev.txt
fi

# Run the tests.
echo "Running pytest at: $module_path"
/databricks/python3/bin/python3 -m pytest