//
//  AcornPolygonPlugin.m
//  AcornPolygonPlugin
//
//  Created by Nicolas Bouilleaud on 22/02/12.
//  Copyright (c) 2012 Awesome Monkeys. All rights reserved.

#import "AcornPolygonPlugin.h"

@implementation AcornPolygonPlugin

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (id) init {
    
    if ((self = [super init])) {
    }
    
    return self;
}

- (void) willRegister:(id<ACPluginManager>)pluginManager
{
    [pluginManager addFilterMenuTitle:@"Polygon Shape"
                   withSuperMenuTitle:@"Generator"
                               target:self
                               action:@selector(showPolygonGenerator:userObject:)
                        keyEquivalent:@"P"
            keyEquivalentModifierMask:NSCommandKeyMask|NSAlternateKeyMask|NSShiftKeyMask
                           userObject:nil];
}


- (void) didRegister {
}

- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return @YES;
}

- (CIImage*) showPolygonGenerator:(id<ACShapeLayer>)layer_ userObject:(id)userObject_
{
    if([layer_ layerType] == ACShapeLayer)
    {
        NSLog(@"ShaperLayer whit graphics : %@",[layer_ graphics]);
        [layer_ addBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 19, 20)]];
    }
    
    return nil;
}

@end
