//
//  Created by August Mueller on 11/14/06.
//  Copyright 2006 Flying Meat Inc.. All rights reserved.
//

#import "ACSimpleDrawPlugin.h"

float SDDistance2D(float x1, float yy1, float x2, float y2) {
    return sqrt((x1 - x2) * (x1 - x2) + (yy1 - y2) * (yy1 - y2));
}

BOOL SDInBetween(float x1, float yy1, float x2, float y2, float x3, float y3) {
    if ((x1 - x2) * (x3 - x2) <= 0 && (yy1 - y2) * (y3 - y2) <= 0) {
        return YES;
    }
    
    return NO;
} 

@implementation ACSimpleDrawPlugin

+ (void) initialize {
    
    
	NSMutableDictionary *defaultValues 	= [NSMutableDictionary dictionary];
    NSUserDefaults      *defaults 	 	= [NSUserDefaults standardUserDefaults];
    
    [defaultValues setObject:[NSNumber numberWithFloat:10.f] forKey:@"simpleDrawBrushSize"];
    [defaultValues setObject:[NSNumber numberWithFloat:25.f] forKey:@"simpleDrawStepSize"];
    
    [defaults registerDefaults: defaultValues];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues];
}

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (id) init {
    
    if ((self = [super init])) {
        [NSBundle loadNibNamed:@"SimpleDraw" owner:self];
        
        
        id defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        [defaultsController addObserver:self
                             forKeyPath:@"values.simpleDrawBrushSize" 
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

- (NSString *) toolName {
    return @"SDraw";
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
    
    float radius = [[NSUserDefaults standardUserDefaults] floatForKey:@"simpleDrawBrushSize"] / 2;
    radius *= scale;
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
    
    if ([@"values.simpleDrawBrushSize" isEqualToString:keyPath]) {
        // I need to make this public
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSToolDidChangeNotification" object:nil];
    }
}

- (void) mouseDown:(NSEvent*)theEvent onCanvas:(NSView*)canvas toLayer:(id<ACBitmapLayer>)layer {
    
    
    float size              = [[NSUserDefaults standardUserDefaults] floatForKey:@"simpleDrawBrushSize"];
    float step              = [[NSUserDefaults standardUserDefaults] floatForKey:@"simpleDrawStepSize"] / 100.0f;
    CGContextRef context    = [layer drawableContext];
    NSPoint downPoint       = [layer layerPointFromEvent:theEvent];
    NSPoint lastPoint        = downPoint;
    NSPoint drawPoint;
    NSRect commitRect       = NSMakeRect(downPoint.x - (size / 2), downPoint.y - (size / 2), size, size);
    
    while (1) {
        
        downPoint           = [layer layerPointFromEvent:theEvent];
        CGRect brushRect    = CGRectMake(downPoint.x - (size / 2), downPoint.y - (size / 2), size, size);
        commitRect          = NSUnionRect(commitRect, (*(NSRect *)&brushRect));
        
        float x = lastPoint.x;
        float y = lastPoint.y;
        
        int i = 0;
        
        do {
            x = (lastPoint.x + i * (size * step) * (downPoint.x - lastPoint.x) / SDDistance2D(lastPoint.x, lastPoint.y, downPoint.x, downPoint.y));
            y = (lastPoint.y + i * (size * step) * (downPoint.y - lastPoint.y) / SDDistance2D(lastPoint.x, lastPoint.y, downPoint.x, downPoint.y));
            
            brushRect = CGRectMake(x - (size / 2), y - (size / 2), size, size);
            
            CGContextFillEllipseInRect(context, brushRect);
            
            [layer setNeedsDisplayInRect:(*(NSRect *)&brushRect)];
            
            i++;
        }
        while (SDDistance2D(x, y, downPoint.x, downPoint.y) > (size * step) && SDInBetween(lastPoint.x, lastPoint.y, x, y, downPoint.x, downPoint.y));
        
        theEvent = [[canvas window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if (([theEvent type] == NSLeftMouseUp)) {
            break;
        }
        
        lastPoint = downPoint;
        [canvas autoscroll:theEvent];
    }
    
    commitRect = NSIntegralRect(NSInsetRect(commitRect, -1, -1));
    
    [layer commitFrameOfDrawableContext:commitRect];
}




@end
