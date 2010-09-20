MABlockClosure
-----------

MABlockClosure uses libffi to generate function pointers wrapping Objective-C blocks. It will generate a function pointer with the same parameter and return types, which when invoked, invokes the block. Mac OS X is fully supported, and there is also experimental support for iOS.

MABlockClosure is released under a BSD license. For the official license, see the LICENSE file.

Quick Start
-----------

The easiest way to use the code is with the BlockFptr convenience function. This function returns a function pointer whose lifetime is equivalent to that of the block passed to it. Note that the block must be on the heap or global: stack blocks will not correctly destroy the function pointer when they go out of scope.

Example with a callback:

    atexit(BlockFptr(^{ ...do something, no captured variables so it's a global block... }));

Use a block to add a new method to NSObject:

    int captured = 42;
    id block = ^(id self, SEL _cmd) { NSLog(@"captured is %d", captured); };
    block = [block copy];
    class_addMethod([NSObject class], @selector(my_printCaptured), BlockFptr(block));

For more control over the lifetime of the returned function pointer, you can use the MABlockClosure class. When an MABlockClosure object is destroyed, the function pointer it gives you from the -fptr method is also destroyed.

Compatibility
-------------

Because MABlockClosure uses libffi to do all of the heavy lifting, it should work on any processor architecture where libffi is available.

The interface between blocks and libffi depends on block signature metadata being present. This metadata is generated when building with the build of clang that ships with the latest Xcode. It is *not* generated when building with the currently shipping gcc as of this writing. The code will fail quickly and loudly if it is not present.

The block signature metadata is the same format as Objective-C method signature strings. Parsing these strings is tricky. The code will parse every primitive type supported by the @encode syntax as well as NSRect, NSPoint, NSSize, and their CG equivalents. Other structs can be added relatively easily, but it is a manual process as the code makes no attempt to actually parse structs.

Standard libffi closures require calling mprotect to mark data pages as executable. This is not currently supported on iOS, so they don't work there. There is an experimental libffi modification to make this work, made by Landon Fuller. More on this below.

iOS Support
-----------

Due to iOS not supporting the creation of executable data, standard libffi closures don't work there. Landon Fuller has developed a fork of libffi that uses some crazy dirty tricks to work around this, and MABlockClosure works with this fork. This requires building a custom libffi, but iOS doesn't even offer libffi anyway, so this would be required either way.

Note that libffi closures on iOS are *highly experimental* and you should tread with caution. They have worked well in limited testing so far, but be prepared for trouble.

This libffi fork is located here:

http://github.com/landonf/libffi-ios

Here are some brief instructions for how to get this fork up and running with MABlockClosure.

First, check out the libffi-ios repository next to your project's folder:

    git clone http://github.com/landonf/libffi-ios.git

Next, use the build-ios.sh script to configure and build it using the proper flags. (Note that you may need to edit the SDK setting in this script first.)

    cd libffi-ios
    ./build-ios.sh

Now everything should be built. Then you need to tell your Xcode project where to find this stuff.

You need to make two changes to your project's build settings.

First, add the following to Other Linker Flags:

    ../libffi-ios/build-ios/.libs/libffi.a

Next, add the following to Header Search Paths:

    ../libffi-ios/build-ios/include

Finally, add the MABlockClosure files to your project. You should now be able to use MABlockClosure on iOS.
