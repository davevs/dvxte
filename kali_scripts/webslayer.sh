# wine version
dpkg --add-architecture i386 && apt-get update && apt-get install wine32
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/webslayer/WebSlayer-Beta.msi
wine msiexec /i WebSlayer.msi
