# audirvana-docker

## Support me

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/H2H7UIN5D)  
Please see the [Goal](https://ko-fi.com/giof71/goal?g=0)  
Please note that support goal is limited to cover running costs for subscriptions to music services.

## References

This is a set of tools you can use in order to build and run docker images for Audirvana Studio and Audirvana Origin. See [here](https://audirvana.com/linux/) for more information.  

## Supported Platforms

The Audirvana applications can run on amd64 and on arm64 platforms.  
This includes Raspberry Pi SBC with a 64 bit version of Raspberry Pi OS.

## Disclaimer

I won't build and publish images which would include binaries from the Audirvana company.  
This means that there are no releated images available on docker hub. You will have to build your image yourself.  
The images resulting from applying the build recipe described in this repository will include the latest studio/origin binaries.  
When a new release is published, you will need to re-build your image, so that it will include the latest available version.  

## Prerequisites

### Docker

Docker must be installed on your system. Refer to your linux distribution documentation. For debian/ubuntu, you can refer to the next section.  

#### Install Docker on Debian/Ubuntu

On debian and derived distributions (this includes Raspberry Pi OS, DietPi, Moode Audio, Volumio), we can install the necessary packages using the following commands:

```text
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -a -G docker $USER
```

The last command adds the current user to the docker group. This is not mandatory; if you choose to skip this step, you might need to execute docker-compose commands by prepending `sudo`.  
Please note that this method uses the docker packages available on the distro repositories.  
If you want to install more up-to-date versions, refer to the guides [here](https://docs.docker.com/desktop/install/linux-install/)

### Clone the repository

You need to clone the repository. Make sure that `git` is installed using the following command on debian and derived distributions (again, this includes Raspberry Pi OS, DietPi, Moode Audio, Volumio):

```code
sudo apt-get update
sudo apt-get install -y git
```

Move to the your home directory and clone the repository using the commands:

```code
cd
git clone https://github.com/GioF71/audirvana-docker.git
```

The rest of the documentation will assume that you have cloned the repository in the suggested directory. If you operated differently, be sure to check and modify the commands appropriately.  

### Update the repository

If you just downloaded the repository, you can skip this step.  
If you previously cloned the repository, it might have been updated in the meantime. Move to the directory and pull the changes:

```code
cd $HOME/audirvana-docker
git config pull.rebase false
git pull
```

## Build

You can build your own images using the convenience scripts available in the root directory of this repository, `build-origin.sh` and `build-studio.sh`.  
From a terminal, you will need to enter one of the following, depending of the version of Audirvana you want to build:

```text
cd $HOME/audirvana-docker
./build-origin.sh
```

or

```text
cd $HOME/audirvana-docker
./build-studio.sh
```

You might want to append `--no-cache` to these commands in order to force rebuild without caching.  
I will not provide pre-built images, in order to avoid to include proprietary binaries.  
Initially, I tried installing the binaries at container startup time, but then abandoned that road. It worked, but the delay in the startup phase was a bit too long for my taste.  
Also, the resulting images could have been uploaded to docker hub, because they would not contain any binaries, but I believe that these would have provided very little advantage compared to the current solution.  

## Usage

### Environment Variables

VARIABLE|DESCRIPTION
:---|:---
ACCEPT_EULA|You MUST set this to `Y` or `YES`, case insensitive
BINARY_TYPE|Set it to either `studio` or `origin`
PUID|The uid for the user you want to run the application, see [User and Group ids](#user-and-group-ids)
PGID|The gid for the user you want to run the application, see [User and Group ids](#user-and-group-ids)
AUDIO_GID|The additional gid, should be set to the audio group id, see [User and Group ids](#user-and-group-ids)
MUSIC_DIRECTORY|The path to be mounted as `/music`, defaults to `./music`

### User and Group ids

Get the current user uid and gid by opening a terminal and entering:

```text
id
```

This should return something like:

```text
uid=1000(giovanni) gid=1000(giovanni) groups=1000(giovanni),995(audio)
```

Now you have your uid which is 1000, the gid which is also 1000, and the audio group id which in my case is 995.  
Your user might not be in the audio group (albeit this is unlikely in a desktop system), in this case you can obtain the group id using the following:

```text
getent group audio
```

Again in my case, this would return:

```text
audio:x:995:giovanni,mpd
```

Please note the adding the audio group is needed only if you want to use the device's built-in audio capabilities. If you plan the device to just be a server for other UPnP players, the step is not required.  

If the previous command does not return anything, the alsa libraries might not be installed correctly. Refer to your distro documentation to understand how to install alsa.  
Please note that I removed all the additional groups just to make things hopefully more readable.

### Configure

Configure the application you want to run by copying the `sample.env` file to a `.env` file:

```text
cp $HOME/audirvana-docker/sample.env $HOME/audirvana-docker/.env
```

Tune the content of the `.env` file according to the previous table and to the information provided in the `sample.env` file.  

### Run

After you have built the image you want to run, and created you configuration, simply run the application using the following:

```text
cd $HOME/audirvana-docker
docker-compose up -d
```

You can watch the logs using:

```text
cd $HOME/audirvana-docker
docker-compose logs -f
```

### (A bit more) Advanced

#### Compose file for Studio with builder

Build and start the Studio version of the application using the following command:

```text
cd $HOME/audirvana-docker
docker-compose -f docker-compose-studio.yaml up --build -d
```

Please note that this might trigger an image (re)build, if needed.

#### Compose file for Origin with builder

Build and start the Studio version of the application using the following command:

```text
cd $HOME/audirvana-docker
docker-compose -f docker-compose-origin.yaml up --build -d
```

Please note that this might trigger an image (re)build, if needed.  

### Renderer

You can easily add a player on mostly any device with audio capabilities using [this example](https://github.com/GioF71/audio-tools/tree/main/players/audirvana-upnp) using my images for [mpd](https://github.com/GioF71/mpd-alsa-docker), [upmpdcli](https://github.com/GioF71/upmpdcli-docker) and [yams](https://github.com/GioF71/yams-docker).  
Credit to the individual underlying projects can be found on the documentation of each repository.
