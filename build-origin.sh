#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker build $SCRIPT_DIR/build/ --build-arg BINARY_TYPE=origin -t giof71/audirvana:origin --progress=plain "$@"
