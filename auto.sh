#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

my_dir="$(dirname "$(realpath "${0}")")"

while :; do
    inputs="$(find "${my_dir}/" -type f -name '*.stl')"
    for input in ${inputs}; do
        input_relative="$(realpath --relative-to="${my_dir}" "${input}")"

        # Check if output file already exists
        if [[ -f "${input/%.stl/}"*.gcode ]]; then
            continue
        fi

        source "${my_dir}/config.sh"

        flags=()
        flags+=(--output-filename-format "{input_filename_base}_{print_time}_{temperature[0]}C_{filament_type[0]}.gcode")
        flags+=(--load "${printer_dir}/${printer}")

        # Fetch print
        layer_height="$(echo "${input_relative}" | awk -F'/' '{print $1}')"
        flags+=(--load "${print_dir}/${layer_heights["${layer_height}"]}")

        # Fetch material
        material="$(echo "${input_relative}" | awk -F'/' '{print $2}')"
        flags+=(--load "${filament_dir}/${materials["${material}"]}")

        # Do the slicing
        (
            set -x
            "${slicer}" --export-gcode "${flags[@]}" "${input}" && while test ! -f "${input/%.stl/}"*.gcode; do sleep 1; done
        )

        # Upload to printer
    done
    sleep 1
done
