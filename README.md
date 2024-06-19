# audirvana-docker

## Support

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/H2H7UIN5D)  
Please see the [Goal](https://ko-fi.com/giof71/goal?g=0)  
Please note that support goal is limited to cover running costs for subscriptions to music services.

## References

This is a set of tools you can use in order to build and run docker images for Audirvana Studio and Audirvana Origin. See [here](https://audirvana.com/linux/) for references.  

## Supported Platforms

The Audirvana applications can run on amd64 and on arm64 platforms.  

## Build

You can build your own images using the convenience scripts available in the root directory of this repository, `build-origin.sh` and `build-studio.sh`.  
I will not provide pre-built images, in order to avoid to include proprietary binaries.  
Initially, I tried installing the binaries at container startup time, but then abandoned that road. It worked, but the delay in the startup phase was a bit too long for my taste.  
Also, the resulting images could have been uploaded to docker hub, because they would not contain any binaries, but I believe that these would have provided very little advantage compared to the current solution.  

## Usage

### Environment Variable

VARIABLE|DESCRIPTION
:---|:---
ACCEPT_EULA|You MUST set this to `Y` or `YES`, case insensitive
BINARY_TYPE|Set it to either `studio` or `origin`
PUID|The uid for the user you want to run the application
PGID|The gid for the user you want to run the application
AUDIO_GID|The additional gid, should be set to the audio group id

### Configure

Configure the application you want to run by copying the `sample.env` file to a `.env` file:

`cp sample.env .env`

Tune the content of the `.env` file according to the previous table and to the information provided in the `sample.env` file.  

### Run

After you have built the image you want to run, and created you configuration, simply run the application using the following:

`docker-compose up -d`

You can watch the logs using:

`docker-compose logs -f`

### (A bit more) Advanced

#### Compose file for Studio with builder

Build and start the Studio version of the application using the following command:

`docker-compose -f studio.yaml up --build -d`

Please note that this might trigger an image (re)build, if needed.

#### Compose file for Origin with builder

Build and start the Studio version of the application using the following command:

`docker-compose -f origin.yaml up --build -d`

Please note that this might trigger an image (re)build, if needed.
