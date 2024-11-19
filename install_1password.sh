#!/bin/bash
# https://github.com/blue-build/modules/blob/c0943c009d578214d8bd3d6f185a106420dc034e/modules/bling/installers/1password.sh
set -xeuo pipefail

onepassword_gid=59999
onepassword_cli_gid=59998

rpm-ostree install 1password 1password-cli

mv /var/opt/1Password /usr/lib/opt/
echo 'L /opt/1Password - - - - /usr/lib/opt/1Password' >/usr/lib/tmpfiles.d/opt-1password.conf

rm -v /usr/lib/sysusers.d/*onepassword*
echo "g onepassword ${onepassword_gid}" >/usr/lib/sysusers.d/onepassword.conf
chgrp ${onepassword_gid} /usr/lib/opt/1Password/1Password-BrowserSupport
chmod 2755 /usr/lib/opt/1Password/1Password-BrowserSupport
echo "g onepassword-cli ${onepassword_cli_gid}" >/usr/lib/sysusers.d/onepassword-cli.conf
chgrp ${onepassword_cli_gid} /usr/bin/op
chmod 2755 /usr/bin/op

exec ostree container commit
