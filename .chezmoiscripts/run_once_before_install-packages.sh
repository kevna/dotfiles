#!/bin/bash
sudo apt-get install --no-install-recommends $(grep -v '^#' apt_packages.list)
pip3 install --user $(grep -v '^#' pip_packages.list)
