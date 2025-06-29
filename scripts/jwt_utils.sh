#!/bin/sh -x
#https://www.shell-tips.com/linux/how-to-format-date-and-time-in-linux-macos-and-bash/

jwt.decode() {
  echo "----------------------------------------------------------"
  echo "Header:"
  jq -R 'split(".") | .[0] | @base64d | fromjson' <<< "$1"
  echo "Payload:"
  jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
  echo "----------------------------------------------------------"
}


jwt.token.expiry() {
  exp=$(jq -R 'split(".") | .[1] | @base64d | fromjson | .exp' <<< "$1")
  if [[ -n "$exp" && "$exp" != "null" ]]; then
    date -r "$exp" +"%m/%d/%Y:%H:%M:%S"
  else
    echo "No 'exp' field found in token payload."
  fi
}