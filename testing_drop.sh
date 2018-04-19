#!/bin/bash

cd 

pwd

echo "extracting SDK.."
tar -xf  ~/SAMSUNG-6.3.0-DROP1A/OCTEONTX-SDK-6.3.0_build36.tar.gz
cd OCTEONTX-SDK 
echo "SDK extraction complete"

#this command needs the SAMSUNG-6.3.0-DROP1 to be installed in the root(~)
tar -xf ~/SAMSUNG-6.3.0-DROP1A/thunderx-tools-179.tar.bz2
echo "toolchain extraction complete"
ln -s thunderx-tools-179 tools
echo "toolchain linked"


source env-setup


gunzip ~/SAMSUNG-6.3.0-DROP1A/se2-octeontx2-6.3.0-1a.tar.gz
tar -xf  ~/SAMSUNG-6.3.0-DROP1A/se2-octeontx2-6.3.0-1a.tar


export ODP_ROOT=$THUNDER_ROOT/se2-octeontx2-6.3.0-1a

echo "building ODP"
cd $ODP_ROOT
platform/octeontx2/scripts/odp-build.sh -p $ODP_ROOT/out
echo "installing ODP"
make install

mkdir $THUNDER_ROOT/linux/cavium-rootfs/user-include


echo "copying application to user-include directory"
cp -r $ODP_ROOT/out/bin/. $THUNDER_ROOT/linux/cavium-rootfs/user-include/

cp -r $ODP_ROOT/example/cavium/pktloop/runtime/. \
$THUNDER_ROOT/linux/cavium-rootfs/user-include/

echo "copy complete"


echo "building uboot"
cd $THUNDER_ROOT
PLAT=f95 make uboot-build
echo "uboot build complete"

echo "building kernel"
cd $THUNDER_ROOT
make linux-kernel-asim
echo "building root file system"
make cavium-rootfs

echo "build complete"


echo "creating virtual disk"
cd $THUNDER_ROOT
./host/bin/create_disk.sh --disk-file thunder-disk.img

echo "Done"

cd $THUNDER_ROOT
make -C asim-dev PLAT=f95 mmc-erase
make -C asim-dev PLAT=f95 flash-erase
make -C asim-dev PLAT=f95 flash-uboot

make -C asim-dev PLAT=f95 run-uboot
