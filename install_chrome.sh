#!/bin/bash
set -xeuo pipefail
rpm-ostree install google-chrome-stable
mv /var/opt/google /usr/lib/opt/
echo 'L /opt/google - - - - /usr/lib/opt/google' >/usr/lib/tmpfiles.d/opt-google.conf
sed -i 's/google-chrome-stable/google-chrome-stable --enable-features=AcceleratedVideoDecodeLinuxGL/g' /usr/share/applications/google-chrome.desktop
exec ostree container commit
