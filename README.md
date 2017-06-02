# pycastr

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/9d52f052fea5479494a971633cb03abc)](https://www.codacy.com/app/georg-bernold/pycastr?utm_source=github.com&utm_medium=referral&utm_content=bgeVam/pycastr&utm_campaign=badger)

Neat tool to cast your audio/video to UPnP clients

![Alt Text](https://github.com/bgeVam/pycastr/blob/master/pycastr_demo.gif)

## Features

![alt text](https://github.com/bgeVam/pycastr/blob/master/data/icons/pycastr_cast_screen_audio.png?raw=true "Mirror Desktop") Mirror your systems desktop on your TV

![alt text](https://github.com/bgeVam/pycastr/blob/master/data/icons/pycastr_cast_audio.png?raw=true "Cast Audio") Stream your audio to your hifi system

## Usage

NOTE: Two dummy clients are added as examples in pycastr.py. Sometimes client discovery fails, if this happens, just add your clients in lines 45-48 in pycastr.py.

* Select "Search clients" to update the list of available clients
* Select a client from the list to start casting
* Select this client again to stop casting
* Choose "Screen mirroring" for video casting

## Icons

The original icons used by pycastr may be found in [Google's material design icon repository](https://github.com/google/material-design-icons "material design icons repository").

## Install

**Requirements** 

* vlc
* python
* [python-kodijson](https://github.com/jcsaaddupuy/python-kodijson)

Just run install.sh as super user

```
sudo ./install.sh
```

## Uninstall

Just run uninstall.sh as super user

```
sudo ./uninstall.sh
```

## Compile Indicator

Compile Indicator with

```
valac *.vala --pkg gee-1.0 --pkg appindicator-0.1 --pkg gtk+-3.0 --pkg libnotify -o PycastrIndicator
```
