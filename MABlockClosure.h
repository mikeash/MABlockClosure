
#import <ffi/ffi.h>
#import <Foundation/Foundation.h>


@interface MABlockClosure : NSObject
{
    NSMutableArray *_allocations;
    ffi_cif _closureCIF;
    ffi_cif _innerCIF;
    void *_closure;
    id _block;
}

- (id)initWithBlock: (id)block;

- (void *)fptr;

@end
