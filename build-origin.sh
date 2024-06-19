#!/bin/bash
docker build ./build/ --build-arg BINARY_TYPE=origin -t giof71/audirvana:origin --progress=plain
