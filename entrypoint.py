#!/usr/bin/python3

import sys
import os
import shutil
import logging
import jinja2 as j2


######################################################################
# Utils

logging.basicConfig(level=logging.DEBUG)

def set_perms(path, user, group, mode):
    for dirpath, dirnames, filenames in os.walk(path):
        shutil.chown(dirpath, user=user, group=group)
        os.chmod(dirpath, mode)
        for filename in filenames:
            shutil.chown(os.path.join(dirpath, filename), user=user, group=group)
            os.chmod(os.path.join(dirpath, filename), mode)


######################################################################
# Setup inputs and outputs

# Import all ATL_* and Dockerfile environment variables. We lower-case
# these for compatability with Ansible template convention. We also
# support CATALINA variables from older versions of the Docker images
# for backwards compatability, if the new version is not set.
env = {k.lower(): v
       for k, v in os.environ.items()}


######################################################################
# Start as the correct user

start_cmd = f"{env['bitbucket_install_dir']}/bin/start-bitbucket.sh"
if env['elasticsearch_enabled'] == 'false' or env['application_mode'] == 'mirror':
    start_cmd += ' --no-search'

if os.getuid() == 0:
    logging.info(f"User is currently root. Will change directory ownership to {env['run_user']} then downgrade permissions")
    set_perms(env['bitbucket_home'], env['run_user'], env['run_group'], 0o700)

    cmd = '/bin/su'
    start_cmd = ' '.join([start_cmd] + sys.argv[1:])
    args = [cmd, env['run_user'], '-c', start_cmd]
else:
    start_cmd = start_cmd.split()
    cmd = start_cmd[0]
    args = start_cmd[1:] + sys.argv[1:]

logging.info(f"Running Bitbucket with command '{cmd}', arguments {args}")
os.execv(cmd, args)
