# Finds a dependency inside the vendor folder by the repro name, removes it vendor and symlinks to to a local copy of that dependency
# If the dependency doesn't exit in vendor, has multiple possible options or a copy doesn't exist in the $GOPATH then nothing will happen
# Note that the search string is case sensitive
# Usage
# E.X. 'symlinkVendorPackage testify' would find 'vendor/github.com/stretchr/testify', remove it from vendor, and symlink to $GOPATH/src/github.com/stretchr/testify
# Large file paths may also be used and can help avoid the case where there are multiple options
# E.X. 'symlinkVendorPackage stretchr/testify' (or even 'symlinkVendorPackage github.com/stretchr/testify') would work even if there was another 'testify' directory under './vendor'

# TODO
#  - Detect existing symlink
#  - Better search for package in GOPATH (current version could still catch invalid options)
#    - Searching for t finds testify for example
#  - Dry run flag
#  - Break logic into functions

### Argbash code starts here, jump to 'ACTUAL SCRIPT STARTS HERE' to skip

### Argbash code starts here, jump to 'ACTUAL SCRIPT STARTS HERE' to skip

#!/bin/bash
#
# This is a rather minimal example Argbash potential
# Example taken from http://argbash.readthedocs.io/en/stable/example.html
#
# ARG_POSITIONAL_SINGLE([symlink-package],[The package to symlink into current project)],[])
# ARG_OPTIONAL_BOOLEAN([ignore-vendor],[],[Ignore (do not move) nested vendor directories])
# ARG_OPTIONAL_BOOLEAN([version],[v],[Print the scripts version])
# ARG_HELP([The general script's help msg])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.6.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate

die() {
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

begins_with_short_option() {
	local first_option all_short_options
	all_short_options='vh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_ignore_vendor="off"
_arg_version="off"

print_help() {
	printf '%s\n' "The general script's help msg"
	printf 'Usage: %s [--(no-)ignore-vendor] [-v|--(no-)version] [-h|--help] <symlink-package>\n' "$0"
	printf '\t%s\n' "<symlink-package>: The package to symlink into current project)"
	printf '\t%s\n' "--ignore-vendor,--no-ignore-vendor: Ignore (do not move) nested vendor directories (off by default)"
	printf '\t%s\n' "-v,--version,--no-version: Print the scripts version (off by default)"
	printf '\t%s\n' "-h,--help: Prints help"
}

parse_commandline() {
	while test $# -gt 0; do
		_key="$1"
		case "$_key" in
		--no-ignore-vendor | --ignore-vendor)
			_arg_ignore_vendor="on"
			test "${1:0:5}" = "--no-" && _arg_ignore_vendor="off"
			;;
		-v | --no-version | --version)
			_arg_version="on"
			test "${1:0:5}" = "--no-" && _arg_version="off"
			;;
		-v*)
			_arg_version="on"
			_next="${_key##-v}"
			if test -n "$_next" -a "$_next" != "$_key"; then
				begins_with_short_option "$_next" && shift && set -- "-v" "-${_next}" "$@" || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
			fi
			;;
		-h | --help)
			print_help
			exit 0
			;;
		-h*)
			print_help
			exit 0
			;;
		*)
			_positionals+=("$1")
			;;
		esac
		shift
	done
}

handle_passed_args_count() {
	_required_args_string="'symlink-package'"
	test ${#_positionals[@]} -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: $_required_args_string), but got only ${#_positionals[@]}." 1
	test ${#_positionals[@]} -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: $_required_args_string), but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')." 1
}

assign_positional_args() {
	_positional_names=('_arg_symlink_package')

	for ((ii = 0; ii < ${#_positionals[@]}; ii++)); do
		eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing, possibly an Argbash bug." 1
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash
# ] <-- needed because of Argbash

### ACTUAL SCRIPT STARTS HERE

# echos the number of lines in the input, treats an empty string as zero lines
# $1 is the input to check
_countLines() {
	if [[ $localDependencyPath == "" ]]; then
		echo "0"
	else
		echo "$localDependencyPath" | wc -l
	fi
}

if [[ $_arg_version == "on" ]]; then
	echo "Version 3.1.1"
	exit
fi

if [[ $_arg_symlink_package == "" ]]; then
	echo "FAILURE: No input for target package, please provide a package to symlink"
	exit 1
fi

if [ ! -d vendor ]; then
	echo "FAILURE: No vendor directory at current location, aborting"
	exit 1
fi

# look for the dependency in GOPATH first, this supports adding a new dependency into vendor if its not already in vendor
# the maxdepth is since go packages should follow the pattern '$GOPATH/src/domain/user/repo' so only search down three directories to limit results
localDependencyPath=$(find $GOPATH/src -maxdepth 3 -d -path "*$_arg_symlink_package" | grep -v /vendor/)

numResults=$(_countLines "$localDependencyPath")

if (($numResults == 0)); then
	echo "FAILURE: Package '$_arg_symlink_package' does not exist in GOPATH, aborting"
	exit 1
elif (($numResults != 1)); then
	echo "FAILURE: Found "$numResults" possible dependency hits in GOPATH, aborting"
	echo "Possible dependencies:"
	echo "$localDependencyPath"
	exit 1
fi

echo "Found package '$_arg_symlink_package' inside GOPATH at '$localDependencyPath'"

expectedVendorPath="./vendor"${localDependencyPath#$GOPATH/src}

# path matches against the whole path name
if [ ! -d $expectedVendorPath ]; then
	echo "Package '$_arg_symlink_package' does not currently exist in vendor, will symlink using path $expectedVendorPath"
else
	if [[ -L $expectedVendorPath ]]; then
		echo "Package '$_arg_symlink_package' is in vendor and appears to already be a symlink"
	else
		echo "Package '$_arg_symlink_package' is in vendor at $expectedVendorPath"
	fi
fi

echo "Preparing to symlink '$_arg_symlink_package' into vendor from GOPATH"

if [ -d "$localDependencyPath/vendor" ]; then
	echo
	echo "ATTENTION!! Package '$_arg_symlink_package' in GOPATH has a vendor directory, if left this way, your build will almost certainly break."

	if [ $_arg_ignore_vendor == "on" ]; then
		echo "NOT MOVING NESTED VENDOR DIRECTORY DUE TO --ignore-vendor parameter!!!"
		echo "THIS WILL MOST LIKELY BREAK YOUR BUILD, BUT YOU TOLD ME TO DO IT!!!"
	else
		echo "Moving the nested vendor directory to 'vendor_bak', use \`mv "$localDependencyPath/vendor_bak" "$localDependencyPath/vendor"\` to reverse"
		mv "$localDependencyPath/vendor" "$localDependencyPath/vendor_bak"
		echo "Moved the nested vendor directory successfuly! Your build should work correctly!"
	fi

else
	echo
	echo "No need to move vendor directory from '$_arg_symlink_package' as it does not have a vendor directory. Your build should be fine!"
fi

if [ -d $expectedVendorPath ]; then
	rm -rf $expectedVendorPath
fi

ln -s $localDependencyPath ${expectedVendorPath%/$_arg_symlink_package}

# touch all files in the symlinked package to ensure gopherJS and other tools see the changes correctly
find "./vendor/$vendorDependencyPath" -type f -name "*.go" -exec touch {} +

echo
echo "Success! Package '$_arg_symlink_package' was symlinked into vendor from GOPATH correctly!"