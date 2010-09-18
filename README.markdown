MABlockClosure
-----------

MABlockClosure uses libffi to generate function pointers wrapping Objective-C blocks. It will generate a function pointer with the same parameter and return types, which when invoked, invokes the block. Due to OS limitations, MABlockClosure only works on the Mac, and not iOS.

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

The use of libffi closures requries calling mprotect to mark data pages as executable. This is not currently supported on iOS, so MABlockClosure is Mac-only until and unless this changes.
