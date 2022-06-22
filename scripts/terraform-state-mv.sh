#!/bin/bash -e

function usage() {
  echo "$(basename $0) Move your terragrunt states

  Usage: $0 -s <path-to-module> -d <path-to-new-module>

  Options :
        -s <path-to-module>:
        -d <path-to-new-module>:


  Example:
        $0 -s cloud-foundation/eks/aws-tags  -d kube001/aws-tags
  "
}

function opterr() {
  echo "$(basename $0): error: ${1}"
  echo ""
  usage
  exit 1
}

function ensure_app_is_installed() {
  command -v ${1} >/dev/null 2>&1 || {
    echo >&2 "'${1}' is require but it was not found in path. Aborting."
      exit 1
    }
}

if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

while getopts "s:d:h?" optname; do
  case "$optname" in
    "?")
      usage
      exit 0
      ;;
    "s")
      SOURCE=$OPTARG
      ;;
    "d")
      DESTINATION=$OPTARG
      ;;
    "h")
      usage
      exit 0
      ;;
  esac
done

if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

function opterr() {
  echo "$(basename $0): error: ${1}"
  echo ""
  usage
  exit 1
}


if [ "${SOURCE}" == "" ]; then
  opterr "Missing <source>. Please use -s <source>"
fi

if [ "${DESTINATION}" == "" ]; then
  opterr "Missing <destination>. Please use -d <destination>"
fi

echo $DESTINATION
## Running State Move
echo "pulling state..."
cd $SOURCE && terragrunt state pull > move-state-teste.json
sed -e "1,2d" < move-state-teste.json > state.json
cd -
echo "State saved"
cp $SOURCE/state.json $DESTINATION
echo "State moved to destination"
echo "pushing satate..."
cd $DESTINATION && terragrunt state push state.json
echo "State push"
terragrunt plan
echo "Migration done!"
rm state.json
echo "File state deleted"