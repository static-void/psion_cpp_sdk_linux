#!/bin/sh
# First patch and build gcc
SDK=`pwd`/../
tar xf gcc-3.0-psion-98r2-9-src.tar.gz
patch -p1 < gcc-3.0-psion-98r2-9-patch
mkdir $SDK/gcc-3.0-psion-98r2-9
mkdir $SDK/install/gcc_build
cd $SDK/install/gcc_build
sh $SDK/install/src/configure --prefix=$SDK/gcc-3.0-psion-98r2-9 --target=arm-epoc-pe --host=i386-pc-linux-gnu --sysroot=$SDK/epoc_cpp_sdk/epoc32
cd $SDK/install/gcc_build/bfd
make
cd $SDK/install/gcc_build/libiberty
make 
cd $SDK/install/gcc_build/opcodes
make
cd $SDK/install/gcc_build/byacc
make
cd $SDK/install/gcc_build/flex
make
cd $SDK/install/gcc_build/intl
make
cd $SDK/install/gcc_build/binutils
make install
cd $SDK/install/gcc_build/gas
make install
cd $SDK/install/gcc_build/ld
make install
cd $SDK/install/gcc_build/bison
make
cd $SDK/install/gcc_build/gcc
make LANGUAGES="c c++"
make LANGUAGES="c c++" install
cd $SDK
# gcc build is done, make some symlinks so the SDK can find stuff
ln -s arm-epoc-pe-addr2line gcc-3.0-psion-98r2-9/bin/arm-pe-addr2line 
ln -s arm-epoc-pe-c++filt gcc-3.0-psion-98r2-9/bin/arm-pe-c++filt 
ln -s arm-epoc-pe-gasp gcc-3.0-psion-98r2-9/bin/arm-pe-gasp 
ln -s arm-epoc-pe-objcopy gcc-3.0-psion-98r2-9/bin/arm-pe-objcopy 
ln -s arm-epoc-pe-size gcc-3.0-psion-98r2-9/bin/arm-pe-size
ln -s arm-epoc-pe-ar gcc-3.0-psion-98r2-9/bin/arm-pe-ar        
ln -s arm-epoc-pe-cpp gcc-3.0-psion-98r2-9/bin/arm-pe-cpp     
ln -s arm-epoc-pe-gcc gcc-3.0-psion-98r2-9/bin/arm-pe-gcc  
ln -s arm-epoc-pe-objdump gcc-3.0-psion-98r2-9/bin/arm-pe-objdump 
ln -s arm-epoc-pe-strings gcc-3.0-psion-98r2-9/bin/arm-pe-strings
ln -s arm-epoc-pe-as gcc-3.0-psion-98r2-9/bin/arm-pe-as        
ln -s arm-epoc-pe-dlltool gcc-3.0-psion-98r2-9/bin/arm-pe-dlltool 
ln -s arm-epoc-pe-ld gcc-3.0-psion-98r2-9/bin/arm-pe-ld   
ln -s arm-epoc-pe-ranlib gcc-3.0-psion-98r2-9/bin/arm-pe-ranlib  
ln -s arm-epoc-pe-strip gcc-3.0-psion-98r2-9/bin/arm-pe-strip
ln -s arm-epoc-pe-c++ gcc-3.0-psion-98r2-9/bin/arm-pe-c++       
ln -s arm-epoc-pe-g++ gcc-3.0-psion-98r2-9/bin/arm-pe-g++     
ln -s arm-epoc-pe-nm gcc-3.0-psion-98r2-9/bin/arm-pe-nm   
ln -s arm-epoc-pe-readelf gcc-3.0-psion-98r2-9/bin/arm-pe-readelf 
ln -s arm-epoc-pe-windres gcc-3.0-psion-98r2-9/bin/arm-pe-windres
# remove build and src dirs
rm -rf $SDK/install/gcc_build $SDK/install/src

# Now build the sdk2unix tools and install them
cd $SDK/install
tar xf sdk2unix-1.9.tar.gz
patch -p0 < sdk2unix-1.9-patch
cd $SDK/install/sdk2unix-1.9/helpers/bmconv-1.1.0-2
make
cp $SDK/install/sdk2unix-1.9/helpers/bmconv-1.1.0-2/src/bmconv $SDK/gcc-3.0-psion-98r2-9/bin
cd $SDK/install/sdk2unix-1.9/helpers/makesis-2.0.0/
make
cp $SDK/install/sdk2unix-1.9/helpers/makesis-2.0.0/src/makesis $SDK/gcc-3.0-psion-98r2-9/bin
cd $SDK/install/sdk2unix-1.9/helpers/petran-1.1.0/
make
cp $SDK/install/sdk2unix-1.9/helpers/petran-1.1.0/e32uid/uidcrc $SDK/gcc-3.0-psion-98r2-9/bin
cp $SDK/install/sdk2unix-1.9/helpers/petran-1.1.0/petran/petran $SDK/gcc-3.0-psion-98r2-9/bin
cd $SDK/install/sdk2unix-1.9/helpers/rcomp-7.0.1
make
cp $SDK/install/sdk2unix-1.9/helpers/rcomp-7.0.1/src/rcomp $SDK/gcc-3.0-psion-98r2-9/bin
cd $SDK/install/sdk2unix-1.9/genaif
gcc genaif.c -o genaif
cp $SDK/install/sdk2unix-1.9/genaif/genaif $SDK/gcc-3.0-psion-98r2-9/bin
cp -rp $SDK/install/sdk2unix-1.9/data/gcc539/makerules $SDK/gcc-3.0-psion-98r2-9/lib
cp $SDK/install/sdk2unix-1.9/bin/xmakesis.pl $SDK/gcc-3.0-psion-98r2-9/bin
#bin/install_epocR5_sdk ../cpp.zip `pwd`/../epoc_r5_sdk `pwd`/../gcc-3.0-psion-98r2-9
# Remove the sdk2unix install folder
rm -rf $SDK/install/sdk2unix-1.9

# Now install SDK via gnupoc (which converts files to unix format and lower cases everything etc)
unset TMP
mkdir $SDK/install/gnupoc
cp $SDK/install/cpp.zip $SDK/install/gnupoc
cd $SDK/install/gnupoc
unzip cpp.zip
mv $SDK/install/gnupoc/Cpp $SDK/install/gnupoc/epoc_cpp_sdk
cd $SDK/install/gnupoc/epoc_cpp_sdk
# Correct permissions
find . -type d -exec chmod 755 {} +
find . -type f -exec chmod 644 {} +
export EPOCROOT=$SDK/install/gnupoc/epoc_cpp_sdk
tar xf $SDK/install/gnupoc.er5.patch.011.tar.gz -C $SDK/install/gnupoc/epoc_cpp_sdk/EPOC32

# Silly hack to rename everything to lower case using zip/unzip (to avoid using perl modules)
cd $EPOCROOT/..
EPOCROOTDIR=`basename $EPOCROOT`
zip -r -0 $EPOCROOTDIR.zip $EPOCROOTDIR
rm -rf $EPOCROOTDIR
unzip -LL $EPOCROOTDIR.zip

# Get back to it
cd $SDK/install/gnupoc/epoc_cpp_sdk/epoc32
./unixifysdk.sh
make apply
patch -p2 < $SDK/install/gnupoc.er5.patch.011-patch
chmod +x $SDK/install/gnupoc/epoc_cpp_sdk/epoc32/tools/*
mv $SDK/install/gnupoc/epoc_cpp_sdk/ $SDK
rm -rf $SDK/install/gnupoc
mkdir $SDK/epoc_cpp_sdk/tmp

# Correct code in the SDK for lower case changes and ISO C++
cd $SDK/epoc_cpp_sdk/
# 1. Rename includes to lower case
find . -type f \( -iname "*.c" -o -iname "*.h" -o -iname "*.cpp" \) -print0 | xargs -0 sed -i -e "s/#include\s\"\([._a-zA-Z0-9]\+\)\"/#include \"\L\1\"/"
find . -type f \( -iname "*.c" -o -iname "*.h" -o -iname "*.cpp" \) -print0 | xargs -0 sed -i -e "s/#include\s<\([._a-zA-Z0-9]\+\)>/#include <\L\1>/"
# 2. Remove non ISO "const xxx=123;" without a type specified, use #define instead
find . -type f \( -iname "*.c" -o -iname "*.h" -o -iname "*.cpp" \) -print0 | xargs -0 sed -i -e "s/^const \([A-Za-z0-9]\+\)=\(.\+\);/#define \1 \2/"
# 3. Make sure != operators have a return type TBool
find . -type f \( -iname "*.c" -o -iname "*.h" -o -iname "*.cpp" \) -print0 | xargs -0 sed -i -e "s/inline operator!=/inline TBool operator !=/"
# 4. Replace library names like "EUSER.LIB" with lower case versions inside project files
find . -type f \( -iname "*.mmp" \) -print0 | xargs -0 sed -i -e "s/\([A-Za-z0-9]\+\)\.LIB/\L\1\.lib/g"
find . -type f \( -iname "*.mmp" \) -print0 | xargs -0 sed -i -e "s/\([A-Za-z0-9]\+\)\.lib/\L\1\.lib/g"

# Create a file that we will source to start using the sdk
printf '%s\n' 'export EPOCROOT=`pwd`/epoc_cpp_sdk' 'export PATH=$PATH:`pwd`/gcc-3.0-psion-98r2-9/bin:`pwd`/epoc_cpp_sdk/epoc32/tools' 'export TMP=`pwd`/epoc_cpp_sdk/tmp' > $SDK/start_epoc_sdk.sh

# Create a symlink for an x: drive in wine so the emulator works
ln -s $SDK $HOME/.wine/dosdevices/x:
