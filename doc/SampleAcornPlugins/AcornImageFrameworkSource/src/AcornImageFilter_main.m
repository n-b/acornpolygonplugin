#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ACImage.h"

#define debug NSLog

@interface ServiceTest : NSObject {
    
}

@end

@implementation ServiceTest

- (void) convertData:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    debug(@"%s:%d", __FUNCTION__, __LINE__);
    
    [pboard clearContents];
    
    debug(@"userData: %@", userData);
    
    [pboard addTypes:[NSArray arrayWithObjects:(id)kUTTypeTIFF, nil] owner:nil];
    
    [pboard setData:[NSData dataWithContentsOfMappedFile:@"/Volumes/srv/Users/gus/Desktop/bimage.tiff"] forType:(id)kUTTypeTIFF];
    
}

@end


int main (int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    
    ServiceTest *serviceProvider = [[ServiceTest alloc] init];
    
    NSRegisterServicesProvider(serviceProvider, @"SimpleService");
    
    NS_DURING
        debug(@"runing");
        [[NSRunLoop currentRunLoop] run];
    NS_HANDLER
        NSLog(@"Received exception: %@", localException);
    
    NS_ENDHANDLER
    
    [serviceProvider release];
    
    
    /*
    if (args && ([args count] == 2)) {
        
        //ACImage *img = [ACImage imageWithFilePath:[args objectAtIndex:1]];
        
        //NSData *compositeDataPNG = [img compositeData];
        
        NSData *foo = [[NSFileHandle fileHandleForReadingAtPath:[args objectAtIndex:1]] readDataToEndOfFile];
        
        //NSData *compositeData = [NSData dataWithContentsOfMappedFile:@"/Volumes/srv/Users/gus/Desktop/MyImage.tiff"];
        NSData *compositeData = [NSData dataWithContentsOfMappedFile:@"/Volumes/srv/Users/gus/Desktop/bimage.tiff"];
        
        NSFileHandle *stdOutput = [NSFileHandle fileHandleWithStandardOutput];
        [stdOutput writeData:compositeData];
        
        //[stdOutput writeData:[[[[NSImage alloc] initWithData:compositeDataPNG] autorelease] TIFFRepresentation]];
    }
    
    */
    
    [pool release];
    
    return 0;      // ...and make main fit the ANSI spec.
}
