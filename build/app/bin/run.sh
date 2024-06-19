#!/bin/bash

BINARY_TYPE=`cat /build/binary-type`
echo "BINARY_TYPE=[${BINARY_TYPE}]"

if [[ -z "${BINARY_TYPE}" ]]; then
    echo "Unknown binary type!"
    exit 1
fi

current_user=$(id -u)
echo "Current user has uid=[$current_user]"
RUNNING_USER_HOME_DIR=/root
run_as_user=0

if [[ $current_user -eq 0 ]]; then
    echo "Container started with user root"
    if [[ -n "${PUID}" && "${PUID}" != "0" ]]; then
        # we create the user
        echo "Running as root, creating user with uid [${PUID}] ..."
        run_as_user=1
        # create user
        DEFAULT_GID=1000
        if [ -z "${PGID}" ]; then
            PGID=$DEFAULT_GID;
            echo "Setting default value for PGID: ["$PGID"]"
        else
            echo "PGID=[${PGID}]"
        fi
        #if [ -z "${AUDIO_GID}" ]; then
        #    echo "AUDIO_GID is mandatory!"
        #    exit 1
        #else
        echo "AUDIO_GID=[${AUDIO_GID}]"
        #fi
        DEFAULT_USER_NAME=audirvana-user
        DEFAULT_GROUP_NAME=audirvana-group
        DEFAULT_HOME_DIR=/home/$DEFAULT_USER_NAME

        USER_NAME=$DEFAULT_USER_NAME
        GROUP_NAME=$DEFAULT_GROUP_NAME
        HOME_DIR=$DEFAULT_HOME_DIR
        echo "Ensuring user with uid:[$PUID] gid:[$PGID] exists ...";
        ### create group if it does not exist
        if [ ! $(getent group $PGID) ]; then
            echo "Group with gid [$PGID] does not exist, creating..."
            groupadd -g $PGID $GROUP_NAME
            echo "Group [$GROUP_NAME] with gid [$PGID] created."
        else
            GROUP_NAME=$(getent group $PGID | cut -d: -f1)
            echo "Group with gid [$PGID] name [$GROUP_NAME] already exists."
        fi
        ### create user if it does not exist
        if [ ! $(getent passwd $PUID) ]; then
            echo "User with uid [$PUID] does not exist, creating..."
            useradd -g $PGID -u $PUID -M $USER_NAME
            echo "User [$USER_NAME] with uid [$PUID] created."
        else
            USER_NAME=$(getent passwd $PUID | cut -d: -f1)
            echo "user with uid [$PUID] name [$USER_NAME] already exists."
            HOME_DIR="/home/$USER_NAME"
        fi
        ### create home directory
        if [ ! -d "$HOME_DIR" ]; then
            echo "Home directory [$HOME_DIR] not found, creating."
            mkdir -p $HOME_DIR
            echo ". done."
        fi
        if [[ -n "${AUDIO_GID}" ]]; then
            echo "Processing AUDIO_GID=[${AUDIO_GID}] ..."
            if [ $(getent group $AUDIO_GID) ]; then
                echo "Group with gid $AUDIO_GID already exists"
            else
                echo "Creating group with gid $AUDIO_GID"
                groupadd -g $AUDIO_GID audirvana-audio
            fi
            echo "Adding $USER_NAME [$PUID] to gid [$AUDIO_GID]"
            AUDIO_GRP=$(getent group $AUDIO_GID | cut -d: -f1)
            echo "gid $AUDIO_GID -> group $AUDIO_GRP"
            usermod -a -G $AUDIO_GRP $USER_NAME
        else
            echo "AUDIO_GID=[${AUDIO_GID}] not specified."
        fi
        echo "Successfully created user $USER_NAME:$GROUP_NAME [$PUID:$PGID])";
        chown -R $PUID:$PGID $HOME_DIR
        RUNNING_USER_HOME_DIR=$HOME_DIR
    else
        echo "Container running as root, not creating any user."
    fi
else
    echo "Container started with user [$current_user], this is not supported."
    exit 1
fi

if [[ "${ACCEPT_EULA^^}" == "Y" ]] || [[ "${ACCEPT_EULA^^}" == "YES" ]]; then
    echo "EULA Accepted."
    config_path=$RUNNING_USER_HOME_DIR/.config/audirvana
    mkdir -p $config_path
    config_file=$config_path/audirvana-${BINARY_TYPE}.ini
    if [ ! -f "$config_file" ]; then
        echo "EulaAccepted = 1" > $config_file
    else
        echo "Configuration file [$config_file] already exists, will not be modified."
    fi
    cat $config_file
else
    echo "EULA NOT Accepted!"
    exit 1
fi

# Setting home directory permissions again
if [[ $run_as_user -eq 1 ]]; then
    chown -R $PUID:$PGID $RUNNING_USER_HOME_DIR
fi

CMD_LINE="/opt/audirvana/${BINARY_TYPE}/audirvana${BINARY_TYPE^}"
echo "CMD_LINE=[${CMD_LINE}]"
if [[ $run_as_user -eq 1 ]]; then
    su - $USER_NAME -c "${CMD_LINE}"
else
    eval "${CMD_LINE}"
fi
