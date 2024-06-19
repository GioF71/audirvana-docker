#!/bin/bash

apt-get remove -y wget
apt-get autoremove -y

rm -rf /var/lib/apt/lists/*
