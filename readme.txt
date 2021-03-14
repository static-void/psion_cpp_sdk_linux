This is the EPOC/Symbian R5 C++ SDK, adapted to work under modern (2021) Linux.

Installation
------------
You need the following dependencies:

make libc6-dev gcc-multilib g++-multilib flex bison zlib1g-dev wine32

On ubuntu just run:

  sudo apt install build-essential gcc-multilib g++-multilib flex bison zlib1g-dev wine32

Then clone the repository:

  git clone https://github.com/static-void/psion_cpp_sdk_linux.git

Change to the install directory:

  cd psion_cpp_sdk_linux/install

And run the install script:

  ./install.sh

It takes about two or three minutes to compile and generate everything on my machine.

Use
---
Change to the directory where the SDK was installed:

  cd psion_cpp_sdk_linux

Load up environment variables to make everything work:

  source ./start_epoc_sdk.sh

Now you can build some example programs:

  cd epoc_cpp_sdk/epoc32ex/cone/
  makmake cosmiley marm
  make -f cosmiley.marm rel

The above uses makmake on the project file cosmiley.mmp, in the cone example
directory, to generate a makefile, then builds the example with make. "marm"
specifies that you want to build for an actual psion instead of the EPOC "wins"
emulator. I don't know if building for wins will work if you have Visual Studio
6.0 installed with wine. Perhaps I will check at some point.

After running the above example you get cosmiley.app, cosmiley.lib,
cosmiley.rsc and cosmiley.map in
psion_cpp_sdk_linux/epoc_cpp_sdk/epoc32/release/marm/rel/.  If you copy
cosmiley.app, cosmiley.lib and cosmiley.rsc to a psion System/Apps/Cosmiley
directory you will be able to run the example.

The emulator also works under wine, just run:

  epoc_cpp_sdk/epoc32/tools/startemul.sh

Although I have been unsuccesful at making it work with different resolutions,
I am fairly sure it requires some registry entries but I haven't taken the time
to check what. 

Background
----------
The SDK, despite being based on GCC, was never intended to work on a Linux
system.  However, various parties worked to make it compatible with Linux,
using somewhat different approaches. This is a bit of a mash up of the GnuPoc
[1] and sdk2unix [2] approaches.

The SDK consists of three parts:

1. Compiler
2. Headers, static libraries, example programs
3. Tools for resource compiling, exe translation etc and an "emulator"

The C++ SDK originally relied on an ancient GCC 2.9. However thanks to a team
at the University of Szeged [3] a version of GCC 3.0 was also available, with
improved performance over the original gcc. With a lot of pain I have managed
to get this version to compile and operate just fine on a modern Linux. This is
based on patches from Jake Hamby (of GnuPoc), fixes for building old gccs on
modern systems taken from an archive of Trevor Pound's blog [4], a backport of
the _bfd_ar_spacepad fixes to binutils [5], and various other misc changes I
found were needed. Also, you have to lie to the configure script and tell it
you are building on an i386 or it falls over pretty early on.

With the headers and example programs I take the gnupoc approach of turning
everything to lower case, but I also convert the actual #include "XXX.H"
directives to lower case as well as all references to libraries etc, otherwise
you have to do this manually each time an example fails to build. I also had to
convert some of the ancient non-ISO C++ from the example programs, which it
appears didn't even work with something as old as GCC 3.0. Most notably it
appears that in gcc 2.9 it's perfectly fine to declare a const variable with no
type, as an alternative to a #define, so I covert those to #define instead.

GnuPoc has done a pretty good job of converting the perl based makmake tool of
the original SDK (which generates makefiles from the SDK project files) into
something that works on Linux and produces real gmake makefiles, but it was
still broken in places because of changes to wine and perl, and the resource
compiler just plain hated unix paths, so as a workaround I hacked makmake to
run sed before rcomp to make it work.

sdk2unix provides Linux versions of most of the tools, and although I was able
to patch them and get them all to build, at least rcomp does not work (didn't
try the others). rcomp turns out to be based on some unobtainium closed source
lex and yacc ("MKS lex & yacc") so although I could see how to fix it I
couldn't build the modified lexer, and it would take an age to convert it to
flex and bison. So instead I stick with running them through wine which works
just fine with the sed hack for rcomp.

[1] http://gnupoc.sourceforge.net/
[2] http://www.koeniglich.de/sdk2unix/symbian_sdk_on_unix.html
[3] http://www.inf.u-szeged.hu/projectdirs/symbian-gcc/dload.php
[4] https://web.archive.org/web/20120516030400/https://www.trevorpounds.com/blog/?p=111
[5] https://sourceware.org/legacy-ml/binutils/2005-03/msg00180.html

