#!/bin/bash

if [ -z "$DISPLAY" ]; then
	export DISPLAY=:0.0
fi  

# help function:
function printhelp {
	echo "usage examples: Download latest public cemu + cemuhook and install to ~/.cemu (default):"
	echo "./cemutil.sh -a"
	echo "Use local zips and install to ~/Documents/cemu:"
	echo "./cemutil.sh -c cemu.zip -h cemuhook.zip -i ~/Documents/cemu/"
	exit 1
}

function downloadlatest {
	echo "Downloading latest cemu"
	wget -q --show-progress -O cemutemp.zip $(curl -s http://cemu.info |grep .zip |awk -F '"' {'print $2'})
	echo "Downloading latest cemuhook"
	wget -q --show-progress -O cemuhooktemp.zip $(curl -s https://cemuhook.sshnuke.net |grep .zip |awk -F '"' NR==2{'print $2'})
	return
}

#Check installed software
declare -a reqsw=("wine" "bsdtar" "unzip" "glxinfo" "curl" "wget" "winetricks")
for i in "${reqsw[@]}"
do
	if ! [ -x "$(command -v $i)" ]; then
		echo "You must install $i"
		exit 1
	fi
done

if ! $(glxinfo | grep -q "Mesa 18.3"); then
	if ! $(glxinfo | grep -q "Mesa 18.2"); then
		echo "You must install at least Mesa 18.2.0"
		exit 1
	fi
fi

if ! $(glxinfo | grep -q "LLVM 8"); then
	if ! $(glxinfo | grep -q "LLVM 7"); then
		echo "You must install Mesa built with at least LLVM 7"
		exit 1
	fi
fi

if ! $(glxinfo | grep -q "4.5 (Compat"); then
	echo "Your hardware doesn't support the required OpenGL version."
	echo "You may attempt using MESA_GL_VERSION_OVERRIDE=4.4COMPAT in the LaunchCEMU script."
	echo "This isn't officially supported, and may cause heavy glitches or not work. Proceeding as usual..."
fi

#Check for args
if [[ ! $@ =~ ^\-.+ ]]
then
	printhelp;
fi

#Handle args
while getopts ":c:h:ai:" opt; do
	case ${opt} in
		c )
			cemuzip=$OPTARG
			if [ ! -f "$cemuzip" ]; then
				echo "cemu zip doesn't exist"
				exit 1
			fi
			;;
		h )
			cemuhookzip=$OPTARG
			if [ ! -f "$cemuhookzip" ]; then
				echo "cemuhook zip doesn't exist"
				exit 1
			fi
			;;
		a )
			downloadlatest
			;;
		i )
			instdir=$OPTARG
			;;
		\? )
			printhelp
			;;
		: )
			echo "Invalid option: $OPTARG requires an argument" 1>&2
			printhelp
			;;
	esac
done
shift $((OPTIND -1))

#Set opts if unset
if [[ "$instdir" == "" ]]; then
	instdir=$HOME/.cemu
fi
if [[ "$cemuzip" == "" ]]; then
	cemuzip=cemutemp.zip
fi
if [[ "$cemuhookzip" == "" ]]; then
	cemuhookzip=cemuhooktemp.zip
fi

#Extract zips
echo "Extracting zips"
mkdir -p $instdir
bsdtar -xf "$cemuzip" -s'|[^/]*/||' -C $instdir
unzip -q -o "$cemuhookzip" -d $instdir
#Delete downloaded zips if applicable
if [ -f "cemutemp.zip" ]; then
	rm -rf cemutemp.zip
	rm -rf cemuhooktemp.zip
fi

#Create launch scripts
cat > LaunchCEMU << EOF1
#!/bin/bash
export WINEPREFIX="$(realpath $instdir)/wine"
export WINEDLLOVERRIDES="mscoree=;mshtml=;dbghelp.dll=n,b"

winetricks settings win7
cd $(realpath $instdir)
mesa_glthread=true vblank_mode=0 WINEESYNC=0 wine $(realpath $instdir)/Cemu.exe "\$@"
EOF1
chmod +x LaunchCEMU

cat > LaunchCEMUgcn3BOTW << EOF1
#!/bin/bash
export WINEPREFIX="$(realpath $instdir)/wine"
export WINEDLLOVERRIDES="mscoree=;mshtml=;dbghelp.dll=n,b"

winetricks settings win7
cd $(realpath $instdir)
R600_DEBUG=nohyperz mesa_glthread=true vblank_mode=0 WINEESYNC=0 wine $(realpath $instdir)/Cemu.exe "\$@"
EOF1
chmod +x LaunchCEMUgcn3BOTW

echo "Successfully installed to $(realpath $instdir)"
echo "You may now run CEMU with LaunchCEMU written in this directory"
echo "You may place LaunchCEMU anywhere, and even pass arguments to it just like Cemu.exe on Windows"
echo "Note: When launching there may be a WxWidgets error. Press Cancel; this is normal from cemuhook"
echo "Note2: gcn3 (radeon 300-500 series) users should use the gcn3BOTW script for launching BOTW"
