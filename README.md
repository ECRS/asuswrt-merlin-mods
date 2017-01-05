## Steps taken to get environment setup (Ubuntu 16.04):
1. Install packages:
    apt-get install autoconf automake bash bison bzip2 diffutils file flex m4 g++ gawk groff-base libncurses-dev libtool libslang2 make patch perl pkg-config shtool subversion tar texinfo zlib1g zlib1g-dev git-core gettext libexpat1-dev libssl-dev cvs gperf unzip python libxml-parser-perl gcc-multilib gconf-editor libxml2-dev g++ g++-multilib gitk libncurses5 mtd-utils libncurses5-dev libstdc++6-4.7-dev libvorbis-dev git autopoint autogen sed build-essential intltool libelf1:i386 libglib2.0-dev lib32z1-dev lib32stdc++6
    
2. Remove packages:
    sudo apt-get remove automake

3. Install automake1.11
    wget http://mirrors.kernel.org/ubuntu/pool/universe/a/automake1.11/automake1.11_1.11.6-3_all.deb
    sudo dpkg -i automake1.11_1.11.6-3_all.deb

4. Checkout:
    cd ~
    git clone https://github.com/RMerl/asuswrt-merlin.git
    mkdir ~/asuswrt-merlin/release/ecrs
    cd ~/asuswrt-merlin/release/ecrs
    git clone https://github.com/ECRS/asuswrt-merlin-mods.git .

5. Symlink build tools
    sudo ln -s ~/asuswrt-merlin/tools/brcm /opt/brcm
    sudo ln -s ~/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3 /opt/brcm-arm

6. Add to ~/.bashrc
    export PATH=$PATH:/opt/brcm/hndtools-mipsel-linux/bin:/opt/brcm/hndtools-mipsel-uclibc/bin:/opt/brcm-arm/bin

7. Encoutered error when building:
    cd libxml2 && \
    CC=mipsel-uclibc-gcc AR=mipsel-uclibc-ar RANLIB=mipsel-uclibc-ranlib LD=mipsel-uclibc-ld CFLAGS="-Os -Wall -DLINUX26 -DCONFIG_BCMWL5 -DDEBUG_NOISY -DDEBUG_RCTEST -pipe -DBCMWPA2 -funit-at-a-time -Wno-pointer-sign -mtune=mips32r2 -mips32r2 -DRTCONFIG_NVRAM_64K  -DLINUX_KERNEL_VERSION=132630 " LDFLAGS=-ldl \
    ././configure --host=mipsel-linux --build= --prefix=/usr --without-python --disable-dependency-tracking
    configure: WARNING: unrecognized options: --disable-dependency-tracking
    ././configure: line 2256: syntax error near unexpected token `config.h'
    ././configure: line 2256: `AM_CONFIG_HEADER(config.h)'
    Makefile:3599: recipe for target 'libxml2/stamp-h1' failed

    FIXED BY: (https://bbs.archlinux.org/viewtopic.php?id=161452)
        cd /home/asus/asuswrt-merlin/release/src/router/libxml2
        libtoolize --force
        aclocal
        autoheader
        automake --force-missing --add-missing
        autoconf

8. Encoutered error when building RT-AC68U:
    checking for intltool >= 0.35.0... ./configure: line 18759: intltool-update: command not found
     found
    configure: error: Your intltool is too old.  You need intltool 0.35.0 or later.
    Makefile:4061: recipe for target 'avahi-0.6.31-configure' failed
    make[4]: *** [avahi-0.6.31-configure] Error 1
    make[4]: Leaving directory '/home/asus/asuswrt-merlin/release/src/router'
    Makefile:4058: recipe for target 'avahi-0.6.31/Makefile' failed
    
    FIXED BY: (https://ubuntuforums.org/showthread.php?t=1080147&p=8334230#post8334230)
        sudo apt-get install intltool

## Steps taken to get environment setup (Linux Mint 13):

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




## How to include stock scripts in the firmware
<pre>
[10/19/16 11:05:42] <@RMerlin> astclair: Implement your change in your fork, and just keep updating your fork from the upstream repo
[10/19/16 11:06:05] <@RMerlin> If your changes are too exxtensive, then implement them as a diff that you can patch on top of the repo
[10/19/16 11:52:56] <astclair> @RMerlin, I think your fork/diff solution will be appropriate for the modifiations I need to make.
[10/19/16 11:53:17] <@RMerlin> It's how I deal with miniupnpd
[10/19/16 11:53:40] <astclair> However, I'm having issues finding the appropriate time in the Make process to place these custom scripts into mipsel-uclibc/target/jffs/scripts
[10/19/16 11:53:59] <@RMerlin> astclair: Put your changes in rom/Makefile
[10/19/16 11:54:09] <@RMerlin> IT's where I put mine when I need to add new static files
[10/19/16 11:54:49] <@RMerlin> Then, modify rc/jffs to symlink to the /rom files at mount time
[10/19/16 11:55:12] <@RMerlin> That way, firmware upgrades will always be using the newer version
[10/19/16 11:56:20] <@RMerlin> The /jffs/scripts is not part of the filesystem image, scripts is created by rc with mkdir
[10/19/16 12:01:54] <astclair> @RMerlin, I see no rc/jffs currently. So, I need to essentially: "mkdir rom/jffs; ln -s rom/jffs rc/jffs;" ? I'm not certain what rc actually is, but it seems like just dropping a new dir/symlink in there isn't enough.
[10/19/16 12:02:09] <@RMerlin> No.
[10/19/16 12:02:20] <@RMerlin> I'm talking about router/rc/jffs.c - the source code.
[10/19/16 12:02:45] <@RMerlin> scripts does not exist in the firmware image, it's created by the firemware at runtime
[10/19/16 12:02:46] <astclair> I only see a jffs2.c, is that the same?
[10/19/16 12:02:50] <@RMerlin> Yes
[10/19/16 12:05:17] <astclair> I see what you're saying now. Wouldn't that remove the ability to add scripts via ssh, given that /jffs -> /rom/jffs ?
[10/19/16 12:11:42] <@RMerlin> Don't symlink the directory, just your scripts
[10/19/16 12:11:57] <@RMerlin> It will mean that these specific scripts won't be user-customizable however.
[10/19/16 12:12:34] <@RMerlin> The problem with copying instead of symlinking is you will override any user changes
[10/19/16 12:12:57] <@RMerlin> And only copying if it doesn't exist means you cannot upgrade it
[10/19/16 12:23:22] <astclair> The only scripts I could see a potential need for adding post-imaging woudln't be in these I'm including.
[10/19/16 12:29:23] <@RMerlin> Them just symlink them to the copies in /rom
[10/19/16 12:29:35] <@RMerlin> Worst case scenario, you can still bind mount on top of them
[10/19/16 12:30:05] <astclair> Yeah looks fairly simple once you point me in the right direction.
[10/19/16 12:30:45] <astclair> AFter the mkdir of jffs/scripts, I should jsut be able to symlink("/jffs/scripts/services-start", "/rom/jffs/services-start"), given that I provide jffs/services-start in the rom dir
[10/19/16 12:34:12] <@RMerlin> Exactly.  And to include the files in the image, adjust rom/Makefile
[10/19/16 12:34:20] <@RMerlin> See what I did there for the recent modules.conf change for example
[10/19/16 12:35:33] <@RMerlin> Tho in that case it was a copy to etc, so not exactly a good example
[10/19/16 12:36:51] <@RMerlin> Commit 94b4181e8c77cf753593ed305c4eba3c0bb550d9 is a better example
[10/19/16 12:37:29] <@RMerlin> cp -f others/dh2048.pem  $(INSTALLDIR)/rom/dh2048.pem
[10/19/16 12:37:50] <@RMerlin> So, have your scripts in others/ and symlink from /rom/yourscript to /jffs/scripts/yourscript
[10/19/16 12:37:59] <@RMerlin> Symlink must be done by rc/jffs2.c
</pre>


## When adding new NVRAM values
1. Also add the value to jffs/nvram-save/nvram-ecrs.ini
2. Also add the value to nvram/setDefaults.sh
