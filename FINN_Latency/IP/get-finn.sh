#!/bin/bash

# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT

declare -A repos
declare -A commits

repos[finn]="https://github.com/Xilinx/finn.git"

commits[finn]="1bcf6d3190f2fa674ad4414b161fe10a13c49260"

# absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

for key in "${!repos[@]}"
do
  # absolute path for the repo local copy
  CLONE_TO=$SCRIPTPATH/$key

  # clone repo if dir not found
  if [ ! -d "$CLONE_TO" ]; then
    git clone ${repos[$key]} $CLONE_TO
  fi
  git -C $CLONE_TO pull

  # checkout the expected commit
  git -C $CLONE_TO checkout ${commits[$key]}

  # verify
  CURRENT_COMMIT=$(git -C $CLONE_TO rev-parse HEAD)
  if [ $CURRENT_COMMIT == ${commits[$key]} ]; then
    echo "Successfully checked out $key at commit $CURRENT_COMMIT"
  else
    echo "Could not check out $key. Check your internet connection and try again."
  fi
done