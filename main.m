
#import <Foundation/Foundation.h>

#import "MABlockClosure.h"


#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#define NSStringFromRect(r) NSStringFromCGRect(r)
#endif

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
    
    block = ^{ return CGRectMake(0, 0, 0, 0); };
    closure = [[MABlockClosure alloc] initWithBlock: block];
    CGRect r = ((CGRect (*)(void))[closure fptr])();
    NSLog(@"%@", NSStringFromRect(r));
    [closure release];
    
    block = [^(NSString *s) { return [s stringByAppendingFormat: @" %s", argv[0]]; } copy];
    NSString *strObj = ((id (*)(id))BlockFptr(block))(@"hello");
    NSLog(@"%@", strObj);
    [block release];
    
    block = ^(int x, int y) { return x + y; };
    closure = [[MABlockClosure alloc] initWithBlock: block];
    ret = ((int (*)(int, int))[closure fptr])(5, 10);
    NSLog(@"%d", ret);
    
    block = ^{ NSLog(@"Hello"); };
    closure = [[MABlockClosure alloc] initWithBlock: block];
    ((void (*)(void))[closure fptr])();
    [closure release];
    
    void (*fptr)(void) = BlockFptrAuto(^{ NSLog(@"Hello 2"); });
    fptr();
}
