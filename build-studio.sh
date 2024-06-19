#!/bin/bash
docker build ./build/ --build-arg BINARY_TYPE=studio -t giof71/audirvana:studio --progress=plain
