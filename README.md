# IP updating service for NoIP

This project is a simple daemon script to auto-update the host IP address in NoIP.

## Installation

To install this program, simply run `install.sh` and follow the instructions.

### Manual configuration and installation

1. Edit `noip.sh`script and set, at less, the parameters:
    * `USER`: Your user name.
    * `PASSWD`: Your user password.
    * `HOST`: The hostname at NoIP, e.g. "example.ddns.net"
2. Copy `noip.sh` to the local directory for user binaries: `sudo cp noip.sh /usr/local/bin`
3. Copy `noip` to the daemons directory (see below).
4. Enable the service.
5. Start the service:

Steps 3-5 depend on your init system:

#### Install service for Systemd

Systemd is used in the most modern Linux systems.
*Use `sudo` if needed:*

```
cp noip.service /etc/systemd/system
systemctl enable noip
systemctl start noip
```

#### Install service for SysVinit

```
cp noip /etc/init.d
insserv noip
service noip start
```

## License

Copyright © 2015-2016 Victor Manuel Fernandez-Castro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
