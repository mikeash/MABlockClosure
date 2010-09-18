
#import <Foundation/Foundation.h>

#import "MABlockClosure.h"


int main(int argc, char **argv)
{
    [NSAutoreleasePool new];
    
    id block = ^(int x) { return x + argc; };
    
    MABlockClosure *closure = [[MABlockClosure alloc] initWithBlock: block];
    int ret = ((int (*)(int))[closure fptr])(3);
    NSLog(@"%d", ret);
    [closure release];
    
    block = ^{ return argv[0]; };
    closure = [[MABlockClosure alloc] initWithBlock: block];
    char *s = ((char *(*)(void))[closure fptr])();
    NSLog(@"%s", s);
    [closure release];
}
