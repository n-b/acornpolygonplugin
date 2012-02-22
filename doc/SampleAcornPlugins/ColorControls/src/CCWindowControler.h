
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <ACPlugin.h>

@interface CCWindowControler : NSWindowController {
    CIFilter *_filter;
    
    id<ACDocument> _workingDocument;
    
}

@property (retain) id workingDocument;

- (void) doYourStuffOnDocument:(id<ACDocument>) document;

- (void) apply:(id)sender;
- (void) cancel:(id)sender;
- (void) resetAction:(id)sender;

- (void) reset;

- (CIFilter *)filter;
- (void)setFilter:(CIFilter *)newFilter;

- (id)workingDocument;
- (void)setWorkingDocument:(id)newWorkingDocument;


@end
