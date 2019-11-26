#!/usr/bin/python3

from entrypoint_helpers import env, str2bool, start_app


RUN_USER = env['run_user']
RUN_GROUP = env['run_group']
BITBUCKET_INSTALL_DIR = env['bitbucket_install_dir']
BITBUCKET_HOME = env['bitbucket_home']

start_cmd = f"{BITBUCKET_INSTALL_DIR}/bin/start-bitbucket.sh -fg"
if str2bool(env['elasticsearch_enabled']) is False or env['application_mode'] == 'mirror':
    start_cmd += ' --no-search'

start_app(start_cmd, BITBUCKET_HOME, name='Bitbucket Server')