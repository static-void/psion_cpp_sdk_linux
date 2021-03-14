This is the PSION EPOC/Symbian R5 C++ SDK, adapted to work under modern (2021) 64 bit Linux.

Installation
------------
You need the following dependencies:

make gcc-multilib g++-multilib flex bison zlib1g-dev wine32

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
emulator. Building for wins (with "mwins") may work if you have Visual Studio 
6.0 installed with wine, but has not yet been attempted.

After running the above example you get cosmiley.app, cosmiley.lib,
cosmiley.rsc and cosmiley.map in
psion_cpp_sdk_linux/epoc_cpp_sdk/epoc32/release/marm/rel/.  If you copy
cosmiley.app, cosmiley.lib and cosmiley.rsc to a psion System/Apps/Cosmiley
directory you will be able to run the example.

The wins emulator also works under wine, just run:

  epoc_cpp_sdk/epoc32/tools/startemul.sh

The emulator does not work at different resolutions, likely due to missing
registry entries, but this still needs further investigation. Note that the
wins emulator does not actually emulate a psion, instead it runs an EPOC
API layer on top of x86 windows. It can only run EPOC applications explicitly
compiled for the wins target, and most psion software is not available for
wins. It may be better to bundle WindEmu [1] with the SDK, which emulates a
real 5mx, and thus makes the wins compilation target redundant. With some
modification it may even be possible to add a gdbserver to WindEmu, which
might allow real debugging to be done, albeit bare metal only, since gdb
has no idea about the EPOC threading model etc.

Background
----------
The SDK, despite being based on GCC, was never intended to work on a Linux
system.  However, various parties worked to make it compatible with Linux,
using somewhat different approaches (though all were abandoned 10-20 years
ago). The SDK presented here is a mash up of the GnuPoc [2] and sdk2unix [3]
approaches.

The SDK consists of three parts:

1. Compiler
2. Headers, static libraries, example programs
3. Tools: for resource compiling, exe translation, the wins "emulator" etc

The C++ SDK originally relied on an ancient GCC 2.9. However thanks to a team
at the University of Szeged [4] a version of GCC 3.0 was also available, with
improved performance over the original gcc. With a lot of patching this
version now compiles and runs just fine on a modern Linux. The changes required
are based on patches from Jake Hamby (of GnuPoc), fixes for building old gccs
on modern systems, taken from an archive of Trevor Pound's blog [5], a backport
of the _bfd_ar_spacepad fixes to binutils [6], and various other misc changes
that were required. The install script also lies to the gcc configure script
and tells it its building on an i386, otherwise it falls over pretty early on
(it doesn't know about the existence of x86-64).

For the headers and example programs the gnupoc approach of renaming all files
to lower case is taken, but the install script takes the additonal step of
changing all #include "XXX.H" directives etc in the example code to lower case
as well, otherwise this has to be done manually each time an example fails to
build. The script also fixes some of ancient non-ISO C++ found in the example
programs, for example const variables declared with no type are converted to
#defines, and missing return types are added for overides of infix relational
operators.

GnuPoc has done a pretty good job of converting the perl based makmake tool of
the windows SDK to work on Linux, so that makmake generates real gmake
makefiles from the SDK .mmp project files. It mostly required only minor fixes
due to changes in modern wine and perl. The windows version of the resource
compiler, rcomp, just plain hates unix paths, so as a workaround makmake has
been modified to use sed in the generated makefiles to remove unnecessary unix
paths left by the C pre-processor before running rcomp.

sdk2unix provides Linux versions of most of the tools like rcomp and petran,
and although these have all been patched and now build under x64, at least rcomp
does not actually produce working output (though the others have not been
tested). rcomp turns out to be based on some unobtainium closed source lex and
yacc ("MKS lex & yacc"), so although modifying it to support unix paths looks
easy enough, there is no way to compile the modified lexer. Converting it to use
flex and bison also looks non-trivial, so instead the windows version is used
via wine, which works fine in combination with the sed hack to remove unix paths.

[1] https://github.com/Treeki/WindEmu
[2] http://gnupoc.sourceforge.net/
[3] http://www.koeniglich.de/sdk2unix/symbian_sdk_on_unix.html
[4] http://www.inf.u-szeged.hu/projectdirs/symbian-gcc/dload.php
[5] https://web.archive.org/web/20120516030400/https://www.trevorpounds.com/blog/?p=111
[6] https://sourceware.org/legacy-ml/binutils/2005-03/msg00180.html

