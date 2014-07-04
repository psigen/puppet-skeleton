puppet-skeleton
===============

This is a skeleton for a standalone git-based puppet package.  It is designed so that you can check out this repository onto an Ubuntu machine and run the update script to handle bootstrapping puppet and applying the settings in the included site.pp.

You can fork this skeleton to create standalone puppet git repos that are useful for personal computers and laptops.  When you need to update a machine, just clone or checkout the git repo onto that machine and run ./update.sh.  You don't need to do anything else!

How it works
------------
The update.sh script first checks for a few core packages, namely puppet-common and librarian-puppet.  If these don't exist, some version of them (not necessarily the latest) is downloaded and installed.  It is assumed that puppet itself can install more recent versions if necessary.

Librarian-puppet is then used to checkout/update any necessary dependencies into the ./modules directory.  (See https://github.com/rodjek/librarian-puppet for more details).  If you need to include any local packages, put them in ./local and include them in the Puppetfile as relative file URIs.

Finally, Puppet itself is called in 'masterless' mode with the included ./modules and ./manifests directories.  This applies the site.pp instructions.  In theory, different nodes could be used, if the names of each machine are known, but more commonly, all settings are just applied to directly or to the 'default' node, and the repo itself is branched for different machines.
