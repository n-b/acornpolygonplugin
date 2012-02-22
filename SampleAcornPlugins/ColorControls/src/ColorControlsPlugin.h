
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "ACPlugin.h"
#import "CCWindowControler.h"

@interface ColorControlsPlugin : NSObject <ACPlugin> {
    CCWindowControler *_windowController;
}

@property (retain) CCWindowControler *windowController;

- (CCWindowControler *)windowController;
- (void)setWindowController:(CCWindowControler *)newWindowController;



@end
