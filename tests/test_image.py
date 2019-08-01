import pytest

import io
import tarfile
import time
import xml.etree.ElementTree as etree

import requests


# Helper function to get a file-like object from an image
def get_fileobj_from_container(container, filepath):
    time.sleep(0.5) # Give container a moment if just started
    stream, stat = container.get_archive(filepath)
    f = io.BytesIO()
    for chunk in stream:
        f.write(chunk)
    f.seek(0)
    with tarfile.open(fileobj=f, mode='r') as tar:
        filename = tar.getmembers()[0].name
        file = tar.extractfile(filename)
    return file



def test_elasticsearch_default(docker_cli, image):
    container = docker_cli.containers.run(image, detach=True)
    procs = container.exec_run('ps aux')
    procs_list = procs.output.decode().split('\n')
    start_bitbucket = [proc for proc in procs_list if 'start-bitbucket.sh' in proc][0]
    assert '--no-search' not in start_bitbucket
    

def test_elasticsearch_disabled(docker_cli, image):
    environment = {'ELASTICSEARCH_ENABLED': 'false'}
    container = docker_cli.containers.run(image, environment=environment, detach=True)
    procs = container.exec_run('ps aux')
    procs_list = procs.output.decode().split('\n')
    start_bitbucket = [proc for proc in procs_list if 'start-bitbucket.sh' in proc][0]
    assert '--no-search' in start_bitbucket


def test_application_mode_mirror(docker_cli, image):
    environment = {'APPLICATION_MODE': 'mirror'}
    container = docker_cli.containers.run(image, environment=environment, detach=True)
    procs = container.exec_run('ps aux')
    procs_list = procs.output.decode().split('\n')
    start_bitbucket = [proc for proc in procs_list if 'start-bitbucket.sh' in proc][0]
    assert '--no-search' in start_bitbucket


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
    