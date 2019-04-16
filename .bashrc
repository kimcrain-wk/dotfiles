#!/usr/bin/env bash

if [ -d "$HOME/.bash-it" ]; then
	# Get the scripts directory (https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself)
	# This is use by the bash-it submodule to load the bash/combinedBash.bash
	scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
	export MY_DOT_FILES="$scriptDir"

	# Path to the bash it configuration
	export BASH_IT="$HOME/.bash-it"

	# Lock and Load a custom theme file
	# location /.bash_it/themes/
	export BASH_IT_THEME='sexy'

	# Don't check mail when opening terminal.
	unset MAILCHECK

	# Set this to false to turn off version control status checking within the prompt for all themes
	export SCM_CHECK=true

	# Load Bash It (and don't care that shellcheck cannot check this file)
	# shellcheck source=/dev/null
	source "$BASH_IT"/bash_it.sh
else
	# Just use my base bash info
	source ./bash/combinedBash.bash
fi
