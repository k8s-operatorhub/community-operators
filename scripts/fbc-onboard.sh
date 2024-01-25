#! /usr/bin/env bash
#
set -euo pipefail

YQ=${YQ:-$(/usr/bin/env yq)}
OPM=${OPM:-$(/usr/bin/env opm)}

# cache curent dir as top of individual operator author hierarchy
# we assume that everything below this is to be converted
CWD=$(readlink -e .)
if [ "$(basename $CWD)" != "community-operators" ]; then
    echo "error: this script should be run from the repo root dir (not $CWD)"
    exit 255
fi

relative_curdir="."

CATALOG_URI="registry.redhat.io/redhat/community-operator-index"
CATALOG_VER="v4.15"

# the location of where we cache catalog data to reduce the pull data
CATALOG_CACHEDIR="$CWD/scripts/catalog-cache"
CATALOG_CACHEFILE="$(basename $CATALOG_URI)-$CATALOG_VER.yaml"
CATALOG_CACHEPATH="$CATALOG_CACHEDIR/$CATALOG_CACHEFILE"

# the name of the location to which we render FBC
CATALOG_DIR="catalog"
# the name of the location to which we render template data precursors (templates, etc.)
CATALOG_PRECURSOR_DIR="catalog-data"
# the name of the location where per-operator config lives in this repo
OPERATORS_DIR="operators"
# the name of the basic catalog template file created in precursors dir
PRECURSOR_FILE="basic-catalog-template.yaml"
# the name of the CI integration file for the operator
CI_FILE="ci.yaml"

function usage() {
    echo "usage: $0 [options] [operator-name1..operator-nameN]"
    echo "where options are:"
    echo " -h --help : this text"
    exit 1
}

function cache_catalog() {
    if [ ! -d "$CATALOG_CACHEDIR" ]; then
        mkdir -p $CATALOG_CACHEDIR
        if [ "$?" -ne "0" ]; then
            echo "error: unable to create catalog cache directory"
            exit 2
        fi
    fi
    if [ -e $CATALOG_CACHEPATH ]; then
        if [ $(find $CATALOG_CACHEDIR -mtime -1 -type f -name $CATALOG_CACHEFILE 2>/dev/null) ]; then
            echo "catalog cache is fresh at $CATALOG_CACHEPATH"
        fi
    else
        echo "caching catalog to $CATALOG_CACHEPATH"
        set -x
        # --migrate to keep the results small
        $OPM render -o yaml --migrate "$CATALOG_URI:$CATALOG_VER" > $CATALOG_CACHEPATH
        set +x
        if [ ! -s "$CATALOG_CACHEPATH" ]; then
            echo "error: unable to cache catalog"
            exit 3
        fi
    fi
}

function mark_fbc() {
    OPNAME="$1"
    yq -i ".updateGraph = \"FBC\"" $OPERATORS_DIR/$OPNAME/$CI_FILE
}

function convert_operator() {
    OPNAME="$1"
    OPPATH="$OPERATORS_DIR/$OPNAME"
    if [ ! -d "$OPPATH" ]; then
        echo "specified operator does not exist: $OPNAME"
        return
    fi

    if [ ! -d "$OPPATH/$CATALOG_PRECURSOR_DIR" ]; then
        mkdir -p "$OPPATH/$CATALOG_PRECURSOR_DIR"
    fi

    set -x
    $YQ eval "select(.name == \"$OPNAME\" or .package == \"$OPNAME\")" $CATALOG_CACHEPATH | \
      $YQ eval 'select(.schema == "olm.bundle") = {"schema": .schema, "image": .image}' > $OPPATH/$CATALOG_PRECURSOR_DIR/$PRECURSOR_FILE
    set +x

    mark_fbc $OPNAME
}

function main() {
    cache_catalog

    while [ "$#" -gt 0 ]; do
        arg="$1"
        shift

        case "$arg" in
            -h|--help)
                usage
                ;;
            *)
                convert_operator $arg
                ;;
        esac
    done
}

main $*

