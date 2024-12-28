#!/bin/bash

# Copyright (C) 2024 Daniel Persson - All Rights Reserved
# You may use, distribute and modify this code under the terms of the MIT
# license.
#
# You should have received a copy of the MIT license with this file. If not,
# please visit https://github.com/perssonz/rtkbase-swepos.

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
podman run --rm -v $SCRIPT_DIR:/rtkbase-swepos:Z --net host -w /rtkbase-swepos ghcr.io/perssonz/rtkbase-swepos:latest ./get_postprocess.sh "$@"