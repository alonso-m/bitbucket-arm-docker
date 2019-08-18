import pytest

import io
import tarfile
import testinfra
import time
import xml.etree.ElementTree as etree
import requests


BB_INSTALL = '/opt/atlassian/bitbucket'
BB_HOME = '/var/atlassian/application-data/bitbucket'
BB_SHARED_HOME = '/var/atlassian/application-data/bitbucket/shared'
BB_MAIN_CLASS = 'com.atlassian.bitbucket.internal.launcher.BitbucketServerLauncher'

# Run an image and wrap it in a TestInfra host for convenience.
# FIXME: There's probably a way to turn this into a fixture with parameters.
def run_image(docker_cli, image, environment={}, ports={}):
    container = docker_cli.containers.run(image, environment=environment, ports=ports, detach=True)
    return testinfra.get_host("docker://"+container.id)

# TestInfra's process command doesn't seem to work for arg matching
def get_procs(container):
    ps = container.run('ps -axo args')
    return ps.stdout.split('\n')

def wait_for_proc(container, proc_str, max_wait=10):
    waited = 0
    while waited < max_wait:
        procs = list(filter(lambda p: proc_str in p, get_procs(container)))
        if len(procs) > 0:
            return procs[0]
        time.sleep(0.1)
        waited += 0.1

    raise TimeoutError("Failed to find target process")

def wait_for_file(container, path, max_wait=10):
    waited = 0
    while waited < max_wait:
        if container.file(path).exists:
            return
        time.sleep(0.1)
        waited += 0.1

    raise TimeoutError("Failed to find target process")


######################################################################
# Tests

def test_first_run_state(docker_cli, image):
    container = docker_cli.containers.run(image, ports={7990: 7990}, detach=True)
    for i in range(20):
        try:
            r = requests.get('http://localhost:7990/status')
        except requests.exceptions.ConnectionError:
            pass
        else:
            if r.status_code in (requests.codes.ok, requests.codes.service_unavailable):
                state = r.json().get('state')
                assert state in ('STARTING', 'FIRST_RUN')
                return
        time.sleep(1)
    raise TimeoutError


def test_jvm_args(docker_cli, image):
    environment = {
        'JVM_MINIMUM_MEMORY': '383m',
        'JVM_MAXIMUM_MEMORY': '2047m',
        'JVM_SUPPORT_RECOMMENDED_ARGS': '-verbose:gc',
    }
    container = run_image(docker_cli, image, environment=environment)
    jvm = wait_for_proc(container, BB_MAIN_CLASS)

    assert f'-Xms{environment.get("JVM_MINIMUM_MEMORY")}' in jvm
    assert f'-Xmx{environment.get("JVM_MAXIMUM_MEMORY")}' in jvm
    assert environment.get('JVM_SUPPORT_RECOMMENDED_ARGS') in jvm


def test_elasticsearch_default(docker_cli, image):
    container = run_image(docker_cli, image)
    jvm = wait_for_proc(container, BB_MAIN_CLASS)
    assert '--no-search' not in jvm

    es = wait_for_proc(container, "org.elasticsearch.bootstrap.Elasticsearch")


def test_elasticsearch_disabled(docker_cli, image):
    environment = {'ELASTICSEARCH_ENABLED': 'false'}
    container = run_image(docker_cli, image, environment=environment)
    jvm = wait_for_proc(container, "start-bitbucket.sh")
    assert '--no-search' in jvm


def test_application_mode_mirror(docker_cli, image):
    environment = {'APPLICATION_MODE': 'mirror'}
    container = run_image(docker_cli, image, environment=environment)
    jvm = wait_for_proc(container, "start-bitbucket.sh")
    assert '--no-search' in jvm

