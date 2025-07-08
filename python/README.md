# Simplify coding with support of AI agents

Python simplifying AI agent supported coding.

## Developer Guide

### Prerequisites

It is recommended to use a python virtual environment. Create and activate it:

```shell
python -m venv venv
source venv/bin/activate
```

Install the required python packages:

```shell
pip install -r requirements.txt
```

Then install this package in development mode:

```shell
pip install --editable .
```

### Execute the Tests Once

```shell
python -m pytest
```

### Launch the Test Runner in the Interactive Watch Mode

```shell
ptw . --now --last-failed --new-first
```
