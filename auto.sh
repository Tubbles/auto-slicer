#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

my_dir="$(dirname "$(realpath "${0}")")"

while :; do
    "${my_dir}/run.sh"
    sleep 1
done
