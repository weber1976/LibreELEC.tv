# LibreELEC PMP Build setup

In order to get LibreELEC with PMP building on Ubuntu 16.04 amd64 (Possibly other releases too) there are a few requirements that have to be made after a normal 16.04 amd64 install.

Follow these steps to get the build env setup.

As root run these commands:

`dpkg --add-architecture i386`
`apt-get clean all ; apt-get update`
`apt-get install build-essential wget bc gawk gperf zip unzip lzop xsltproc openjdk-9-jre-headless libncurses5-dev texi2html libexpat1 gcc-multilib libexpat1-dev:i386 libfreetype6:i386 libexpat1-dev libfreetype6-dev`

That should enable the host to build PMP Embedded and LibreELEC.
