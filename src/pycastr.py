#!/usr/bin/python
import os,subprocess
import commands,json
import requests, base64
import sys,time
import argparse
import socket

parser = argparse.ArgumentParser(description="Cast Desktop")
parser.add_argument('cast', nargs="+", help="cast desktop to a client")
parser.add_argument('-C', '--client-ip', dest='client_ip', required=True, help='Client hostname or IP Address')
parser.add_argument('-P', '--client-port', dest='client_port', help='Client port')
parser.add_argument('--audio-only', action='store_true', dest='audio_only')
parser.add_argument('--video-only', action='store_true', dest='video_only')
args = parser.parse_args()

AUDIO_SETTINGS = " --no-video --no-sout-video" if args.audio_only else ""
VIDEO_SETTINGS = " --no-audio --no-sout-audio" if args.video_only else ""
SOUND_DEVICE_SETTINGS = " --input-slave=pulse://" + commands.getstatusoutput("pacmd list-sources | awk '/name:.+\.monitor/'")[1][8:-1]
CLIENT_IP = args.client_ip
CLIENT_PORT = args.client_port if args.client_port!=None else "8080"
SERVER_IP = [l for l in ([ip for ip in socket.gethostbyname_ex(socket.gethostname())[2] if not ip.startswith("127.")][:1], [[(s.connect(('8.8.8.8', 53)), s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1]]) if l][0][0]

cast_cmd = "vlc --qt-start-minimized screen:// :screen-fps=34 :screen-caching=80 --sout '#transcode{vcodec=mp4v,vb=4096,acodec=mpga,ab=128,sca=Auto,width=1024,height=768}:http{mux=ts,dst=:8080/}'" + AUDIO_SETTINGS + SOUND_DEVICE_SETTINGS + VIDEO_SETTINGS
disable_local_audio_cmd = "pacmd set-sink-volume " + commands.getstatusoutput("pacmd list-sink-inputs | grep sink | grep -oP '(?<=<).*(?=>)'")[1] + " 100"

subprocess.Popen(cast_cmd, shell = True)
subprocess.Popen(disable_local_audio_cmd, shell = True)

# PUSH TO KODI
time.sleep(.500)
usrPass = "kodi:"
b64Val = base64.b64encode(usrPass)
url = 'http://' + CLIENT_IP + ':' + CLIENT_PORT + '/jsonrpc'
print(url)
payload = {"jsonrpc":"2.0", "id":1, "method": "Player.Open", "params":{"item":{"file":"http://" + SERVER_IP + ":8080?action=play_video"}}}
r=requests.post(url, 
                headers={"Authorization": "Basic %s" % b64Val,'content-type': 'application/json'},
                data=json.dumps(payload))
print(r.content)

