#!/bin/sh
printf '\033c\033]0;%s\a' Space Shooter V2
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Space Shooter V2.x86_64" "$@"
