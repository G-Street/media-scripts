# Scripts for our Media directory for our Home Server

These scripts initially began their early life in late 2019, and are miscellaneous in nature, but all help to manage the home server which we had at G. Street.  Since moving house, I (Jake) still use these on my home server.

See also: [`filmls`](https://github.com/jakewilliami/scripts/tree/master/rust/filmls).

## Accessing Jail via SSH

This Jail is locatable at `192.168.1.203` via port `24`.  I haven't yet figured out how to get to the Jail via SSH on this IP address.  However, if you `ssh <username>@192.168.1.100` (to get to the main server) and run `jls` in the shell, you can get the Jail ID:
```
freenas% jls
   JID  IP Address      Hostname                      Path
     1                  Converter                     /mnt/Primary/iocage/jails/converter/root
     2                  plex                          /mnt/Primary/iocage/jails/plex/root
     3                  qbittorrent                   /mnt/Primary/iocage/jails/qbittorrent/root
     7                  ACME                          /mnt/Primary/iocage/jails/ACME/root
     4                  computation                   /mnt/Primary/iocage/jails/computation/root
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
sudo jexec $(jls | awk '/computation/ {print $1}') /usr/local/bin/bash
```

Sometimes `/usr/local/bin/bash` will not work, as it will not always be installed on the jail.  In those cases, just use `/bin/tcsh`; it's no different from using a 20-year-old Apple computer.  E.g.,
```bash
sudo jexec $(jls | awk '/computation/ {print $1}') /bin/tcsh
pkg install bash
```

## Format of Plex Database
See [here](plex/format.md).

## Setting up [`bw_plex`](https://github.com/Hellowlol/bw_plex)

First you will need to install some dependencies manually for FreeNAS:
```bash
wget https://versaweb.dl.sourceforge.net/project/cmusphinx/sphinxbase/5prealpha/sphinxbase-5prealpha.tar.gz
tar xvzf sphinxbase-5prealpha.tar.gz
wget https://versaweb.dl.sourceforge.net/project/cmusphinx/pocketsphinx/5prealpha/pocketsphinx-5prealpha.tar.gz
tar xvzf pocketsphinx-5prealpha.tar.gz
cd sphinxbase-5prealpha/
./autogen.sh
./configure
make
make install
cd ../pocketsphinx-5prealpha/
./configure
make
make install
pkg install python3 spy37-pip git lapack gcc libstdc++_stldoc_4.2.2 fortran-utils py37-wheel py37-llmvlite py37-numba py37-matplotlib py37-sqlite3 pocketsphinx sphinx3 pulseaudio swig30 py37-opencv libsndfile automake libtool bison
ln -s /usr/local/bin/swig3.0 /usr/local/bin/swig
pip install Pillow wheel SpeechRecognition pytesseract sphinx PocketSphinx
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
to get your authorisation token.  Put this into the configurating file, along with the server's web address, and `bw_plex` *should* be working.  Probably the command you want to run is `bw_plex watch`.  **Note:** this only works with admin accounts!  I tried with my account and it told me "access denied" (error code 401).  Upon trying with the main explosivecrayons account, it worked.  While `bw_plex watch` is running, you can start Plex on any device and as you watch, a show will be assessed for title sequences &c.

## Setting up Julia
```bash
JL_VERSION="1.5.2" # or: env JL_VERSION="1.5.2" if using csh/tcsh
pkg install git gcc gmake cmake pkgconf gsed
cd /tmp/

# option one
git clone https://github.com/JuliaLang/julia --branch v${JL_VERSION}
cd julia && gmake

# option two
wget https://github.com/JuliaLang/julia/releases/download/v${JL_VERSION}/julia-${JL_VERSION}-full.tar.gz
tar xzvf julia-${JL_VERSION}-full.tar.gz
gsed -i '14s/^/LDFLAGS=-L\/usr\/local\/lib\n/' julia-${JL_VERSION}/Make.inc
gsed -i '15s/^/CPPFLAGS=-I\/usr\/local\/include\n/' julia-${JL_VERSION}/Make.inc
cd julia-${JL_VERSION} && gmake
```

## In case of `ffmpeg` issues

I had some very strange issues occur with using `ffmpeg` in `for` loops.  I ended up [fixing this](https://github.com/G-Street/media-scripts/commit/65b643c) with, instead of 
```bash
ffmpeg -i ...
```
using ```bash
```
< /dev/null ffmpeg -nostdin -i ...
```
It took me a very long time to figure this out.

## In case of memory issues in jails

```
git gc --aggressive --prune=now || rm -f .git/objects/*/tmp_* && rm -f .git/objects/*/.tmp-*
```

## Benchmark comparisons between [`countMedia`](bash/countMedia) and [`filmls`](https://github.com/jakewilliami/scripts/tree/master/rust/filmls)

I used [`hyperfine`](https://github.com/sharkdp/hyperfine) for these benchmarks.

### Films

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `countMedia -f` | 174.6 ± 9.9 | 160.7 | 194.9 | 4.63 ± 0.45 |
| `filmls -f` | 37.7 ± 3.0 | 33.5 | 46.3 | 1.00 |

### Series

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `countMedia -s` | 217.9 ± 9.0 | 205.8 | 232.8 | 2.90 ± 0.28 |
| `filmls -s` | 75.2 ± 6.5 | 65.7 | 89.5 | 1.00 |
