#!/bin/sh

tx_wl0=23
tx_wl1=20

# Wifi TX-power (FRENCH reg)
(sleep 60;iwconfig wl0 txpower $tx_wl0;iwconfig wl1 txpower $tx_wl1)&
