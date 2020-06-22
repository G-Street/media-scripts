# Scripts for our Media directory for our Home Server


## Accessing Jail via SSH

This Jail is locatable at `192.168.1.203` via port `24`.  I haven't yet figured out how to get to the Jail via SSH on this IP address.  However, if you `ssh <username>@192.168.1.100` (to get to the main server) and run `jls` in the shell, you can get the Jail ID:
```
freenas% jls
   JID  IP Address      Hostname                      Path
     1                  Converter                     /mnt/Primary/iocage/jails/converter/root
     2                  plex                          /mnt/Primary/iocage/jails/plex/root
     3                  qbittorrent                   /mnt/Primary/iocage/jails/qbittorrent/root
     7                  ACME                          /mnt/Primary/iocage/jails/ACME/root
```
Then all you have to do is run
```
sudo jexec <JID> <path to desired shell>
```

For example, accessing the `Converter` jail with `bash` (because why would you use `tcsh` as is defualt for FreeNAS?), you will run
```
sudo jexec 1 /usr/local/bin/bash
```

If you wanted to make this easier for yourself, run something like this:
```bash
ssh <username>@192.168.1.100
sudo jexec $(jls | awk '/Converter/ {print $1}') /usr/local/bin/bash
```

Sometimes `/usr/local/bin/bash` will not work.  In those cases, just use `/bin/tcsh`; it's no different from using a 20-year-old Apple computer.  E.g.,
```bash
sudo jexec $(jls | awk '/plex/ {print $1}') /bin/tcsh
```

## Setting up [`bw_plex`](https://github.com/Hellowlol/bw_plex)

First you will need to install some dependencies manually for FreeNAS:
```bash
pkg install python3 spy37-pip git lapack gcc libstdc++_stldoc_4.2.2 fortran-utils py37-wheel py37-llmvlite py37-numba py37-matplotlib py37-sqlite3 phinx3 swig30 py37-opencv libsndfile
pip install Pillow wheel SpeechRecognition pytesseract
```
This took me ages to figure out, so be greatful.

Now you can (hopefully successfully) install `bw_plex`:
```bash
pip install -e git+https://github.com/Hellowlol/bw_plex.git#egg=bw_plex
```
Now, before you use `bw_plex`, you will need to create a config file.  This is usually created automatically, but if it's not, simply run
```bash
bw_plex create-config
```
In the config file, you will need your authorisation token.  The easiest way to do this is to use the python script that some beautiful human created (located in this directory at `plex_token.py`):
```bash
cd /tmp/
git clone https://gitlab.com/media-scripts/apps.git
for i in apps/plex/p3/*; do mv "${i}" /mnt/Media/Scripts/; done
```
And run 
```bash
python3 /mnt/Media/Scripts/plex_token.py
```
to get your authorisation token.  Put this into the configurating file, along with the server's web address, and `bw_plex` *should* be working.  Probably the command you want to run is `bw_plex watch`.  **Note:** this only works with admin accounts!  I tried with my account and it told me "access denied" (error code 401).  Upon trying with the main explosivecrayons account, it worked.
