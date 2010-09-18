
#import "MABlockClosure.h"

#import <assert.h>
#import <sys/mman.h>


@implementation MABlockClosure

struct BlockDescriptor
{
    unsigned long reserved;
    unsigned long size;
    void *rest[1];
};

struct Block
{
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct BlockDescriptor *descriptor;
};
    

static void *BlockImpl(id block)
{
    return ((void **)block)[2];
}

static const char *BlockSig(id blockObj)
{
    struct Block *block = (void *)blockObj;
    struct BlockDescriptor *descriptor = block->descriptor;
    
    int copyDisposeFlag = 1 << 25;
    int signatureFlag = 1 << 30;
    
    assert(block->flags & signatureFlag);
    
    int index = 0;
    if(block->flags & copyDisposeFlag)
        index += 2;
    
    return descriptor->rest[index];
}

static void BlockClosure(ffi_cif *cif, void *ret, void **args, void *userdata)
{
    MABlockClosure *self = userdata;
    
    void *innerargs[] = { &self->_block, args[0] };
    ffi_call(&self->_innerCIF, BlockImpl(self->_block), ret, innerargs);
}

static void *AllocateClosure(void)
{
    ffi_closure *closure = mmap(NULL, sizeof(ffi_closure), PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    if(closure == (void *)-1)
    {
        perror("mmap");
        return NULL;
    }
    return closure;
}

static void DeallocateClosure(void *closure)
{
    munmap(closure, sizeof(ffi_closure));
}

- (void *)_allocate: (size_t)howmuch
{
    NSMutableData *data = [NSMutableData dataWithLength: howmuch];
    [_allocations addObject: data];
    return [data mutableBytes];
}

- (void)_prepClosureCIF
{
    ffi_type **argTypes = [self _allocate: sizeof(*argTypes)];
    argTypes[0] = &ffi_type_sint32;
    ffi_status status = ffi_prep_cif(&_closureCIF, FFI_DEFAULT_ABI, 1, &ffi_type_sint32, argTypes);
    if(status != FFI_OK)
    {
        NSLog(@"Got result %ld from ffi_prep_cif", (long)status);
        abort();
    }
}

- (void)_prepInnerCIF
{
    ffi_type **argTypes = [self _allocate: sizeof(*argTypes)];
    argTypes[0] = &ffi_type_pointer;
    argTypes[1] = &ffi_type_sint32;
    ffi_status status = ffi_prep_cif(&_innerCIF, FFI_DEFAULT_ABI, 2, &ffi_type_sint32, argTypes);
    if(status != FFI_OK)
    {
        NSLog(@"Got result %ld from ffi_prep_cif", (long)status);
        abort();
    }
}

- (void)_prepClosure
{
    ffi_status status = ffi_prep_closure(_closure, &_closureCIF, BlockClosure, self);
    if(status != FFI_OK)
    {
        NSLog(@"ffi_prep_closure returned %d", (int)status);
        abort();
    }
    
    if(mprotect(_closure, sizeof(_closure), PROT_READ | PROT_EXEC) == -1)
    {
        perror("mprotect");
        abort();
    }
}

- (id)initWithBlock: (id)block
{
    if((self = [self init]))
    {
        NSLog(@"%s", BlockSig(block));
        _allocations = [[NSMutableArray alloc] init];
        _block = block;
        _closure = AllocateClosure();
        [self _prepClosureCIF];
        [self _prepInnerCIF];
        [self _prepClosure];
    }
    return self;
}

- (void)dealloc
{
    if(_closure)
        DeallocateClosure(_closure);
    [_allocations release];
    [super dealloc];
}

- (void *)fptr
{
    return _closure;
}

@end
