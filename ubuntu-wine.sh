if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0.0
fi

if ! $(lsb_release -a | grep -q -e "18.04" -e "18.10" -e "19.04" -e "19.10" -e "20.04" -e "20.10"); then
  echo "You need at least Ubuntu 18.04"
  exit 1
fi

# add i386 architecture, necessary for wine
sudo dpkg --add-architecture i386

# download wine repo key
sudo wget -nc https://dl.winehq.org/wine-builds/winehq.key

# add wine repo key
sudo apt-key add winehq.key

if $(lsb_release -a | grep -q -e "18.04"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
fi

if $(lsb_release -a | grep -q -e "18.10"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ cosmic main'
fi

if $(lsb_release -a | grep -q -e "19.04"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ disco main'
fi

if $(lsb_release -a | grep -q -e "19.10"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ eoan main'
fi

if $(lsb_release -a | grep -q -e "20.04"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'
fi

if $(lsb_release -a | grep -q -e "20.10"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ groovy main'
fi

if $(lsb_release -a | grep -q -e "21.04"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ hirsute main'
fi

if $(lsb_release -a | grep -q -e "21.10"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ impish main'
fi

if $(lsb_release -a | grep -q -e "22.04"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main'
fi

if $(lsb_release -a | grep -q -e "22.10"); then
  sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ kinetic main'
fi

sudo add-apt-repository ppa:cybermax-dexter/sdl2-backport -y

sudo apt update

# install wine-staging
sudo apt -y install --install-recommends winehq-staging

# install winetricks
sudo apt -y install winetricks

#cleanup
sudo rm -rf winehq.key
