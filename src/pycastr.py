#!/usr/bin/python
import argparse
import base64
import commands
import json
import os
import requests
import socket
import subprocess
import sys
import time

from kodijson import Kodi, Player

parser = argparse.ArgumentParser(description="Cast Desktop")
subparsers = parser.add_subparsers(help='commands', dest='command')

# Cast start
cast_start_parser = subparsers.add_parser('cast-start', help='cast desktop to client')
cast_start_parser.add_argument('-C', '--client-ip', dest='client_ip', required=True, help='Client hostname or IP Address')
cast_start_parser.add_argument('-P', '--client-port', dest='client_port', help='Client port')
cast_start_parser.add_argument('--audio-only', action='store_true', dest='audio_only')
cast_start_parser.add_argument('--video-only', action='store_true', dest='video_only')

# Cast stop
cast_stop_parser = subparsers.add_parser('cast-stop', help='Create a directory')

args = parser.parse_args()

if args.command == "cast-stop":
	subprocess.Popen("killall vlc", shell = True) 
	sys.exit()

AUDIO_SETTINGS = " --no-video --no-sout-video" if args.audio_only else ""
VIDEO_SETTINGS = " --no-audio --no-sout-audio" if args.video_only else ""
SOUND_DEVICE_SETTINGS = " --input-slave=pulse://" + commands.getstatusoutput("pacmd list-sources | awk '/name:.+\.monitor/'")[1][8:-1]
CLIENT_IP = args.client_ip
CLIENT_PORT = args.client_port if args.client_port!=None else "8080"
SERVER_IP = [l for l in ([ip for ip in socket.gethostbyname_ex(socket.gethostname())[2] if not ip.startswith("127.")][:1], [[(s.connect(('8.8.8.8', 53)), s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1]]) if l][0][0]

cast_cmd = "vlc --qt-start-minimized screen:// :screen-fps=34 :screen-caching=80 --sout '#transcode{vcodec=mp4v,vb=4096,acodec=mpga,ab=128,sca=Auto,width=1024,height=768}:http{mux=ts,dst=:8080/" + socket.gethostname() + "}'" + AUDIO_SETTINGS + SOUND_DEVICE_SETTINGS + VIDEO_SETTINGS
disable_local_audio_cmd = "pacmd set-sink-volume " + commands.getstatusoutput("pacmd list-sink-inputs | grep sink | grep -oP '(?<=<).*(?=>)'")[1] + " 100"

subprocess.Popen(cast_cmd, shell = True)
subprocess.Popen(disable_local_audio_cmd, shell = True)

# PUSH TO KODI
kodi = Kodi("http://" + CLIENT_IP + ":" + CLIENT_PORT + "/jsonrpc", "kodi", "")
kodi.GUI.ShowNotification(title=socket.gethostname(), message="pycastr")
time.sleep(.500)
kodi.Player.Open({"item":{"file":"http://" + SERVER_IP + ":8080/" + socket.gethostname() + "?action=play_video"}})
print(kodi.Player.getItem({"properties": ["title", "thumbnail", "file"],"playerid": 1}, id="VideoGetItem"))
