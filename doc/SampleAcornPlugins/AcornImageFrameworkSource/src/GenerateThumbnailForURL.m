#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import "ACImage.h"

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    
    
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    // Create and read the document file
    ACImage *img = [ACImage imageWithURL:(NSURL *)url];
    
    NSSize canvasSize = [img canvasSize];
    
    // Preview will be drawn in a vectorized context
    CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, *(CGSize *)&canvasSize, false, NULL);
    if(cgContext) {
        
        [img drawInContext:cgContext];
        
        QLThumbnailRequestFlushContext(thumbnail, cgContext);
        
        CFRelease(cgContext);
    }
    
    [pool release];
    
    
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
