#!/bin/bash
#
# This script updates the machine using the puppet configuration specified
# in this directory.
#
# Copyright (C) 2013, Cephal Systems LLC, All rights reserved.
#
DIR=$(dirname "${BASH_SOURCE[0]}")

# Default paths to various tools.
APT=/usr/bin/apt-get
GEM=/usr/bin/gem
BUNDLE=/usr/bin/bundle
PUPPET=/usr/bin/puppet
LIBRARIAN=/usr/bin/librarian-puppet

# Change to this script's directory.
pushd ${DIR} > /dev/null

# Warn the user if not running as root. (This may be desired in some special
# cases, but most commands probably won't work)
if [[ $EUID -ne 0 ]]; then
   echo "WARNING: Script was not run as root, install commands may fail!" >&2
fi

# Install puppet if it is not already installed.
if [ ! -x ${PUPPET} ]; then
	echo "Puppet was not found at '${PUPPET}'."
	echo "Installing Puppet from apt..."

	${APT} install -y puppet-common

	echo "Puppet installation complete."
fi

# Install librarian-puppet if it is not already installed.
if [ ! -x ${LIBRARIAN} ]; then
	echo "Librarian-puppet was not found at '${LIBRARIAN}'."
	echo "Installing librarian-puppet from gem..."

    if [ ! -x ${BUNDLE} ]; then
		if [ ! -x ${GEM} ]; then
			# Install gem if it is not already installed.
			${APT} install -y rubygems
		fi
	
		# Install bundle if it is not already installed.
		${GEM} install bundler
	fi

	# Install librarian-puppet via the Gemfile.
	${BUNDLE} install

	echo "Librarian-puppet installation complete."
fi

# TODO: remove this
echo "DEBUG EXIT"
exit 0

# Initialize librarian-puppet if necessary.
if [ ! -d .librarian ]; then
	echo "Initializing librarian-puppet from Puppetfile..."

	${LIBRARIAN} install

	echo "Librarian-puppet initialized."
fi

# Apply the puppet manifest from this repository.
echo "Starting puppet update..."

${PUPPET} apply --hiera_config ./hiera.yaml \
                --modulepath ./modules \
                manifests/site.pp \
    || { echo "ERROR: Failure during puppet configuration." && exit 1; }

echo "Update complete."