# Damn Vulnerable Xebia Training Environment

DVXTE is a docker container with several vulnerable applications.
By using a docker container it's easy to setup and can easily be reset to it's starting point.

Currently the following training environments are implemented in the Docker container:
  * DVWA          https://github.com/ethicalhack3r/DVWA
  * DVWServices   https://github.com/snoopysecurity/dvws
  * DVWSockets    https://github.com/interference-security/DVWS
  * WebGoat       https://github.com/WebGoat/WebGoat
  * Juiceshop     https://github.com/bkimminich/juice-shop
  * Railsgoat     https://github.com/OWASP/railsgoat
  * django.NV     https://github.com/nVisium/django.nV
  * Buggy Bank    https://www.mavensecurity.com/about/webmaven/

Next to those, the following tools are installed:
  * Mailcatcher   https://mailcatcher.me/
  * Brakeman      http://brakemanscanner.org/
  * RIPS          https://sourceforge.net/projects/rips-scanner/files/

Once build, the image currently has a size of roughly 1.3GB

# TODO
  * Mutilidae II  https://sourceforge.net/projects/mutillidae/files/
  * Webgoat.net   https://github.com/jerryhoff/WebGoat.NET
