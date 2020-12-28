# Rosalie-s-Mupen-GUI_flatpak
Rosalie's Mupen GUI flatpak

You can test the flatpak, it's just Release/rmg directory inside flatpak.
```
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
git clone https://github.com/fastrizwaan/Rosalie-s-Mupen-GUI_flatpak
cd Rosalie-s-Mupen-GUI_flatpak/\[flatpak-linux64\]Rosalies_.Mupen_.G.U.I/
./install.sh
./run.sh
```

I've created a flatpak bundle from compiled binaries of Flatpak runtime sdk.
https://github.com/fastrizwaan/Rosalie-s-Mupen-GUI_flatpak

```
# flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# flatpak install flathub org.kde.Sdk/x86_64/5.15

app-id: io.github.RMG
runtime: org.kde.Platform
runtime-version: '5.15'
sdk: org.kde.Sdk
command: RMG


finish-args:
  - --socket=wayland
  - --socket=fallback-x11
  - --share=ipc
  - --share=network
  - --device=dri
  - --filesystem=host:ro
  - --filesystem=~/.config/RMG:create
  - --device=all

modules:
 
- name: RMG
  buildsystem: simple
  sources:
  - type: git
    url: https://github.com/Rosalie241/RMG
    
  build-options:
#--share=network is disliked by flatpak devs, but it allows for internet access to during build process; else multiple git clone not allwed
    build-args:
    - --share=network
  build-commands:
  - ./Source/Script/Build.sh Release 1
  - cp Bin/Release/rmg /app -r
```
After the above build, just copy the build-dir/files/rmg directory and build flatpak using `make_rmg_flatpak-linux64.sh`
