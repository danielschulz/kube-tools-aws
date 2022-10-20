#!/bin/bash
# usage: source this script --
# in this example, from this very folder './', which is optional:
# `source ./0--initialize-workenv-once.sh`


# source PyENV's ROOT dir
command -v pyenv >/dev/null || export PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$( pyenv init - )"

# source PyENV's extension/plugin pyenv-virtualenv
eval "$( pyenv virtualenv-init - )"


# check & poss. create PyENV w/ packages
if [[ $( pyenv versions | grep -E '^((\*)?\s+dev\-jarvis\s+|\s+dev\-jarvis$)' | wc -l ) -lt 1 ]]; then
  # create VENV from pre-installed Python installed in PyENV
  pyenv virtualenv "${PYTHON_VERSION}" dev-jarvis
fi

# utilize it in this Bash session
pyenv activate dev-jarvis

# check, whether both dependencies can be found in it or install them:
#   - Docker-Compose for building and
#   - PreCommit for Linting & Formatting
if [[ $( pip list | grep -E '^(docker-compose|pre-commit)' | wc -l ) -lt 2 ]]; then
  pip install pre-commit docker-compose
fi

# before Git-committing changes, please configure your workplace's Git client w/
#   - your name and
#   - your eMail
# e.g.
# git config --global user.name Daniel Schulz
# git config --global user.email daniel.schulz@bayer.com
