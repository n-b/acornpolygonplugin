
//  Created by August Mueller on 11/14/06.
//  Copyright 2006 Flying Meat Inc.. All rights reserved.
//

#import "ColorControlsPlugin.h"

// please ignore the spelling mistake.
@implementation ColorControlsPlugin
@synthesize windowController=_windowController;


+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (void) willRegister:(id<ACPluginManager>)pluginManager {
    
}

- (void) didRegister {
    
    NSMenuItem *layerMenu = 0x00;
    
    for (NSMenuItem *item in [[NSApp mainMenu] itemArray]) {
        
        if ([[item title] isEqualToString:@"Layer"]) {
            layerMenu = item;
            break;
        }
    }
    
    if (!layerMenu) {
        NSLog(@"Could not find the layer menu to add Adjust Color to.");
        return;
    }
    
    [[layerMenu submenu] addItem:[NSMenuItem separatorItem]];
    
    NSString *name = [NSString stringWithFormat:@"Adjust Color%C", 0x2026];
    
    NSMenuItem *myMenu = [[layerMenu submenu] insertItemWithTitle:name
                                                           action:@selector(bringUpColorControls:)
                                                    keyEquivalent:@""
                                                          atIndex:[[layerMenu submenu] numberOfItems]];
    [myMenu setTarget:self];
}

- (void) bringUpColorControls:(id)sender {
    
    [[[NSDocumentController sharedDocumentController] currentDocument] askToCommitCurrentAccessory];
    
    if (!_windowController) {
        CCWindowControler *controller = [[[CCWindowControler alloc] initWithWindowNibName:@"ColorControls"] autorelease];
        [self setWindowController:controller];
    }
    
    [_windowController doYourStuffOnDocument:[[NSDocumentController sharedDocumentController] currentDocument]];
    
}


- (BOOL)validateMenuItem:(NSMenuItem*)anItem {
    
    if ([anItem action] == @selector(bringUpColorControls:)) {
        
        id<ACLayer> layer = [[[NSDocumentController sharedDocumentController] currentDocument] currentLayer];
        
        return ([layer layerType] == ACBitmapLayer);
    }
    
    return YES;
}



- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}


@end
