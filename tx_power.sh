#!/bin/sh

(sleep 60; iwconfig wl0 txpower 30; iwconfig wl1 txpower 30) &

exit 0
