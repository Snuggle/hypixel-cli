#!/bin/bash
configFile=~/.config/hypixel-cli
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

  # Convert PLUS to +'s! For example, MVP_PLUS -> MVP+
  if [ "$actualRank" == "SUPERSTAR" ]; then
    actualRank="MVP++"
  fi
  if [[ "$actualRank" = *"_PLUS"* ]]; then
    actualRank="${actualRank%$"_PLUS"}+"
  fi

  rawActualRank="$actualRank" # Save uncoloured string for later.

  # Now add colour!
  if [[ $showColor == true ]]; then
    if [[ $actualRank == "" ]]; then
      actualRank="\e[38;5;245m"
    fi
    if [[ $actualRank == "VIP" ]]; then
      actualRank="\e[38;5;82m[VIP] "
    fi
    if [[ $actualRank == "VIP+" ]]; then
      actualRank="\e[38;5;82m[VIP\e[38;5;214m+\e[38;5;82m] "
    fi
    if [[ $actualRank == "MVP" ]]; then
      actualRank="\e[38;5;45m[MVP] "
    fi
    if [[ $actualRank == "MVP+" ]]; then
      actualRank="\e[38;5;122m[MVP\e[38;5;203m+\e[38;5;122m] "
    fi
    if [[ $actualRank == "MVP++" ]]; then
      actualRank="\e[38;5;214m[MVP\e[38;5;203m++\e[38;5;214m] "
    fi
    if [[ $actualRank == "YOUTUBER" ]]; then
      actualRank="\e[38;5;203m[\e[97mYOUTUBE\e[38;5;203m] "
    fi
    if [[ $actualRank == "HELPER" ]]; then
      actualRank="\e[38;5;105m[HELPER] "
    fi
    if [[ $actualRank == "MODERATOR" ]]; then
      actualRank="\e[38;5;28m[MODERATOR] "
    fi
    if [[ $actualRank == "ADMIN" ]]; then
      actualRank="\e[38;5;203m[ADMIN] "
    fi
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
