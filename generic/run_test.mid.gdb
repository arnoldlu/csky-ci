./$OUT_PATH/host/csky-ci/csky_switch /dev/ttyUSB1 off
./$OUT_PATH/host/csky-ci/csky_switch /dev/ttyUSB1 on

SLEEPY=6
echo "Gonna sleep $SLEEPY seconds here"
sleep $SLEEPY
echo "Sleep done"

#Must enter /root/DebugServerConsole to execute since we need the configs
cd /root/DebugServerConsole
killall DebugServerConsole.elf > /dev/null 2>&1
./DebugServerConsole.elf -ddc -port 1025 &
cd -

echo "Gonna sleep $SLEEPY seconds here again"
sleep $SLEEPY
echo "Sleep done again"

if [ -d /tmp/rootfs_nfs ]; then
	rm -rf /tmp/rootfs_nfs
fi
mkdir -p /tmp/rootfs_nfs
if [ -f $OUT_PATH/images/rootfs.tar ]; then
	tar -xf $OUT_PATH/images/rootfs.tar -C /tmp/rootfs_nfs
fi

killall csky_serial > /dev/null 2>&1
./$OUT_PATH/host/csky-ci/csky_serial > >(tee $ROOT_PATH/test.log) &

#Must enter /output/images to execute since we need the configs
cd $OUT_PATH/images
../host/bin/csky-linux-gdb -x ./gdbinit vmlinux
cd -
