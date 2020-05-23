#!/bin/bash
#
# Copyright (C) 2020 SebaUbuntu's Telegram Bash Bot
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

export VERSION=0.1.0
export BRANCH=Alpha

export SCRIPT_PWD=$(pwd)

# Source variables and basic functions
source variables.sh
source base/get.sh
source base/send.sh
source base/admin.sh
source base/modules.sh

import_variables
import_more_variables

import_modules

if [ $(get_updates | jq .ok) = "true" ]; then
	while [ 0 != 1 ]; do
		if [ "$LAST_UPDATE_ID" != "" ]; then
			LAST_UPDATES=$(get_updates -d offset="$LAST_UPDATE_ID")
		else
			LAST_UPDATES=$(get_updates)
		fi
		UNREAD_UPDATES_NUMBER="$(get_unread_updates_number "$LAST_UPDATES")"
		if [ "$UNREAD_UPDATES_NUMBER" != "0" ]; then
			echo "Found $UNREAD_UPDATES_NUMBER update(s)"
			CURRENT_UPDATES_NUMBER=0
			while [ "$UNREAD_UPDATES_NUMBER" -gt "$CURRENT_UPDATES_NUMBER" ]; do
				execute_module "$(get_specific_update "$LAST_UPDATES" "$CURRENT_UPDATES_NUMBER")"
				CURRENT_UPDATES_NUMBER=$(( CURRENT_UPDATES_NUMBER + 1 ))
			done
			LAST_UPDATE_ID=$(get_last_update_id "$LAST_UPDATES")
			LAST_UPDATE_ID=$(( LAST_UPDATE_ID + 1 ))
		fi
	done
else
	echo "Error!"
fi