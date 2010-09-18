
#import <ffi/ffi.h>
#import <Foundation/Foundation.h>
#import <sys/mman.h>


static void *BlockImpl(id block)
{
    return ((void **)block)[2];
}

static void BlockClosure(ffi_cif *cif, void *ret, void **args, void *userdata)
{
    ffi_type *argTypes[] = { &ffi_type_pointer, &ffi_type_sint32 };
    ffi_cif innercif;
    ffi_status result = ffi_prep_cif(&innercif, FFI_DEFAULT_ABI, 2, &ffi_type_sint32, argTypes);
    if(result != FFI_OK)
    {
        NSLog(@"Got result %ld from ffi_prep_cif", (long)result);
    }
    
    int val = 3;
    void *innerargs[] = { &userdata, args[0] };
    ffi_call(&innercif, BlockImpl(userdata), ret, innerargs);
}

int main(int argc, char **argv)
{
    id block = ^(int x) { return x + argc; };
    
    ffi_type *argTypes[] = { &ffi_type_sint32 };
    ffi_cif cif;
    ffi_status status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 2, &ffi_type_sint32, argTypes);
    if(status != FFI_OK)
    {
        NSLog(@"Got result %ld from ffi_prep_cif", (long)status);
        return 1;
    }
    
    ffi_closure *closure = mmap(NULL, sizeof(ffi_closure), PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    if(closure == (void *)-1)
    {
        perror("mmap");
        return 1;
    }
    
    status = ffi_prep_closure(closure, &cif, BlockClosure, block);
    if(status != FFI_OK)
    {
        NSLog(@"Got result %ld from ffi_prep_closure", (long)status);
        return 1;
    }
    
    if(mprotect(closure, sizeof(closure), PROT_READ | PROT_EXEC) == -1)
    {
        perror("mprotect");
        return 1;
    }
    
    long ret = ((int (*)(int))closure)(3);
    NSLog(@"%ld", (long)ret);
}
