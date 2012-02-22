//
//  ACPSDLoader.m
//  ACPSDLoader
//
//  Created by August Mueller on 2/5/09.
//  Copyright Flying Meat Inc 2009 . All rights reserved.
//

#import "ACPSDLoader.h"
#include "libpsd.h"

#define ACPSDARGBToColor(tta, ttr, ttg, ttb)		(((tta) << 24) | ((ttr) << 16) | ((ttg) << 8) | (ttb))
#define ACPSDGetAlpha(c) (((c) & 0xFF000000) >> 24)
#define ACPSDGetRed(c)   (((c) & 0x00FF0000) >> 16)
#define ACPSDGetGreen(c) (((c) & 0x0000FF00) >> 8)
#define ACPSDGetBlue(c)  ((c)  & 0x000000FF)



@implementation ACPSDLoader

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (void) willRegister:(id<ACPluginManager>)pluginManager {
    
    [pluginManager registerIOProviderForReading:self forUTI:@"com.adobe.photoshop-image"];
    //[pluginManager registerIOProviderForWriting:self forUTI:@"com.adobe.photoshop-image"];
}

- (void) didRegister {}

- (BOOL)writeDocument:(id<ACDocument>)document toURL:(NSURL *)absoluteURL ofType:(NSString *)type forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError {
    debug(@"hai, we want to save, right?");
    
    
    return NO;
}

- (BOOL) loadCompositeForDocument:(id<ACDocument>)document fromURL:(NSURL *)absoluteURL {
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:@"com.adobe.photoshop-image" forKey:(id)kCGImageSourceTypeIdentifierHint];
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)absoluteURL, (CFDictionaryRef)options);
    
    if (!imageSourceRef) {
        NSLog(@"Could not turn the file into an image");
        return NO;
    }
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, (CFDictionaryRef)[NSDictionary dictionary]);
    
    CFRelease(imageSourceRef);
    
    if (!imageRef) {
        return NO;
    }
    
    [document setCanvasSize:NSMakeSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef))];
    
    id <ACGroupLayer> baseGroup = [document baseGroup];
    [baseGroup insertCGImage:imageRef atIndex:0 withName:NSLocalizedString(@"Background", @"Background")];
    
    CGImageRelease(imageRef);
    
    return YES;
}


- (BOOL) readImageForDocument:(id<ACDocument>)document fromURL:(NSURL *)absoluteURL ofType:(NSString *)type error:(NSError **)outError {
    
    debug(@"%s:%d", __FUNCTION__, __LINE__);
    
    /*
    #ifdef __LP64__
    // libpsd doesn't work so well in 64bit mode.
    return [self loadCompositeForDocument:document fromURL:absoluteURL];
    #endif
    */
    //NSData *data = [NSData dataWithContentsOfURL:absoluteURL];
    
    // vImageVerticalReflect_ARGB8888
    
    psd_context * pdfContext = NULL;
    psd_status status;
    
    status = psd_image_load(&pdfContext, (psd_char*)[[absoluteURL path] fileSystemRepresentation]);
    
    debug(@"status: %d", status);
    
    if (!pdfContext) {
        NSLog(@"Loading composite");
        // well shit.
        return [self loadCompositeForDocument:document fromURL:absoluteURL];
    }
    
    #warning what about color space?
    
    NSSize canvasSize = NSMakeSize(pdfContext->width, pdfContext->height);
    [document setCanvasSize:canvasSize];
    [document setDpi:NSMakeSize(pdfContext->resolution_info.hres, pdfContext->resolution_info.hres)];
    
    int i = pdfContext->layer_count;
    while (i > 0) {
        psd_layer_record psdLayer = pdfContext->layer_records[i - 1];
        i--;
        
        if ((psdLayer.width == 0) || (!psdLayer.image_data) || (!*psdLayer.image_data)) {
            debug(@"no dater for layer %d", i);
            continue;
        }
        
        
        CGContextRef context;
        size_t destBytesPerRow = psdLayer.width * 4;
        //destBytesPerRow = COMPUTE_BEST_BYTES_PER_ROW(destBytesPerRow);
        psd_argb_color *outDest = calloc(1, destBytesPerRow * psdLayer.height);
        
        //#define PSD_VIMAGE
        
#ifdef PSD_VIMAGE
        
        vImage_Buffer src  = { psdLayer.image_data, psdLayer.width, psdLayer.height, destBytesPerRow };
        vImage_Buffer dest = { outDest, psdLayer.width, psdLayer.height, psdLayer.width * 4 };
        vImagePremultiplyData_ARGB8888(&src, &dest, kvImageNoFlags);
        
#else
        psd_argb_color * dst_color = outDest;
        psd_argb_color * src_color = psdLayer.image_data;
        int j = psdLayer.width * psdLayer.height;
        while (j > 0) {
            j--;
            psd_argb_color temp = *src_color;
            
            //debug(@"temp: %x", temp);
            //debug(@"j: %d", j);
            
            psd_uchar sA = ACPSDGetAlpha(temp);
            psd_uchar sR = ACPSDGetRed(temp);
            psd_uchar sG = ACPSDGetGreen(temp);
            psd_uchar sB = ACPSDGetBlue(temp);
            
            psd_uchar dR = (sR * sA + 127) / 255;
            psd_uchar dG = (sG * sA + 127) / 255;
            psd_uchar dB = (sB * sA + 127) / 255;
            psd_uchar dA = sA;
            
            *dst_color = CFSwapInt32BigToHost(ACPSDARGBToColor(dA, dR, dG, dB));
            
            src_color++;
            dst_color++;
        }
#endif
        
        context = CGBitmapContextCreate(outDest, psdLayer.width, psdLayer.height, 8, destBytesPerRow, 
                                        CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB),
                                        kCGImageAlphaPremultipliedFirst);
        
        if (context) {
            CGImageRef imageRef = CGBitmapContextCreateImage(context);
            
            NSString *name = [NSString stringWithUTF8String:(const char *)psdLayer.layer_name];
            
            id <ACGroupLayer> baseGroup = [document baseGroup];
            id <ACBitmapLayer> layer    = [baseGroup insertCGImage:imageRef atIndex:0 withName:name];
            
            [layer setVisible:psdLayer.visible];
            
            [layer setOpacity:psdLayer.opacity / 255.0f];
            
            NSPoint drawDelta = NSMakePoint(psdLayer.left, canvasSize.height - psdLayer.bottom);
            
            [layer setDrawDelta:drawDelta];
            
            CGImageRelease(imageRef);
        }
        
        CGContextRelease(context);
        free(outDest);
        
        
    }
    
    // free if it's done
    psd_image_free(pdfContext);
    
    if ([[[document baseGroup] layers] count] == 0) {
        return [self loadCompositeForDocument:document fromURL:absoluteURL];
    }
    
    return YES;
}


- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

@end
