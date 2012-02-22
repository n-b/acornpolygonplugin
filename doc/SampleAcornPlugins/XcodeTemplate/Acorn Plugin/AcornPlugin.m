//
//  ÇPROJECTNAMEÈ.m
//  ÇPROJECTNAMEÈ
//
//  Created by ÇFULLUSERNAMEÈ on ÇDATEÈ.
//  Copyright ÇORGANIZATIONNAMEÈ ÇYEARÈ . All rights reserved.
//

#import "ÇPROJECTNAMEÈ.h"

@implementation ÇPROJECTNAMEÈ

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (void) willRegister:(id<ACPluginManager>)pluginManager {
    
    [pluginManager addFilterMenuTitle:@"ÇPROJECTNAMEÈ"
                   withSuperMenuTitle:@"Color Adjustment"
                               target:self
                               action:@selector(convert:userObject:)
                        keyEquivalent:@""
            keyEquivalentModifierMask:0
                           userObject:nil];
}

- (void) didRegister {
    
}

- (CIImage*) convert:(CIImage*)image userObject:(id)uo {
    
    CIFilter *filter = [CIFilter filterWithName: @"CIColorMonochrome" keysAndValues: @"inputImage", image, nil];
    
    CIColor *color = [CIColor colorWithRed:0.5f green:0.5f blue:0.5f];
    
	[filter setDefaults];
	[filter setValue:color forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithFloat:1] forKey:@"inputIntensity"];
    
    return [filter valueForKey: @"outputImage"];
}

- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

@end
