#!/bin/sh

(sleep 60; iwconfig wl0 txpower 17; iwconfig wl1 txpower 21) &

exit 0
