# pycastr

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/9d52f052fea5479494a971633cb03abc)](https://www.codacy.com/app/georg-bernold/pycastr?utm_source=github.com&utm_medium=referral&utm_content=bgeVam/pycastr&utm_campaign=badger)

Neat tool to cast your audio/video to kodi clients

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

## Compile and Install

**Install with Cmake** 

For advanced instructions please take a look at [the elementary os developer guidelines](https://elementary.io/en/docs/code/getting-started#building-and-installing-with-cmake).

Please start with cloning or downloading the repository.

1. Create a build directory

```
mkdir build
```

2. Change to build directory

```
cd build/
```

3. Prepare to build the app

```
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
```

4. Build the app

```
make
```

5. Install the app

```
sudo make install
```