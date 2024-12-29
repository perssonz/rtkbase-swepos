# RTKBase Swepos

Utilities to collect and postprocess [RTKBase](https://github.com/Stefal/rtkbase) observations against the [Swepos](https://www.lantmateriet.se/en/geodata/gps-geodesy-and-swepos/swepos/) reference stations. The intended use is for positioning and continuous monitoring of RTK base stations. Access to Swepos daily observation files is free but requires [registration](https://swepos.lantmateriet.se/register.aspx). I have also written a small [guide](https://persson.tech/2024/12/29/egen-gnss-rtk-basstation/) (in swedish) for setting up an RTK base station.

## Features

* Downloads observation files from RTKBase base station
* Downloads observation files from selected Swepos reference station for the same date
* Runs rtklib's rnx2rtkp for positioning
* Saves the result to a text file

## Usage

Dependencies: [podman](https://podman.io/docs/installation)

Clone this repo

    git clone https://github.com/perssonz/rtkbase-swepos.git

Run the script

    ./get_postprocess_in_container.sh -u <swepos username> -p <swepos password> -s <swepos reference station name, e.g. 0SIB0SWE_S> --rtkbase-hostname <hostname/IP-address of base station>

Positions per date are output to ./positions.txt.

## License

[MIT](/LICENSE)

Dependencies:
* [RTKLIB](https://github.com/tomojitakasu/RTKLIB), BSD-2-Clause
* [RNXCMP](https://terras.gsi.go.jp/ja/crx2rnx.html), [License](https://terras.gsi.go.jp/ja/crx2rnx/LICENSE.txt)
* [sshpass](https://sourceforge.net/projects/sshpass/), GPLv2
* [wget](https://www.gnu.org/software/wget/), GPLv3
* [rsync](https://rsync.samba.org/), GPLv3
* [unzip](https://infozip.sourceforge.net/UnZip.html), [Info-ZIP License](https://infozip.sourceforge.net/license.html)
* [debian](https://debian.org), [DFSG](https://www.debian.org/social_contract.en.html#guidelines)
