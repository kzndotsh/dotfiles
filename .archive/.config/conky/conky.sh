#!/bin/sh
sleep 5
conky -c ./conkyl.conf &
conky -c ./conkylm.conf &
conky -c ./conkyrm.conf &
conky -c ./conkyr.conf &