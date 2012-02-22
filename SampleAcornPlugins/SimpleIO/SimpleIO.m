//
//  SimpleIO.m
//  SimpleIO
//
//  Created by August Mueller on 2/5/09.
//  Copyright Flying Meat Inc 2009 . All rights reserved.
//

#import "SimpleIO.h"

@implementation SimpleIO

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (void) willRegister:(id<ACPluginManager>)pluginManager {
    debug(@"%s:%d", __FUNCTION__, __LINE__);
    [pluginManager registerIOProvider:self forUTI:(id)kUTTypePICT];
    
}

- (void) didRegister {
    
}

- (BOOL)writeDocument:(<ACDocument>)document toURL:(NSURL *)absoluteURL ofType:(NSString *)type forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError {
    
    CGImageRef composite = [document createCGImage];
    
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((CFURLRef)absoluteURL, (CFStringRef)type , 1, NULL);
    CGImageDestinationAddImage(imageDestination, composite, (CFDictionaryRef)[NSDictionary dictionary]);
    CGImageDestinationFinalize(imageDestination);
    CFRelease(imageDestination);
    
    CGImageRelease(composite);
    
    return YES;
}

- (BOOL) readImageForDocument:(<ACDocument>)document fromURL:(NSURL *)absoluteURL ofType:(NSString *)type error:(NSError **)outError {
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:type forKey:(id)kCGImageSourceTypeIdentifierHint];
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)[NSData dataWithContentsOfURL:absoluteURL], (CFDictionaryRef)options);
    
    if (!imageSourceRef) {
        NSLog(@"THE SimpleIO plugin could not read %@", absoluteURL);
        return NO;
    }
    
    NSDictionary *props = [(id)CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, (CFDictionaryRef)[NSDictionary dictionary]) autorelease];
    
    
    NSSize s;
    
    s.width  = [[props objectForKey:(id)kCGImagePropertyPixelWidth] intValue];
    s.height = [[props objectForKey:(id)kCGImagePropertyPixelHeight] intValue];
    
    [document setCanvasSize:s];
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, (CFDictionaryRef)[NSDictionary dictionary]);
    
    CFRelease(imageSourceRef);
    
    id <ACGroupLayer> baseGroup = [document baseGroup];
    
    NSString *fileName = [[[absoluteURL path] lastPathComponent] stringByDeletingPathExtension];
    
    [baseGroup insertCGImage:imageRef atIndex:0 withName:fileName];
    
    debug(@"document: %@", document);
    debug(@"absoluteURL: %@", absoluteURL);
    debug(@"type: %@", type);
    
    return YES;
}

- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

@end
