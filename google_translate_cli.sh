#!/bin/bash

CLIENT=gtx
CODING=UTF-8
DT=t

sourceLang=""
targetLang=""
query=""
verbose=false

function printUsage() {
  printf "Available flags:\n"
  printf -- "\t --help or -h: Show help\n"
  printf -- "\t --list or -l: List available languages\n"
  printf -- "\t --verbose or -v: Print more details about translation"
  printf -- "\t --sourceLang or -s: Source language\n"
  printf -- "\t --targetLang or -t: Target language\n"
  printf -- "\t --query or -q: Query to translate\n"
  printf "\n"
  printf "Usage:\n"
  printf "\t translate -h\n"
  printf "\t translate -l\n"
  printf "\t translate -s en -t pl -q \"Something to translate\"\n"
  printf "\t translate -v -s en -t pl -q \"Something to translate\"\n"
}

function printLinkToAvailableLanguages() {
  printf -- "See here: https://cloud.google.com/translate/docs/languages\n"
}

function parseArgs() {
  args=("$@")
  index=0
  while [ $index -lt $# ]; do
    if [ "${args[${index}]}" == "--help" ] || [ "${args[${index}]}" == "-h" ]; then
      printUsage
      exit 0
    elif [ "${args[${index}]}" == "--list" ] || [ "${args[${index}]}" == "-l" ]; then
      printLinkToAvailableLanguages
      exit 0
    elif [ "${args[${index}]}" == "--sourceLang" ] || [ "${args[${index}]}" == "-s" ]; then
      sourceLang="${args[((index + 1))]}"
    elif [ "${args[${index}]}" == "--targetLang" ] || [ "${args[${index}]}" == "-t" ]; then
      targetLang="${args[((index + 1))]}"
    elif [ "${args[${index}]}" == "--query" ] || [ "${args[${index}]}" == "-q" ]; then
      query="${args[((index + 1))]}"
    elif [ "${args[${index}]}" == "--verbose" ] || [ "${args[${index}]}" == "-v" ]; then
      verbose=true
    else
      printUsage
      exit 1
    fi
    ((index += 2))
  done
}

function urlencode() {
  # urlencode <string>
  old_lc_collate=$LC_COLLATE
  LC_COLLATE=C

  local length="${#1}"
  for ((i = 0; i < length; i++)); do
    local c="${1:i:1}"
    case $c in
    [a-zA-Z0-9.~_-]) printf "$c" ;;
    *) printf '%%%02X' "'$c" ;;
    esac
  done

  LC_COLLATE=$old_lc_collate
}

if [ $# -ne 0 ]; then
  parseArgs "$@"
fi

if [ -z "$query" ]; then
  printf "Query can not be empty!\n\n" 1>&2
  printUsage
  exit 1
fi

if [ -z "${sourceLang}" ]; then
  sourceLang="${TRANSLATION_DEFAULT_SOURCE_LANG}"
  if [ -z "${sourceLang}" ]; then
    sourceLang="auto"
  fi
fi

if [ -z "${targetLang}" ]; then
  targetLang="${TRANSLATION_DEFAULT_TARGET_LANG}"
  if [ -z "${targetLang}" ]; then
    printf "Target language can not be empty!\n\n" 1>&2
    printUsage
    exit 1
  fi
fi

encodedQuery=$(urlencode "$query")

RESPONSE=response.txt
HEADERS=headers.txt

curl -s -D $HEADERS "$1" -o $RESPONSE -H "Accept: application/json" \
  "https://translate.googleapis.com/translate_a/single?client=${CLIENT}&sl=${sourceLang}&tl=${targetLang}&dt=${DT}&ie=${CODING}&oe=${CODING}&q=${encodedQuery}"

status=$(head -n 1 <"${HEADERS}" | awk '{print $2}')
if [ "${status}" -ne 200 ]; then
  printf "Translation failed with status %s!\n\n" "${status}" 1>&2
  rm "${RESPONSE}" "${HEADERS}"
  exit 1
else
  translationResponse=$(cat "${RESPONSE}")
  translationResponse="${translationResponse//,null/}"
  translationResponse="${translationResponse//[/}"
  translationResponse="${translationResponse//]/}"
  translationResponse="${translationResponse//[$'\t\r\n']/}"
  result=$(sed 's/[^"]*"\([^"]*\).*/\1/' <<< "${translationResponse}")
  IFS=','
  read -ra splitResponse <<<"${translationResponse}"
  if [ "${verbose}" == true ]; then
    size=${#splitResponse[@]}
    printf "Translation result\n"
    printf "\t From: %s\n" "${result}"
    printf "\t To: %s\n" "${targetLang}"
    printf "\t Original text: \"%s\"\n" "${query}"
    printf "\t Translated text: %s\n" "${splitResponse[0]}"
  else
    echo "${result}"
  fi
  rm "${RESPONSE}" "${HEADERS}"
fi
