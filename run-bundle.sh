#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

my_dir="$(dirname "$(realpath "${0}")")"
slicer="${my_dir}/prusa-slicer"

gcode_does_not_exist () {
    stem="$(basename -s ".stl" "${1}")"
    find "$(dirname "${1}")" -type f -regextype posix-extended -regex ".*/${stem}_.+.gcode" | grep -q .
    echo $?
}

shopt -s globstar nullglob
for input in **/*.stl; do
    input="$(realpath "${input}")"
    #input_relative="$(realpath --relative-to="${my_dir}" "${input}")"

    # Check if output file already exists
    if [[ "$(gcode_does_not_exist "${input}")" == "0" ]]; then
        continue
    fi

    #source "${my_dir}/config.sh"

    flags=()
    #flags+=(--output-filename-format "{input_filename_base}_{print_time}_{digits(layer_height,1,2)}mm_{temperature[0]}C_{filament_type[0]}_{printer_model}.gcode")
    flags+=(--load "${my_dir}/PrusaSlicer_config_bundle.ini")

    # Fetch print
    #layer_height="$(echo "${input_relative}" | awk -F'/' '{print $1}')"
    #flags+=(--load "${print_dir}/${layer_heights["${layer_height}"]}")

    # Fetch material
    #material="$(echo "${input_relative}" | awk -F'/' '{print $2}')"
    #flags+=(--load "${filament_dir}/${materials["${material}"]}")

    print="0.20 mm NORMAL (0.4 mm nozzle) @CREALITY - Copy"
    printer="Creality Ender-3 V2 (0.4 mm nozzle) - Copy"
    filament="Generic PLA @CREALITY - Copy"

    flags+=(--material-profile "${filament}")
    flags+=(--print-profile "${print}")
    flags+=(--printer-profile "${printer}")

    # Do the slicing
    (
        set -x
        "${slicer}" --export-gcode "${flags[@]}" "${input}" && while ! compgen -G "${input/%.stl/}"*.gcode &>/dev/null; do sleep 1; done
    )

    # Upload to printer
done
