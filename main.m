
#import <Foundation/Foundation.h>

#import "MABlockClosure.h"


int main(int argc, char **argv)
{
    [NSAutoreleasePool new];
    
    id block = ^(int x) { return x + argc; };
    
    MABlockClosure *closure = [[MABlockClosure alloc] initWithBlock: block];
    long ret = ((int (*)(int))[closure fptr])(3);
    NSLog(@"%ld", (long)ret);
}
