#!/bin/bash

if (( $EUID == 0 )); then
	echo "Do not run as root."
	exit 1
fi

if [ -z "$DISPLAY" ]; then
	export DISPLAY=:0.0
fi

# help function:
function printhelp {
	echo "usage examples:"
	echo "Download latest working cemu + cemuhook + graphic packs and install to ~/.cemu (default):"
	echo "./cemutil.sh -a"
	echo "Use local zips and install to ~/Documents/cemu:"
	echo "./cemutil.sh -c cemu.zip -h cemuhook.zip -g graphicpacks.zip -i ~/Documents/cemu"
	exit 1
}

function downloadlatest {
	echo "Downloading latest cemu"
	#wget -q --show-progress -O cemutemp.zip $(curl -s http://cemu.info |grep .zip |awk -F '"' {'print $2'})
	wget -q --show-progress -O cemutemp.zip http://cemu.info/releases/cemu_1.15.0.zip
	echo "Downloading latest cemuhook"
	wget -q --show-progress -O cemuhooktemp.zip $(curl -s https://cemuhook.sshnuke.net |grep .zip |awk -F '"' NR==2{'print $2'})
	echo "Downloading latest graphics packs"
	wget -q --show-progress -O gfxpacktemp.zip https://github.com$(curl https://github.com/slashiee/cemu_graphic_packs/releases |grep graphicPacks |awk -F '"' NR==1{'print $2'})
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

function checkgfxver {
	echo "Checking graphics packages are new enough. To skip this check (on Nvidia for instance), run with -f flag."
	if ! $(glxinfo | grep -q -e 'Mesa 18.2' -e 'Mesa 18.3' -e 'Mesa 18.4' -e 'Mesa 19'); then
		echo "You must install at least Mesa 18.2.0"
		exit 1
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
	return
}

#Check for args
if [[ ! $@ =~ ^\-.+ ]]
then
	printhelp;
fi

#Handle args
while getopts ":c:h:g:afi:" opt; do
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
		g )
			gfxpackzip=$OPTARG
			if [ ! -f "$gfxpackzip" ]; then
				echo "graphic packs zip doesn't exist"
				exit 1
			fi
			;;
		a )
			downloadlatest
			;;
		f )
			skipgfxcheck=1
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

#check gfx package vers
if [[ "$skipgfxcheck" == "" ]]; then
	checkgfxver
fi

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
if [[ "$gfxpackzip" == "" ]]; then
	gfxpackzip=gfxpacktemp.zip
fi

#Extract zips
echo "Extracting zips"
mkdir -p $instdir


#Unpack downloaded zips if applicable
if [ -f "$cemuzip" ]; then
	bsdtar -xf "$cemuzip" -s'|[^/]*/||' -C $instdir
fi
if [ -f "$cemuhookzip" ]; then
	unzip -q -o "$cemuhookzip" -d $instdir
fi
if [ -f "$gfxpackzip" ]; then
	rm -rf ${instdir}/graphicPacks/* #remove old versions of Graphic Packs to help with major changes
	unzip -q -o "$gfxpackzip" -d ${instdir}/graphicPacks/
fi

#Delete downloaded zips if applicable
if [ -f "gfxpacktemp.zip" ]; then
	rm -rf gfxpacktemp.zip
fi
if [ -f "cemutemp.zip" ]; then
	rm -rf cemutemp.zip
fi
if [ -f "cemuhooktemp.zip" ]; then
	rm -rf cemuhooktemp.zip
fi

#Configure wine prefix
echo "Configuring new wine prefix"
export WINEPREFIX=$(realpath $instdir)/wine 
winetricks -q vcrun2015
winetricks settings win7

#Create launch scripts
cat > LaunchCEMU << EOF1
#!/bin/bash
export WINEPREFIX="$(realpath $instdir)/wine"
#for cemuhook
export WINEDLLOVERRIDES="mscoree=;mshtml=;dbghelp.dll=n,b"

cd $(realpath $instdir)
mesa_glthread=true __GL_THREADED_OPTIMIZATIONS=1 vblank_mode=0 WINEESYNC=1 wine Cemu.exe "\$@"
EOF1
chmod +x LaunchCEMU

cat > LaunchCEMUgcn3BOTW << EOF1
#!/bin/bash
export WINEPREFIX="$(realpath $instdir)/wine"
#for cemuhook
export WINEDLLOVERRIDES="mscoree=;mshtml=;dbghelp.dll=n,b"

cd $(realpath $instdir)
R600_DEBUG=nohyperz mesa_glthread=true vblank_mode=0 WINEESYNC=1 wine Cemu.exe "\$@"
EOF1
chmod +x LaunchCEMUgcn3BOTW

echo "Successfully installed to $(realpath $instdir)"
echo "You may now run CEMU with LaunchCEMU written in this directory"
echo "You may place LaunchCEMU anywhere, and even pass arguments to it just like Cemu.exe on Windows"
echo "Note: When launching there may be a WxWidgets error. Press Cancel; this is normal from cemuhook"
echo "Note2: gcn3 (radeon 300-500 series) users should use the gcn3BOTW script for launching BOTW"
echo "Note3: Cemu Hook may not be able to download the 4 required shared fonts, these can be copied from a working Windows install of Cemu"
