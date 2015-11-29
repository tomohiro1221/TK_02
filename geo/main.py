import os
import requests
import json
import subprocess
import sys
import re

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")

delimiter = 'Cell'
re_mac = re.compile("\s+\d{2} - Address: (\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})")
re_ch = re.compile("\s+Channel:(\d+)")
re_freq = re.compile("\s+Frequency:(\S+) GHz")
re_qual = re.compile("\s+Quality=(\S+)  Signal level=(\S+) dBm")
re_essid = re.compile("\s+ESSID:\"([^\"]+)\"")


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

if __name__ == '__main__':
    assert GOOGLE_API_KEY is not None, "GOOGLE_API_KEY must be set."

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
    print geo

