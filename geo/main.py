import os
import requests
import json
import subprocess
import sys
import re
from flask import Flask
from flask_pushjack import FlaskAPNS

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")

delimiter = 'Cell'
re_mac = re.compile("\s+\d{2} - Address: (\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})")
re_ch = re.compile("\s+Channel:(\d+)")
re_freq = re.compile("\s+Frequency:(\S+) GHz")
re_qual = re.compile("\s+Quality=(\S+)  Signal level=(\S+) dBm")
re_essid = re.compile("\s+ESSID:\"([^\"]+)\"")

# config = {'APNS_CERTIFICATE': '/home/root/entrust_root_certification_authority.pem'}
config = {'APNS_CERTIFICATE': '/home/root/dev_push.pem'}

class AP:
    def __init__(self, mac_address=None, channel=None, frequency=None, quality=None, signal=None, essid=None):
        self.mac_address = mac_address
        self.channel = channel
        self.frequency = frequency
        self.quality = quality
        self.signal = signal
        self.essid = essid

    @classmethod
    def scan_access_points(cls):
        access_points = []
        output = subprocess.check_output(["/sbin/iwlist", "wlan0", "scan"])
        for ap_data in output.split(delimiter):
            ap = cls()
            lines = ap_data.splitlines()
            for line in lines:
                matched_mac = re_mac.match(line)
                if matched_mac:
                    ap.mac_address = matched_mac.group(1)

                matched_ch = re_ch.match(line)
                if matched_ch:
                    ap.channel = matched_ch.group(1)

                matched_freq = re_freq.match(line)
                if matched_freq:
                    ap.frequency = matched_freq.group(1)

                matched_qual = re_qual.match(line)
                if matched_qual:
                    ap.quality = matched_qual.group(1)

                matched_essid = re_essid.match(line)
                if matched_essid:
                    ap.essid = matched_essid.group(1)

            if ap.mac_address is not None:
                access_points.append(ap)
        return access_points


def find_geolocation():
    aps = AP.scan_access_points()
    
    url = "https://www.googleapis.com/geolocation/v1/geolocate?key=" + GOOGLE_API_KEY
    headers = {"Content-Type": "application/json"}
    data = {
        "wifiAccessPoints": [
            {"macAddress": ap.mac_address, "signalStrength": ap.signal, "channel": ap.channel} for ap in aps
        ]
    }
    res = requests.post(url, headers=headers, json=data)
    geo = res.json()
    return geo['location']['lat'], geo['location']['lng']

# App definition
app = Flask(__name__)
app.config.update(config)

client = FlaskAPNS()
client.init_app(app)

@app.route("/")
def hello():
    return "Hello world!"

@app.route("/loc")
def loc():
    lat, lng = find_geolocation()
    return "{} {}".format(lat, lng)

@app.route("/nearby")
def nearby():    
    import mraa
    import time
    x = mraa.Gpio(13)
    pin1 = mraa.Gpio(9)
    pin2 = mraa.Gpio(10)
    x.dir(mraa.DIR_OUT)
    pin1.dir(mraa.DIR_OUT)
    pin2.dir(mraa.DIR_OUT)
    for i in range(40):
        x.write(1)
        pin1.write(1)
        pin2.write(0)
        time.sleep(1)
        pin1.write(0)
        pin2.write(0)
        x.write(0)
        time.sleep(1)

if __name__ == '__main__':
    assert GOOGLE_API_KEY is not None, "GOOGLE_API_KEY must be set."
    #with app.app_context():
    #    res = client.send("afb5c4ff3c153dbe30a3a04ee168030f5b5d786035f629779ad999af3786a697", "hello world!")
    #    print res.tokens
    #    print res.errors
    #    print res.token_errors
    app.run(host='0.0.0.0', port=80)




