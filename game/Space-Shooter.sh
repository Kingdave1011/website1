#!/bin/sh
printf '\033c\033]0;%s\a' Galactic Combat
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Space-Shooter.x86_64" "$@"
