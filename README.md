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
```
ssh <username>@192.168.1.100
sudo jexec $(jls | awk '/Converter/ {print $1}') /usr/local/bin/bash
```

Sometimes `/usr/local/bin/bash` will not work.  In those cases, just use `/bin/tcsh`; it's no different from using a 20-year-old Apple computer.
