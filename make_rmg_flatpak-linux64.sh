#!/bin/bash
# Script that was used to build this package. Enjoy
# make_flatpak-linux.sh AppName /AppDirectory executable.exe # exe from AppDirectory/App.exe

# FEZ is a linux program 

# ./make_fez_flatpak-linux.sh fez fez/ FEZ ;#FEZ is a script in this folder which is linux

# also we are not copying wine 
# don't use this for wine but for linux flatpaks


# Icon: 1st install the program using wine 
# then copy the icon to the 
# cp '~/.local/share/icons/hicolor/256x256/apps/0DE1_FontLab 7.0.png' FontLab7/icon.png

# before running this program, also remove Spaces in folder and exe names, 
# example Fontlab\ 7 to Fontlab7 and Fontlab\ 7.exe to Fontlab7.exe
# This wine is i386 with 5.0.3 stable built using 
# install sdk
##flatpak install flathub org.freedesktop.Platform/i386/18.08 org.freedesktop.Sdk//18.08
##flatpak install flathub org.freedesktop.Platform/i386/18.08 org.freedesktop.Sdk/i386/18.08
#get json file from 
#https://github.com/johnramsden/pathofexile-flatpak/blob/master/ca.johnramsden.pathofexile.json

#build to create files (wine 32 bit)
#flatpak-builder build-dir ca.johnramsden.pathofexile.json
#copy the files directory from build-dir to current directory


NAME="$1"; shift
APP="$1"; shift
EXE="$1"; shift

NICE_NAME=$(echo $(echo "$NAME" | sed 's/[A-Z]/ \0/g'))
DOT_NAME=$(echo "$NICE_NAME" | tr " " . )
WINEEXE="/app/bin/wine"
ARCH="x86_64"

mkdir -p target/package/files/bin
mkdir -p target/package/files/lib
mkdir -p target/package/export/share/applications
mkdir -p target/package/export/share/icons/hicolor/128x128/apps/
mkdir -p target/\[flatpak-linux64\]$DOT_NAME

cat << EOF > target/package/files/bin/run.sh
#!/bin/bash


if [ "\$1" == "bash" ] ; then
  bash

# on 1st run, copy Project64 to ~/.local/share/flatpak-linux64/$NAME/
elif [ ! -f ~/.local/share/flatpak-linux64/$NAME/1st-run-done.txt ];
     then
     cp -r /app/rmg/ ~/.local/share/flatpak-linux64/$NAME/ && \
     touch ~/.local/share/flatpak-linux64/$NAME/1st-run-done.txt && \
     chmod a+rwx ~/.local/share/flatpak-linux64/$NAME/rmg -R
     cd ~/.local/share/flatpak-linux64/$NAME/rmg && \
     ./RMG
else
 cd ~/.local/share/flatpak-linux64/$NAME/rmg && \
 "./RMG"
	exit 0

fi
EOF

cat << EOF >target/package/metadata
[Application]
name=org.flatpakwine64.$NAME
runtime=org.kde.Platform/$ARCH/5.15
command=run.sh

[Context]
features=devel;multiarch;
shared=network;ipc;
sockets=x11;pulseaudio;
devices=all;
filesystems=xdg-documents;~/Games;~/games;~/.local/share/flatpak-linux64/$NAME:create
EOF


cat << EOF >target/\[flatpak-linux64\]$DOT_NAME/install.sh
#!/bin/bash
# Installs game bundle for user.
# You can delete everything after installation.

DIR=\$(dirname "\$0")
set -ex
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
flatpak --user install -y --app --bundle "\$DIR/$NAME.flatpak" || echo "Installation failed. Check if you have Flatpak properly configured. See http://flatpak.org/ for more info."
EOF

cat << EOF >target/\[flatpak-linux64\]$DOT_NAME/uninstall.sh
#!/bin/bash
# You can as well use package manager to uninstall the game
echo You can as well use package manager to uninstall the game

set -ex
flatpak --user uninstall org.flatpakwine64.$NAME
EOF

cat << EOF >target/\[flatpak-linux64\]$DOT_NAME/run.sh
#!/bin/bash
set -ex
flatpak run org.flatpakwine64.$NAME \$@
EOF

cat << EOF >target/package/export/share/applications/org.flatpakwine64.$NAME.desktop
[Desktop Entry]
Version=1.0
Name=$NICE_NAME
Exec=run.sh
Icon=org.flatpakwine64.$NAME
StartupNotify=true
Terminal=false
Type=Application
Categories=Game;
EOF


set -ex
[ -e "$APP"/icon.png ] && cp "$APP"/icon.png target/package/export/share/icons/hicolor/128x128/apps/org.flatpakwine64.$NAME.png
cp -rd "$APP" target/package/files/
#cp -r $WINE/bin $WINE/$LIB $WINE/share target/package/files/
# we are not copying wine as this is a linux program
#cp -rp ../files/ target/package/

chmod +x target/package/files/bin/run.sh
chmod +x target/\[flatpak-linux64\]$DOT_NAME/install.sh
chmod +x target/\[flatpak-linux64\]$DOT_NAME/uninstall.sh
chmod +x target/\[flatpak-linux64\]$DOT_NAME/run.sh
cp "$0" target/package/files/flatpak-make

flatpak build-export target/repo target/package
flatpak build-bundle --arch=$ARCH target/repo target/\[flatpak-linux64\]$DOT_NAME/$NAME.flatpak org.flatpakwine64.$NAME


