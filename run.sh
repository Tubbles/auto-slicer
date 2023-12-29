#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

my_dir="$(dirname "$(realpath "${0}")")"

gcode_does_not_exist () {
    stem="$(basename -s ".stl" "${1}")"
    find "$(dirname "${1}")" -type f -regextype posix-extended -regex ".*/${stem}_([0-9]+h|)[0-9]+m_[0-9]+C_[A-Za-z0-9]+.gcode" | grep -q .
    echo $?
}

shopt -s globstar nullglob
for input in **/*.stl; do
    input="$(realpath "${input}")"
    input_relative="$(realpath --relative-to="${my_dir}" "${input}")"

    # Check if output file already exists
    if [[ "$(gcode_does_not_exist "${input}")" == "0" ]]; then
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
        "${slicer}" --export-gcode "${flags[@]}" "${input}" && while ! compgen -G "${input/%.stl/}"*.gcode &>/dev/null; do sleep 1; done
    )

    # Upload to printer
done
