# IP updating service for NoIP

This project is a simple script to auto-update the host IP address in NoIP.

It synchronizes periodically to keep your IP updated.

## Installation

To install this program, simply run `install.sh` and follow the instructions.

### Manual configuration and installation

1. Create a file with name `noip_conf` and write the following parameters:

    ```
    USER="your_usename"
    PASSWD="your_password"
    HOST="your_hostname"
    LAST_IP=""
    ```

    Leave the last parameter in blank. Then copy this file in the folder `etc/noip`. I advise you to give reading permissions only to `root` since it contains **sensitive information**:

    ```
    $ sudo mkdir -p /etc/noip
    $ sudo cp noip_conf /etc/noip
    $ sudo chmod 600 /etc/noip/noip_conf
    ```

2. Make sure `noip.sh` has execution permissions and copy it to the local directory for user binaries: 

    ```
    $ chmod a+x noip.sh
    $ sudo cp noip.sh /usr/local/bin
    ```

3. To execute the script periodically, register it on cron:

    ```
    $ sudo crontab -e
    ```

    A text editor will be opened. For example, to run the program every 5 minutes, write the next line into it:

    ```
    */5 * * * * /usr/local/bin/noip.sh
    ```

    Save this file and exit. The application is now installed.

- To run the script once, simply run:

    ```
    $ noip.sh
    ```

- To see the log, run:

    ```
    $ grep "noip:" /var/log/messages
    ```

## License

Copyright © 2015-2016 Victor Manuel Fernandez-Castro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
