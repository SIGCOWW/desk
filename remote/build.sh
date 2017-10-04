#!/bin/bash
cd ~/
set -eu
TMPDIR=$(mktemp -d tmp.XXXXXXXX)
DIFF=".temporary.diff"

clean() {
	cd ~/
	rm -rf "$TMPDIR"
	exit
}
#trap 'clean' ERR


# Clone
cat > "${TMPDIR}/$DIFF"
header=$(head -n1 "${TMPDIR}/${DIFF}" | cut -b2-)
repo=$(echo "$header" | cut -d':' -f1)
if [ ! -d "$repo" ]; then
	git clone "git@github.com:SIGCOWW/${repo}.git"
fi

# Fetch
cd "$repo"
origin=$(echo "$header" | cut -d':' -f2)
set +e
ret=$(git log origin/master --pretty=format:"%H" | grep "$origin")
set -e
if [ ! "$ret" ]; then git fetch; fi

# Apply
cd "../"
cp -a "${repo}/." "$TMPDIR"
cd "$TMPDIR"
git checkout "$origin"
git apply "$DIFF"

# Build
./make.sh "build"
file="working_temporary_directory/original.pdf"
if [ -f "$file" ]; then
	set +e
	git diff --no-index --binary /dev/null $file | sed 's/^/+>#/'
	set -e
fi

# Clean
clean
