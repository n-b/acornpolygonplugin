//
//  AcornPolygonPlugin.m
//  AcornPolygonPlugin
//
//  Created by Nicolas Bouilleaud on 22/02/12.
//  Copyright (c) 2012 Awesome Monkeys. All rights reserved.

#import "AcornPolygonPlugin.h"

@implementation AcornPolygonPlugin

+ (void) initialize
{
}

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (id) init {
    
    if ((self = [super init])) {
    }
    
    return self;
}




- (void) willRegister:(id<ACPluginManager>)pluginManager {
}

- (void) didRegister {
    
}

- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:YES];
}


- (NSString *) toolName {
    return @"Distort";
}

@end
