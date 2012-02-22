//
//  ACGrayscalePlugin.h
//  acplugins
//
//  Created by August Mueller on 11/14/06.
//  Copyright 2006 Flying Meat Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "ACPlugin.h"

@interface ACSimpleDrawPlugin : NSObject <ACPlugin, ACBitmapTool> {
    
    IBOutlet NSView *paletteView;
    
}

@end
