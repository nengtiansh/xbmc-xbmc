export ANDROID_SDK=/home/share/android-sdk
export ANDROID_NDK=/home/share/android-sdk/ndk/20.1.5948944
#export CompilerDir=/home/lei/kodi/android-tools/arm-linux-androideabi-vanilla/android-24
export CompilerDir=/home/lei/kodi/android-tools/aarch64-linux-android-vanilla/android-21
export KodiPrefix=/home/lei/kodi/xbmc-depends
export KodiTarball=$KodiPrefix/xbmc-tarballs
avlc_checkfail()
{
    if [ ! $? -eq 0 ];then
        echo "$1"
        exit 1
    fi
}
set -e
curdir=`pwd`
if [ ! -d $CompilerDir ]; then
   echo "compiler ..."
   cd $ANDROID_NDK/build/tools
   #./make-standalone-toolchain.sh --install-dir=$CompilerDir --platform=android-24 --toolchain=arm-linux-androideabi
   ./make-standalone-toolchain.sh --install-dir=$CompilerDir --platform=android-21 --toolchain=aarch64-linux-android
fi
avlc_checkfail "compiler fail"
cd $curdir/..
if [ ! -d "download" ]; then
   git clone git@gitee.com:nengtiansh/downloadxbmc.git download
fi
if [ ! -f $KodiTarball/cmake-3.12.2.tar.gz ]; then
   cat download/xbmc-tarball.tgz.* |tar zxv
fi
avlc_checkfail "decompression fail"
cd $curdir/tools/depends
./bootstrap
#./configure --host=arm-linux-androideabi --with-sdk-path=$ANDROID_SDK --with-ndk-path=$ANDROID_NDK --with-toolchain=$CompilerDir --prefix=$KodiPrefix
./configure --host=aarch64-linux-android --with-sdk-path=$ANDROID_SDK --with-ndk-path=$ANDROID_NDK --with-toolchain=$CompilerDir --prefix=$KodiPrefix
avlc_checkfail "configure fail"
make -j8
avlc_checkfail "make fail"
cd $curdir
echo "build add ons"
make -j8 -C tools/depends/target/binary-addons
avlc_checkfail "make addons fail"
echo "build kodi"
make -C tools/depends/target/cmakebuildsys
avlc_checkfail "make kodi cmake fail"
cd $curdir/build
make -j8
avlc_checkfail "build kodi  fail"
make apk
avlc_checkfail "build apk  fail"
