#!/usr/bin/env bash
# -*- coding: utf-8 -*-

my_dir="$(dirname "$(realpath "${0}")")"

conf_dir="${HOME}/.var/app/com.prusa3d.PrusaSlicer/config/PrusaSlicer"
filament_dir="${conf_dir}/filament"
print_dir="${conf_dir}/print"
printer_dir="${conf_dir}/printer"

printer="Creality Ender-3 V2 - Copy.ini"

declare -A materials=(
    ["pla"]="AddNorth @CREALITY.ini"
    ["petg"]="addnorth ESD-PETG @Template - Copy.ini"
)

declare -A layer_heights=(
    ["200um"]="0.20mm NORMAL @CREALITY - Copy - SCRIPT.ini"
    ["280um"]="0.28mm SUPERDRAFT @CREALITY - Copy.ini"
)

slicer="com.prusa3d.PrusaSlicer"
