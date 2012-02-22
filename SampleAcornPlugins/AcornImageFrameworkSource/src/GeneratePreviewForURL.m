#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import "ACImage.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    // Create and read the document file
    ACImage *img = [ACImage imageWithURL:(NSURL *)url];
    
    NSSize canvasSize = [img canvasSize];
    
    // Preview will be drawn in a vectorized context
    CGContextRef cgContext = QLPreviewRequestCreateContext(preview, *(CGSize *)&canvasSize, false, NULL);
    if(cgContext) {
        
        [img drawInContext:cgContext];
        
        QLPreviewRequestFlushContext(preview, cgContext);
        
        CFRelease(cgContext);
    }
    
    [pool release];
    
    
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
