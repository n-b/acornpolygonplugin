//
//  Created by August Mueller on 11/14/06.
//  Copyright 2006 Flying Meat Inc.. All rights reserved.
//
//  Copyright 2008 Andrew Finnell
//  http://www.losingfight.com/blog/2007/09/04/how-to-implement-smudge-and-stamp-tools/

#import "ACSmudgePlugin.h"

NSRect ACSCNSRectFromCGRect(CGRect cgrect) {
    return NSMakeRect(cgrect.origin.x, cgrect.origin.y, cgrect.size.width, cgrect.size.height);
    //return (*(NSRect *)(void *)&(cgrect));
}

CGRect ACSCNSRectToCGRect(NSRect nsrect) {
    return (*(CGRect *)(void *)&(nsrect));
}

float ACSMDistance2D(float x1, float yy1, float x2, float y2) {
    return sqrt((x1 - x2) * (x1 - x2) + (yy1 - y2) * (yy1 - y2));
}

BOOL ACSMInBetween(float x1, float yy1, float x2, float y2, float x3, float y3) {
    if ((x1 - x2) * (x3 - x2) <= 0 && (yy1 - y2) * (y3 - y2) <= 0) {
        return YES;
    }
    
    return NO;
} 

@implementation ACSmudgePlugin

+ (void) initialize {
    
    
	NSMutableDictionary *defaultValues 	= [NSMutableDictionary dictionary];
    NSUserDefaults      *defaults 	 	= [NSUserDefaults standardUserDefaults];
    
    [defaultValues setObject:[NSNumber numberWithFloat:10.f] forKey:@"smudgeRadius"];
    
    [defaults registerDefaults: defaultValues];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues];
}

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (id) init {
    
    if ((self = [super init])) {
        [NSBundle loadNibNamed:@"Smudge" owner:self];
        
        
        id defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        [defaultsController addObserver:self
                             forKeyPath:@"values.smudgeRadius" 
                                options:(NSKeyValueObservingOptionNew)
                                context:NULL];
        
    }
    
    return self;
}




- (void) willRegister:(id<ACPluginManager>)pluginManager {
    [pluginManager addBitmapTool:self];
}

- (void) didRegister {
    
}

- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

- (CGContextRef) createBitmapContext {
    
    // FIXME - move to config
    float radius = [[NSUserDefaults standardUserDefaults] floatForKey:@"smudgeRadius"];
    
    mShape = CGPathCreateMutable();
    CGPathAddEllipseInRect(mShape, nil, CGRectMake(0, 0, 2 * radius, 2 * radius));
    
	// Create the offscreen bitmap context that we can draw the brush tip into.
	//	The context should be the size of the shape bounding box.
	CGRect boundingBox = CGPathGetBoundingBox(mShape);
	
	size_t width = CGRectGetWidth(boundingBox);
	size_t height = CGRectGetHeight(boundingBox);
	size_t bitsPerComponent = 8;
	size_t bytesPerRow = (width + 0x0000000F) & ~0x0000000F; // 16 byte aligned is good
	size_t dataSize = bytesPerRow * height;
	void* data = calloc(1, dataSize);
	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray);
	
	CGContextRef bitmapContext = CGBitmapContextCreate(data, width, height, bitsPerComponent,
													   bytesPerRow, colorspace, 
													   kCGImageAlphaNone);
	
	CGColorSpaceRelease(colorspace);
	
	CGContextSetGrayFillColor(bitmapContext, 0.0, 1.0);
	CGContextFillRect(bitmapContext, CGRectMake(0, 0, width, height));
	
	return bitmapContext;
}

- (void) disposeBitmapContext:(CGContextRef)bitmapContext {
	// Free up the offscreen bitmap
	void * data = CGBitmapContextGetData(bitmapContext);
	CGContextRelease(bitmapContext);
	free(data);	
}

- (CGImageRef) createShapeImage
{
	// Create a bitmap context to hold our brush image
	CGContextRef bitmapContext = [self createBitmapContext];
	
	CGContextSetGrayFillColor(bitmapContext, 1.0, 1.0);
	
    // FIXME - move to config
    float radius = [[NSUserDefaults standardUserDefaults] floatForKey:@"smudgeRadius"];
    
    // FIXME - move to config
    float softness = 0.5;
    
	// The way we acheive "softness" on the edges of the brush is to draw
	//	the shape full size with some transparency, then keep drawing the shape
	//	at smaller sizes with the same transparency level. Thus, the center
	//	builds up and is darker, while edges remain partially transparent.
	
	// First, based on the softness setting, determine the radius of the fully
	//	opaque pixels.
	int innerRadius = (int)ceil(softness * (0.5 - radius) + radius);
	int outerRadius = (int)ceil(radius);
	int i = 0;
	
	// The alpha level is always proportial to the difference between the inner, opaque
	//	radius and the outer, transparent radius.
	float alphaStep = 1.0 / (outerRadius - innerRadius + 1);
	
	// Since we're drawing shape on top of shape, we only need to set the alpha once
	CGContextSetAlpha(bitmapContext, alphaStep);
	
	for (i = outerRadius; i >= innerRadius; --i) {
		CGContextSaveGState(bitmapContext);
		
		// First, center the shape onto the context.
		CGContextTranslateCTM(bitmapContext, outerRadius - i, outerRadius - i);
		
		// Second, scale the the brush shape, such that each successive iteration
		//	is two pixels smaller in width and height than the previous iteration.
		float scale = (2.0 * (float)i) / (2.0 * (float)outerRadius);
		CGContextScaleCTM(bitmapContext, scale, scale);
		
		// Finally, actually add the path and fill it
		CGContextAddPath(bitmapContext, mShape);
		CGContextEOFillPath(bitmapContext);
		
		CGContextRestoreGState(bitmapContext);
	}
	
	// Create the brush tip image from our bitmap context
	CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
	
	// Free up the offscreen bitmap
	[self disposeBitmapContext:bitmapContext];
	
	return image;
}



- (void) mouseDown:(NSEvent*)theEvent onCanvas:(NSView*)canvas toLayer:(id<ACBitmapLayer>)layer {
    
    float radius = floorf([[NSUserDefaults standardUserDefaults] floatForKey:@"smudgeRadius"]);
    
    CGContextRef context = [layer drawableContext];
    
    NSPoint downPoint = [layer layerPointFromEvent:theEvent];
    NSPoint lastPoint = downPoint;
    NSRect updateRect = NSMakeRect(downPoint.x, downPoint.y, 1, 1);
    
    CGSize     canvasSize       = CGSizeMake(CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context));
    CGRect     placeRect        = CGRectMake(downPoint.x - (radius / 2.f), downPoint.y - (radius / 2.f), radius, radius);
    CGRect     flippedRect      = placeRect;
    flippedRect.origin.y        = (canvasSize.height - flippedRect.origin.y) - flippedRect.size.height;
    
    CGImageRef stampTemplate    = CGBitmapContextCreateImage(context);
    CGImageRef stamp            = CGImageCreateWithImageInRect(stampTemplate, flippedRect);
    
    CGImageRelease(stampTemplate);
    
	CGImageRef mask = [self createShapeImage];
    
    float step = 25.f;
    float size = 10.f;
    
    NSRect commitRect = ACSCNSRectFromCGRect(placeRect);
    
    while (1) {
        
        theEvent = [[canvas window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if (([theEvent type] == NSLeftMouseUp)) {
            break;
        }
        
        downPoint = [layer layerPointFromEvent:theEvent];
        
        // if we're zoomed in, this can happen- no need to play with the image below.
        if (NSEqualPoints(downPoint, lastPoint)) {
            continue;
        }
        
        float x = lastPoint.x;
        float y = lastPoint.y;
        
        int i = 0;
        
        do {
            x = (lastPoint.x + i * (size * step / 100.0) * (downPoint.x - lastPoint.x) / ACSMDistance2D(lastPoint.x, lastPoint.y, downPoint.x, downPoint.y));
            y = (lastPoint.y + i * (size * step / 100.0) * (downPoint.y - lastPoint.y) / ACSMDistance2D(lastPoint.x, lastPoint.y, downPoint.x, downPoint.y));
            
            placeRect               = CGRectMake(x - (radius / 2.f), y - (radius / 2.f), radius, radius);
            
            flippedRect             = placeRect;
            flippedRect.origin.y    = (canvasSize.height - flippedRect.origin.y) - flippedRect.size.height;
            
            CGContextSaveGState(context);
            CGContextClipToMask(context, placeRect, mask);
            CGContextDrawImage(context, placeRect, stamp);
            CGContextRestoreGState(context);
            CGImageRelease(stamp);
            
            stampTemplate    = CGBitmapContextCreateImage(context);
            stamp            = CGImageCreateWithImageInRect(stampTemplate, flippedRect);
            
            CGImageRelease(stampTemplate);
            
            [layer setNeedsDisplayInRect:ACSCNSRectFromCGRect(placeRect)];
            
            i++;
        }
        while (ACSMDistance2D(x, y, downPoint.x, downPoint.y) > (size * step / 100.0) && ACSMInBetween(lastPoint.x, lastPoint.y, x, y, downPoint.x, downPoint.y));
        
        commitRect = NSUnionRect(commitRect, ACSCNSRectFromCGRect(placeRect));
        
        lastPoint = downPoint;
        [canvas autoscroll:theEvent];
    }
    
    commitRect = NSIntegralRect(NSInsetRect(commitRect, -1, -1));
    
    [layer commitFrameOfDrawableContext:commitRect];
    
    CGImageRelease(stamp);
    
    CGImageRelease(mask);
    
    
    CGPathRelease(mShape);
}

- (NSString *) toolName {
    return @"Distort";
}

- (NSBezierPath*) bezierCircleAroundPoint:(NSPoint)p radius:(float)radius {
    
    NSRect r;
    
    r.origin.x = p.x - radius;
    r.origin.y = p.y - radius;
    r.size.width = radius * 2;
    r.size.height = radius * 2;
    
    return [NSBezierPath bezierPathWithOvalInRect:r];
}

- (NSCursor*) toolCursorAtScale:(float)scale {
    
    debug(@"scale: %f", scale);
    
    float radius = ([[NSUserDefaults standardUserDefaults] floatForKey:@"smudgeRadius"] / 2) * scale;
    float brushSize = (radius * 2);
    
    NSImage *img = [[[NSImage alloc] initWithSize:NSMakeSize(brushSize + 4, brushSize + 4)] autorelease];
    [img lockFocus]; {
        
        NSBezierPath *path = [self bezierCircleAroundPoint:NSMakePoint(radius + 2, radius + 2) radius:radius];
        
        NSBezierPath *stroke = [self bezierCircleAroundPoint:NSMakePoint(radius + 2, radius + 2) radius:radius + .5];
        
        [[NSColor whiteColor] set];
        [stroke stroke];
        
        [path setLineWidth:1];
        [[NSColor blackColor] set];
        [path stroke];
        
    } [img unlockFocus];
    
    NSCursor *cursor = [[[NSCursor alloc] initWithImage:img hotSpot:NSMakePoint(radius + 2, radius + 2)] autorelease];
    
    return cursor;
}

- (NSView*) toolPaletteView {
    return paletteView;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([@"values.smudgeRadius" isEqualToString:keyPath]) {
        // I need to make this public
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSToolDidChangeNotification" object:nil];
    }
}


@end
