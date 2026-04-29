#!/usr/bin/env bash

if [[ -z $1 ]]; then
	exit 0
fi

color=''
str=$1
len=${#str}
top_bottom_line=$(printf '%.0s-' $(seq 1 $((len + 4)))) # +4 for padding and corners

if [[ -n $2 ]]; then
	color_input="${2,,}"
	case "$color_input" in
		r|red)
			color='\e[0;31m'
			;;
		g|green)
			color='\e[0;32m'
			;;
		y|yellow)
			color='\e[0;33m'
			;;
		b|blue)
			color='\e[0;34m'
			;;
		m|magenta)
			color='\e[0;35m'
			;;
		c|cyan)
			color='\e[0;36m'
			;;
		# *)
		# 	color='\e[0m'
		# 	;;
	esac
fi

echo -e "${color}\
+$top_bottom_line+\n\
|  $str  |\n\
+$top_bottom_line+\e[0m"