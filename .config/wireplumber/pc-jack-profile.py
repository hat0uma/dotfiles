#!/usr/bin/python3
"""Select the built-in UCM profile from the physical headphone jack state."""
import json
import os
import selectors
import subprocess
import time

CARD = 'alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic'
ENV = dict(os.environ, LC_ALL='C')

def pactl(*args):
    return subprocess.check_output(['pactl', *args], env=ENV, stderr=subprocess.DEVNULL, text=True, timeout=5)

def reconcile():
    cards = json.loads(pactl('-f', 'json', 'list', 'cards'))
    card = next((c for c in cards if c['name'] == CARD), None)
    if not card:
        return
    ports = card.get('ports', {})
    jack = ports.get('[Out] Headphones', {})
    # Do not guess the jack state when the driver has not reported it yet.
    state = jack.get('availability')
    if state not in ('available', 'not available'):
        return
    port = jack if state == 'available' else ports.get('[Out] Speaker', {})
    profiles = port.get('profiles', [])
    target = next((p for p in profiles if p.startswith('HiFi')), None)
    if target and card.get('active_profile') != target:
        pactl('set-card-profile', CARD, target)
        print('Selected profile:', target, flush=True)

if __name__ == '__main__':
    while True:
        proc = subprocess.Popen(['pactl', 'subscribe'], env=ENV, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        try:
            with selectors.DefaultSelector() as selector:
                selector.register(proc.stdout, selectors.EVENT_READ)
                reconcile()
                while proc.poll() is None:
                    events = selector.select(timeout=15)
                    if events:
                        chunk = os.read(proc.stdout.fileno(), 65536)
                        if not chunk:
                            break
                        if b' on card ' not in chunk:
                            continue
                        time.sleep(0.2)
                    reconcile()
        except (subprocess.SubprocessError, ValueError, OSError) as error:
            print(type(error).__name__, flush=True)
        finally:
            proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
        time.sleep(2)
