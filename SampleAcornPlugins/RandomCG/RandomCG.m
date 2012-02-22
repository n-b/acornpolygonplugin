//
//  RandomCG.m
//  RandomCG
//
//  Created by August Mueller on 10/15/07.
//  Copyright Flying Meat Inc 2007 . All rights reserved.
//

#import "RandomCG.h"

#define PI 3.14159265358979323846

@implementation RandomCG

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (void) willRegister:(id<ACPluginManager>)pluginManager {
    
    [pluginManager addFilterMenuTitle:@"Random CG Calls"
                   withSuperMenuTitle:@"Generator"
                               target:self
                               action:@selector(make:userObject:)
                        keyEquivalent:@""
            keyEquivalentModifierMask:0
                           userObject:nil];
}

- (void) didRegister {
    
}

- (CIImage*) make:(CIImage*)image userObject:(id)uo {
    
    NSImage *img = [image NSImage];
    
    int w = [img size].width;
    int h = [img size].height;
    
    [img lockFocus];
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextClearRect(context, CGRectMake(0, 0, w, h));
    
    int i;
    
    
    for (i = 0; i < 20; i++) {
        int numberOfSegments = rand() % 8;
        int j;
        float sx, sy;
        
        
        if (i==0)
        {
            CGContextSetRGBFillColor(context, (float)(rand()%256)/255, 
                                     (float)(rand()%256)/255, (float)(rand()%256)/255, 
                                     1);
            CGContextBeginPath(context);
            CGContextAddRect(context, CGRectMake(0, 0, w, h));
            CGContextDrawPath(context, kCGPathFill);
            CGContextClosePath(context);
        }	
        
        
        CGContextBeginPath(context);
        sx = rand()%w; sy = rand()%h;
        CGContextMoveToPoint(context, rand()%w, rand()%h);
        for (j = 0; j < numberOfSegments; j++) {
            if (j % 2) {
                CGContextAddLineToPoint(context, rand()%w, rand()%h);
            }
            else {
                CGContextAddCurveToPoint(context, rand()%w, rand()%h,  
                                         rand()%w, rand()%h,  rand()%h, rand()%h);
            }
        }
        if(i % 2) {
            CGContextAddCurveToPoint(context, rand()%w, rand()%h,
                                     rand()%w, rand()%h,  sx, sy);
            CGContextClosePath(context);
            CGContextSetRGBFillColor(context, (float)(rand()%256)/255, 
                                     (float)(rand()%256)/255, (float)(rand()%256)/255, 
                                     (float)(rand()%256)/255);
            CGContextFillPath(context);
        }
        else {
            CGContextSetLineWidth(context, (rand()%10)+2);
            CGContextSetRGBStrokeColor(context, (float)(rand()%256)/255, 
                                       (float)(rand()%256)/255, (float)(rand()%256)/255, 
                                       (float)(rand()%256)/255);
            CGContextStrokePath(context);
        }
    }
    
    [img unlockFocus];
    
    
    return [CIImage imageWithData:[img TIFFRepresentation]];
}

- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

@end
