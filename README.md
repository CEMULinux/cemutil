cemutil -- a Linux CEMU install helper
===============================================================

Capabilties
===============================================================
 - Supports downloading latest cemu, cemuzips and graphic packs, then installing them to either ~/.cemu or a location of your choosing.
 - Supports using local zips for the install.
 - Creates and configures a wineprefix in the install directory, to not impact the default prefix.
 - Creates two launch scripts: one for cemu normally (with glthread and vsync flags set), and another for launching Zelda BOTW on gcn3 cards (e.g. polaris, fiji).

Running
===============================================================
Run the following commands to download and run the program to see usage capabilities:
```
wget -O ./cemutil.sh https://github.com/HengiFettlich/cemutil/raw/master/cemutil.sh && chmod +x cemutil.sh && ./cemutil.sh
```

Run the following commands to download and run the program with the '-a' flag to download latest known working Cemu, Cemu Hook and the latest Graphics Packs:
```
wget -O ./cemutil.sh https://github.com/HengiFettlich/cemutil/raw/master/cemutil.sh && chmod +x cemutil.sh && ./cemutil.sh -a
```

Run the following commands to download and run the program with the '-l' flag to download latest Cemu, Cemu Hook and the latest Graphics Packs:
```
wget -O ./cemutil.sh https://github.com/HengiFettlich/cemutil/raw/master/cemutil.sh && chmod +x cemutil.sh && ./cemutil.sh -l
```

Support
===============================================================
Go to #linux on [CEMU Discord](https://discord.gg/5psYsup)
 - If you're using an Arch based Distro, it is recommended to build wine-tkg yourself.(https://github.com/Tk-Glitch/PKGBUILDS/tree/master/wine-tkg-git)
 
 Users with Ubuntu 18.04 and later can run this command in terminal:
```
wget -O ./ubuntu-wine.sh https://github.com/HengiFettlich/cemutil/raw/master/ubuntu-wine.sh && chmod +x ubuntu-wine.sh && ./ubuntu-wine.sh
```
