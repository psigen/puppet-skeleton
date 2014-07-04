#!/bin/bash
#
# This script updates the machine using the puppet configuration specified
# in this directory.
#
# Copyright (C) 2013, Cephal Systems LLC, All rights reserved.
#
DIR=$(dirname "${BASH_SOURCE[0]}")

echo "Starting puppet update..."
pushd ${DIR} > /dev/null

sudo puppet apply --hiera_config ./hiera.yaml \
                  --modulepath ./modules \
                  manifests/site.pp \
    || { echo "ERROR: Failure during puppet configuration." && exit 1; }

popd > /dev/null
echo "Update complete."