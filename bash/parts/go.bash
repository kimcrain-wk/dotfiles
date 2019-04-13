# The GOCACHE makes tests a lot faster, but it can also hide random failures.
enableGoTestCache() { unset GOCACHE; }
disableGoTestCache() { export GOCACHE=off; }

# clear go test cache
alias goClearTestCache='go clean -testcache'

# run all go tests
goTestAll() { go test ./...; }

# install go simple, becuase it keeps uninstalling somehow
installGoSimple() { go get honnef.co/go/tools/cmd/gosimple; }

# remove/install gopherJS, because of caching issues with serve
removeGopherJS() { rm -rf $GOPATH/src/github.com/gopherjs; }
installGopherJS() { go get -u github.com/gopherjs/gopherjs; }
reinstallGopherJS() { removeGopherJS && installGopherJS; }

# Identies all directories with changed go files and runs the given command ($1) in all those directories
# passed in command must be able to run with a single in the form `command $directory`
# Note, if this is run from non-repo root, it will only touch things at this directory and below
# E.X. `_smartGoRunner goFormat` would run `goFormat` in all directories with changed go files
# Generally should use one of the public (not `_`) smartGoBLANK style functions
_smartGoRunner() {
	# Throw an alert if not at the repo root just so no mistakes are made
	if [[ $(git rev-parse --show-toplevel) != $(pwd) ]]; then
		echo "FYI: Not running at repo root, not all files may be processed"
		echo
	fi

	# Print changed files, no deleted files, .go files only regardless of index or working tree.
	# The --relative flag returns paths relative to the current path, allowing running in sub-directories.
	# Use grep to remove any entries from the vendor directory as these should never be touched.
	changedFiles=$(git diff HEAD --relative --name-only --diff-filter=d -- '*.go' | grep -v '^vendor/')
	if [[ "$changedFiles" == "" ]]; then
		echo "No changed files found, aborting"
		return 0
	fi

	commandToRun=$1

	# https://unix.stackexchange.com/questions/217628/cut-string-on-last-delimiter
	# echo, reverse it, get 2nd and beyond fields, reverse again
	# using `dirname` might be better, but that requires looping over lines
	endingsRemoved=$(echo "$changedFiles" | rev | cut -d'/' -f2- | rev)

	uniqueDirs=$(echo "$endingsRemoved" | sort | uniq)

	while read -r line; do
		# go test requires the './' at the start of a path
		# `go test ./common/stuff` = good
		# `go test common/stuff` = bad
		line="./$line"
		echo "####"
		echo "#### running $commandToRun in '$line'"
		echo "####"

		eval $commandToRun $line
		echo ""
	done <<<"$uniqueDirs"
}

# Identies all directories with changed go files and runs `goFormat` in all those directories
smartGoFormat() { _smartGoRunner goFormat; }

# TODO "superSmartGoLint" highlights lints on lines that were changed
# Identies all directories with changed go files and runs `goLint` in all those directories
smartGoLint() { _smartGoRunner goLint; }

# Identies all directories with changed go files and runs goCheck (`goFormat` + `goLint`) in all those directories
smartGoCheck() { _smartGoRunner goCheck; }

# Identies all directories with changed go files and runs `gosimple` in all those directories
smartGoSimple() { _smartGoRunner gosimple; }

# Identies all directories with changed go files and runs `go test` in all those directories
smartGoTest() { _smartGoRunner 'go test'; }

# Identies all directories with changed go files the whole suite of go checks
# This includes, `goFormat`, `goLint`, `gosimple` and `go test`
smartGoAll() {
	smartGoCheck
	smartGoSimple
	smartGoTest
}

# Identies all directories with changed go files the whole suite of go checks minus go lint
# Good for cleaner output in code that is very messy according to the linter
# This includes, `goFormat`, `gosimple` and `go test`
smartGoAllNoLint() {
	smartGoFormat
	smartGoSimple
	smartGoTest
}

# runs `goFormat` and `goLint` in the given directory. If no input, assume the current ('.') directory
goCheck() {
	goFormat $1
	goLint $1
}

# runs `goimports -w` in the given directory. If no input, assume the current ('.') directory
goFormat() {
	input=$1
	if [[ $input == "" ]]; then
		input="."
	fi

	goimports -w $input # does everything gofmt does plus organizes imports, also see goreturns
}

# runs `golint` in the given directory. If no input, assume the current ('.') directory
goLint() {
	input=$1
	if [[ $input == "" ]]; then
		input="."
	fi

	golint $input
}

# populate these two variables with options for paths to not delete when running cleanGoPath. These will be given to a find command.
export cleanGoPathDomainProtected=""                            # E.X '! -name github.com' to ignore all go packages coming from the 'github.com' domain
export cleanGoPathGithubUserProtected="! -name convergedtarkus" # Of course I protect my repos, they are just too awesome to delete

cleanGoPath() {
	# the "$@" passes all arguments to the symlink script
	../scripts/cleanGoPath.bash "$@"
}

symlinkVendorPackage() {
	# the "$@" passes all arguments to the symlink script
	../scripts/symlinkPackageIntoVendor.bash "$@"
}

# Helper to easily move the vendor directory. Pairs with the symlinkVendorPackage function.
backupVendorDir() {
	if [ ! -d ./vendor ]; then return; fi
	mv ./vendor ./vendor_bak
}

# Helper to undo backupVendorDir
restoreVendorDir() {
	if [ ! -d ./vendor_bak ]; then return; fi
	mv ./vendor_bak ./vendor
}

# dep aliases
alias depEnsure='dep ensure -v'
alias depEnsureUp='dep ensure -v -update'
