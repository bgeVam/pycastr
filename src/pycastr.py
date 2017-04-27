#!/usr/bin/python
import argparse
import re
import socket
import subprocess
import sys
import time
from netdisco.discovery import NetworkDiscovery
from kodijson import Kodi, Player

parser = argparse.ArgumentParser(description="Cast Desktop")
subparsers = parser.add_subparsers(help='commands', dest='command')

# Cast start
cast_start_parser = subparsers.add_parser(
    'cast-start', help='cast desktop to client')
cast_start_parser.add_argument(
    '-C', '--client-ip', dest='client_ip', required=True, help='Client hostname or IP Address')
cast_start_parser.add_argument(
    '-P', '--client-port', dest='client_port', help='Client port')
cast_start_parser.add_argument(
    '--audio-only', action='store_true', dest='audio_only')

# Cast stop
cast_stop_parser = subparsers.add_parser(
    'cast-stop', help='stop casting desktop to client')

# List Clients
list_clients_parser = subparsers.add_parser(
    'list-clients', help='list all available clients')

args = parser.parse_args()

if args.command == "cast-stop":
    subprocess.Popen("killall vlc", shell=True)
    sys.exit()

if args.command == "list-clients":
    netdis = NetworkDiscovery()
    netdis.scan()
    for dev in netdis.discover():
        client_name = dev
        client_ip = re.search(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', str(netdis.get_info(dev))).group()
        print(dev + ":" + client_ip)
    netdis.stop()
    print("LivingRoom:192.168.0.15")
    print("Balcony:192.168.0.18")
    sys.exit()

AUDIO_SETTINGS = " --no-video --no-sout-video" if args.audio_only else ""

SOUND_DEVICE_SETTINGS = " --input-slave=pulse://" + \
    subprocess.getoutput(
        "pacmd list-sources | grep name: | grep monitor | grep -oP '(?<=<).*(?=>)'")

CLIENT_IP = args.client_ip
CLIENT_PORT = args.client_port if args.client_port != None else "8080"
SERVER_IP = [l for l in ([ip for ip in socket.gethostbyname_ex(socket.gethostname())[2] if not ip.startswith("127.")][:1], [
                         [(s.connect(('8.8.8.8', 53)), s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1]]) if l][0][0]

cast_cmd = "cvlc --qt-start-minimized screen:// :screen-fps=34 :screen-caching=80 --sout '#transcode{vcodec=mp4v,vb=4096,acodec=mpga,ab=128,sca=Auto,width=1024,height=768}:http{mux=ts,dst=:8080/" + socket.gethostname(
) + "}'" + AUDIO_SETTINGS + SOUND_DEVICE_SETTINGS
disable_local_audio_cmd = "pacmd set-sink-volume " + subprocess.getoutput(
    "pacmd list-sink-inputs | grep sink | grep -oP '(?<=<).*(?=>)'") + " 100"

subprocess.Popen(cast_cmd, shell=True)
subprocess.Popen(disable_local_audio_cmd, shell=True)

# PUSH TO KODI
KODI_URL = "http://" + CLIENT_IP.replace(' ', '') + ":" + CLIENT_PORT + "/jsonrpc"
KODI_URL = KODI_URL.replace('\r', '').replace('\n', '')
kodi = Kodi(KODI_URL, "kodi", "")
kodi.GUI.ShowNotification(title=socket.gethostname(), message="pycastr")
time.sleep(.500)
kodi.Player.Open({"item": {"file": "http://" + SERVER_IP +
                           ":8080/" + socket.gethostname() + "?action=play_video"}})
print(kodi.Player.getItem({"properties": [
      "title", "thumbnail", "file"], "playerid": 1}, id="VideoGetItem"))
