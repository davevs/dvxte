#!/bin/bash
cd /var/www/html/dvws-node
node startup_script.js
PORT=5000 npm run dvws
