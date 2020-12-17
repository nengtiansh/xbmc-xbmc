#cc.sh
curdir=`pwd`
cd tools/depends/
make distclean
make -C target/binary-addons distclean clean
cd $curdir
make -C tools/depends/target/cmakebuildsys distclean
cd $curdir/build
make clean
