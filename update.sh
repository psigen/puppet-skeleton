#!/bin/bash
#
# This script bootstraps a ruby installation and updates the machine using the
# puppet configuration specified in this directory structure.
#
# Copyright (C) 2014, Cephal Systems LLC, All rights reserved.
#

# Detect and change to this script's directory.
DIR=$(dirname "${BASH_SOURCE[0]}")
pushd ${DIR} > /dev/null

# Download and install RVM and ruby latest-stable locally.
# TODO: Is this overkill?  Naaaaaah!
if [[ ! -x ./.rvm/bin/rvm ]]
then
	export rvm_path="$(pwd)/.rvm"
	curl -sSL https://get.rvm.io \
		| bash -s stable --ruby \
		|| { echo "ERROR: Failed to install RVM/Ruby locally." && exit 1; }
fi

# Source bash script to use local RVM installation.
source ./.rvm/scripts/rvm \
	|| { echo "ERROR: Failed to initialize local Ruby installation." && exit 2; }
GEM=./.rvm/rubies/default/bin/gem

# Install bundler if it is not already installed.
if ! ${GEM} list | grep --quiet "^bundler "
then
	echo "Installing Bundler from gem..."
	${GEM} install bundler \
		|| { echo "ERROR: Failed to install Bundler gem locally." && exit 4; }
	echo "Bundler installation complete."
fi
BUNDLE=bundle

# Install librarian-puppet if it is not already installed.
if ! ${GEM} list | grep --quiet "^librarian-puppet "
then
	echo "Installing required gems from gemfile..."
	# Install librarian-puppet via the Gemfile.
	${BUNDLE} install \
		|| { echo "ERROR: Failed to install gems locally." && exit 5; }
	echo "Gem installation complete."
fi
PUPPET=puppet
LIBRARIAN=librarian-puppet

# Initialize librarian-puppet if necessary.
if [ ! -d .librarian ]; then
	echo "Initializing librarian-puppet from Puppetfile..."
	${LIBRARIAN} install \
		|| { echo "ERROR: Failed to initialize Librarian-Puppet." && exit 6; }
	echo "Librarian-puppet initialized."
else
	# TODO: check this with librarian-puppet outdated.
	${LIBRARIAN} install \
		|| { echo "ERROR: Failed to initialize Librarian-Puppet." && exit 6; }
fi

# Warn the user if not running as root. (This may be desired in some special
# cases, but most commands probably won't work)
if [[ $EUID -ne 0 ]]; then
   echo "WARNING: Script not run as root, system-wide install commands may fail!" >&2
fi

# Apply the puppet manifest from this repository.
echo "Starting puppet update..."
${PUPPET} apply --hiera_config ./hiera.yaml \
                --modulepath ./modules \
                manifests/site.pp \
    || { echo "ERROR: Failure during puppet configuration." && exit 1; }
echo "Update complete."
