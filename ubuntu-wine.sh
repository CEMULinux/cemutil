if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0.0
fi

sudo rm -rf /tmp/wine_install

sudo mkdir /tmp/wine_install

cd /tmp/wine_install

# add i386 architecture, necessary for wine
sudo dpkg --add-architecture i386

# download wine repo key
sudo wget -nc https://dl.winehq.org/wine-builds/winehq.key

# add wine repo key
sudo apt-key add winehq.key

sudo add-apt-repository ppa:cybermax-dexter/sdl2-backport

sudo apt update

sudo apt -y install libfaudio0-amd64 libfaudio0-i386 libfaudio0 

# install wine-staging
sudo apt -y install --install-recommends winehq-staging

# install winetricks
sudo apt -y install winetricks

# cleanup
sudo rm -rf /tmp/wine_install
