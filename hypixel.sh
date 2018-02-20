#!/bin/bash
installationDir=~/.config/hypixel-cli
hypixelURL="https://api.hypixel.net/"
showColor=true

getRank() {
  rankLocations=".player.oldPackageRank .player.newPackageRank .player.monthlyPackageRank .player.rank"
  for value in $rankLocations; do
    tempRank=$(jq -r "$value" <<<"$playerJSON")
    if [ "$tempRank" != "null" ] && [ "$tempRank" != "NORMAL" ]; then
      actualRank="$tempRank"
    fi
  done

  rawActualRank="$actualRank" # Save uncoloured string for later.

  # Now add colour!
  if [[ $showColor == true ]]; then
    rankJSON=$(<$installationDir/ranks.json) # Read ranks.json into variable.
    actualRank=$(jq -r ".$actualRank" <<<"$rankJSON") # Find appropriate coloured string.
  else
    actualRank="$actualRank "
  fi
}

lookupPlayer() {
  lookupValues=".player.uuid .player.prefix .player.karma .player.mcVersionRp .player.knownAliases .player.rank .player.monthlyPackageRank .player.newPackageRank .player.oldPackageRank .player.userLanguage .player.mostRecentGameType"

  requestURL=$hypixelURL"player?key="$key"&name="$1 # Build the request URL.
  playerJSON=$(curl -s $requestURL) # Get the JSON from the API.
  displayName=$(jq -r '.player.displayname' <<<"$playerJSON") # Get the player's displayname and UUID.

  # Print player's rank/name title.
  getRank
  playerTitle="$actualRank$displayName\e[39m\n"
  printf "$playerTitle"

  # Print a **perfectly-sized** underline.
  playerTitle="$rawActualRank$displayName"
  echo "${playerTitle//?/―}―――"

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

if [ ! -f "$installationDir/config" ]; then
  echo "This is the first time running hypixel-cli! Please enter your API key and it'll be saved in \"$installationDir/config\"."
  read key
  echo "$key" > "$installationDir/config" # Write API key to file.
else
  key=$(cat "$installationDir/config") # Get API key.
  if [ "$1" == "player" ] || [ "$#" == 1 ]; then # If "hypixel player[...]" or one argument passed.
    for last; do true; done # Get the last argument passed. (https://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script)
    lookupPlayer $last
  fi
fi
