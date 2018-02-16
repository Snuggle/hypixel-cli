#!/bin/bash
configFile=~/.config/hypixel-cli
hypixelURL="https://api.hypixel.net/"

lookupPlayer() {
  lookupValues=".player.uuid .player.karma .player.mcVersionRp .player.knownAliases .player.rank .player.monthlyPackageRank .player.newPackageRank .player.oldPackageRank .player.userLanguage .player.mostRecentGameType"

  requestURL=$hypixelURL"player?key="$key"&name="$1 # Build the request URL.
  playerJSON=$(curl -s $requestURL) # Get the JSON from the API.
  identifier=$(jq -r '"\(.player.displayname) | \(.player.uuid)"' <<<"$playerJSON") # Get the player's displayname and UUID.
  echo $identifier
  echo ${identifier//?/―} # Print an underline.

  for value in $lookupValues; do
    valueName=${value##*.}
    valueName=${valueName^^}
    valueData=$(jq -r "$value" <<<"$playerJSON") # Print each JSON value in lookupValues.
    if [ "$valueData" != "null" ]; then # Hide any results that are null.
      valueData=$(echo "$valueData" | tr -d '\n ')
      echo "$valueName - $valueData"
    fi
  done

}

if [ ! -f "$configFile" ]; then
  echo "This is the first time running hypixel-cli! Please enter your API key and it'll be saved in \"$configFile\"."
  read key
  echo "$key" > "$configFile" # Write API key to file.
else
  key=$(cat "$configFile") # Get API key.
  if [ "$1" == "player" ] || [ "$#" == 1 ]; then # If "hypixel player[...]" or one argument passed.
    for last; do true; done # Get the last argument passed. (https://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script)
    lookupPlayer $last
  fi
fi
