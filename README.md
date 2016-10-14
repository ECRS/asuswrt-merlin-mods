Steps taken to get environment setup:

1. sudo apt-get install bison flex g++ g++-4.4 g++-multilib gawk gcc-multilib gconf-editor gitk lib32z1-dev libncurses5 libncurses5-dev libstdc++6-4.4-dev libtool m4 pkg-config zlib1g-dev gperf lib32z1-dev libelf1:i386
2. sudo apt-get install libmpc2:i386
3. sudo apt-get install automake
4. sudo apt-get install autopoint
5. sudo apt-get install gettext
6. sudo apt-get install libgtk2.0-dev
7. Add the following to customize.sh:
    cd /home/asus/asuswrt-merlin/release/src/router/nano
    autoreconf --force --install
8. sudo ln -s $HOME/asuswrt-merlin/tools/brcm /opt/brcm
9. export PATH=$PATH:/opt/brcm/hndtools-mipsel-linux/bin:/opt/brcm/hndtools-mipsel-uclibc/bin
10. Add the following line to ~/.bashrc:
    export PATH=$PATH:/opt/brcm/hndtools-mipsel-linux/bin:/opt/brcm/hndtools-mipsel-uclibc/bin
11. sudo mkdir -p /media/ASUSWRT/
12. sudo ln -s $HOME/asuswrt-merlin /media/ASUSWRT/asuswrt
