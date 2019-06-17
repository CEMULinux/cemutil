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

# adds repo for Ubuntu 18.04 and libfaudio0, which isn't available in the standard repo
if $(lsb_release -a | grep -q -e "18.04"); then
    sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
    sudo wget -nc https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/amd64/libfaudio0_19.04-0~bionic_amd64.deb
    sudo wget -nc https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/i386/libfaudio0_19.04-0~bionic_i386.deb
fi

# adds repo for Ubuntu 18.10 and libfaudio0, which isn't available in the standard repo
if $(lsb_release -a | grep -q -e "18.10"); then
    sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ cosmic main'
    sudo wget -nc https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Ubuntu_18.10_standard/amd64/libfaudio0_19.04-0~cosmic_amd64.deb
    sudo wget -nc https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Ubuntu_18.10_standard/i386/libfaudio0_19.04-0~cosmic_i386.deb
fi

# adds repo for Ubuntu 19.04 and libfaudio0, which isn't available in the standard repo
if $(lsb_release -a | grep -q -e "19.04"); then
    sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ disco main'
    sudo wget -nc https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_19.04/amd64/libfaudio0_19.04-0~disco_amd64.deb
    sudo wget -nc https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_19.04/i386/libfaudio0_19.04-0~disco_i386.deb
fi

# install faudio
sudo dpkg -i *.deb

sudo apt -y --fix-broken install

sudo apt update

# install wine-staging
sudo apt -y install --install-recommends winehq-staging

# install winetricks
sudo apt -y install winetricks

# vcrun2017 is recommended
winetricks vcrun2017

# cleanup
sudo rm -rf /tmp/wine_install
