#!/bin/bash

if [ -z "$DISPLAY" ]; then
	export DISPLAY=:0.0
fi  

if ! $(glxinfo | grep -q "18.3"); then
	if ! $(glxinfo | grep -q "18.2"); then
		echo "You must install at least Mesa 18.2.0"
		exit 0
	fi
fi

if ! [ -x "$(command -v wine)" ]; then
	echo "You must install wine"
	exit 0
fi

if [[ $# -eq 0 ]] ; then
	echo "Usage: cemutil.sh cemu.zip cemuhook.zip installdir(optional)"
	exit 0
else
	if [ ! -f "$1" ]; then
		echo "cemu zip doesn't exist"
		exit 0
	fi
	if [ ! -f "$2" ]; then
		echo "cemuhook zip doesn't exist"
		exit 0
	fi
fi

if [[ "$3" != "" ]]; then
	INSTDIR="$3"
else
	INSTDIR=$HOME/.cemu
fi

mkdir -p $INSTDIR
bsdtar -xf "$1" -s'|[^/]*/||' -C $INSTDIR
unzip -q -o "$2" -d $INSTDIR

cat > LaunchCEMU << EOF1
#!/bin/bash
export WINEPREFIX="$(realpath $INSTDIR)/wine"
export WINEDLLOVERRIDES="mscoree=;mshtml=;dbghelp.dll=n,b"

if [ -z `winetricks list-installed|grep vcrun2015` ]; then
  if [ -n "`whereis zenity|grep bin`" ]; then
    zenity --info  --title 'Cemu' --text 'Installing wine dependencies.\n\nThe process may take a few minutes'
  fi
  winetricks -q vcrun2015
  winetricks settings win7
fi
cd $(realpath $INSTDIR)
mesa_glthread=true vblank_mode=0 WINEESYNC=0 wine $(realpath $INSTDIR)/Cemu.exe "\$@"
EOF1
chmod +x LaunchCEMU

cat > LaunchCEMUgcn3BOTW << EOF1
#!/bin/bash
export WINEPREFIX="$(realpath $INSTDIR)/wine"
export WINEDLLOVERRIDES="mscoree=;mshtml=;dbghelp.dll=n,b"

if [ -z `winetricks list-installed|grep vcrun2015` ]; then
  if [ -n "`whereis zenity|grep bin`" ]; then
    zenity --info  --title 'Cemu' --text 'Installing wine dependencies.\n\nThe process may take a few minutes'
  fi
  winetricks -q vcrun2015
  winetricks settings win7
fi
cd $(realpath $INSTDIR)
R600_DEBUG=nohyperz mesa_glthread=true vblank_mode=0 WINEESYNC=0 wine $(realpath $INSTDIR)/Cemu.exe "\$@"
EOF1
chmod +x LaunchCEMUgcn3BOTW

echo "Successfully installed to $(realpath $INSTDIR)"
echo "You may now run CEMU with CEMULaunch written in this directory"
echo "You may place CEMULaunch anywhere, and even pass arguments to it just like Cemu.exe on Windows"
echo "Note: When launching there may be a WxWidgets error. Press Cancel; this is normal from cemuhook"
echo "Note2: gcn3 (radeon 300-500 series) users should use the gcn3BOTW script for launching BOTW"
