.PHONY         = set-test-env circleci-test test clean build upload list
.DEFAULT_GOAL := list

########################################

SHELL          = /bin/bash
VENV_NAME      = .venv
CODECOV_TOKEN  = f8d82f5b-1379-4fa2-a011-77e83724ce46

########################################

set-test-env:
	python3 -m venv ${VENV_NAME}
	${VENV_NAME}/bin/python3 -m pip install --upgrade pip setuptools
	${VENV_NAME}/bin/python3 setup.py install
	${VENV_NAME}/bin/python3 -m pip install codecov tox

test:
	${VENV_NAME}/bin/flake8 toucan_data_sdk tests
	${VENV_NAME}/bin/pytest tests -x --cov-fail-under=100 --cov=toucan_data_sdk

circleci-test: set-test-env test
	${VENV_NAME}/bin/tox
	source ${VENV_NAME}/bin/activate && \
	codecov --token=${CODECOV_TOKEN}

clean:
	find . -name \*.pyc -delete
	find . -name \*.so -delete
	find . -name __pycache__ -delete
	rm -rf .coverage build dist *.egg-info

build:
	python setup.py sdist bdist_wheel

upload:
	twine upload dist/*

list:
	@grep '^[^\.#[:space:]].*:' Makefile | \
		cut -d':' -f1
