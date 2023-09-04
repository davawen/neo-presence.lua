#!/bin/sh

set -xe

RPC_VERSION=3.2.1
LINK="https://dl-game-sdk.discordapp.net/${RPC_VERSION}/discord_game_sdk.zip"
FILE="discord_sdk/sdk_${RPC_VERSION}.zip"

mkdir -p discord_sdk
mkdir -p build

if [ ! -e "$FILE" ]; then
	# clear folder first in case there is an older version already present
	rm -rf ./discord_sdk/*

	curl "$LINK" -o "$FILE"
fi

if [ ! -e "discord_sdk/README.md" ]; then
	unzip "$FILE" -d discord_sdk
fi

if [ ! -e "discord_game_sdk_processed.h" ]; then
	# used by presence.c
	cp -f discord_sdk/c/discord_game_sdk.h discord_game_sdk.h

	# preprocess file for lua and remove useless includes (luajit ffi doesn't need any)
	grep -v "#include" discord_game_sdk.h | cpp -P > discord_game_sdk_processed.h
fi

if [ ! -e "libdiscord_game_sdk.so" ]; then
	cp discord_sdk/lib/x86_64/discord_game_sdk.so libdiscord_game_sdk.so # (add 'lib' prefix)
fi

gcc -fPIC -c presence.c -o presence.o # compile (shared) object file

# gcc -shared presence.o -L . -ldiscord_game_sdk -o libpresence.so # create shared library (depending on discord library)
# since the lua file plugin is in another folder, there are a few problems with relative paths. it's easier to link with absolute paths (since it's built on the user's machine anyway)
gcc -shared presence.o $(realpath libdiscord_game_sdk.so) -o libpresence.so
