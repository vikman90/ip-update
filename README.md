# IP updating service for NoIP
This project is a simple daemon script to auto-update the host IP address in NoIP.

## Installation
1. Edit `noip.sh`script and set, at less, the parameters:
    * `USER`: Your user name.
    * `PASSWD`: Your user password.
    * `HOST`: The hostname at NoIP, e.g. "example.ddns.net"
2. Copy `noip.sh` to the local directory for user binaries: `sudo cp noip.sh /usr/local/bin`
3. Copy `noip` to the daemons directory: `sudo cp noip /etc/init.d`
4. Enable the service.
    * If your system has Systemd (modern): `sudo systemctl enable noip`
    * If your system has SysVinit (legacy): `sudo insserv noip`
5. Start the service: `sudo service noip start`

## License

Copyright © 2015-2016 Victor Manuel Fernandez-Castro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
