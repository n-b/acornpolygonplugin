//
//  Created by August Mueller on 6/20/07.
//  Copyright 2007 Flying Meat Inc.. All rights reserved.
//

#import "CCWindowControler.h"


@implementation CCWindowControler
@synthesize workingDocument=_workingDocument;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_filter release];
    _filter = 0x00;
    
    [_workingDocument release];
    _workingDocument = 0x00;
    
    [super dealloc];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context  {
    
    [(id<ACBitmapLayer>)[_workingDocument currentLayer] setPreviewCIImage:[_filter valueForKey:@"outputImage"]];

}

- (void) doYourStuffOnDocument:(id<ACDocument>) document {
    
    [self setWorkingDocument:document];
    [self reset];
    
    [NSApp runModalForWindow:[self window]];
}

- (BOOL) windowShouldClose:(id)sender {
    [self cancel:self];
    return YES;
}

- (void) cancel:(id)sender {
    
    [[self window] orderOut:self];
    [(id<ACBitmapLayer>)[_workingDocument currentLayer] setPreviewCIImage:nil];
    
    [self setFilter:nil];
    [self setWorkingDocument:nil];
    [NSApp stopModal];
}

- (void) apply:(id)sender {
    
    CIImage *img = [_filter valueForKey:@"outputImage"];
    
    if (img) {
        [(id<ACBitmapLayer>)[_workingDocument currentLayer] applyCIImageFromFilter:img];
    }

    [self cancel:self];
}

- (void) resetAction:(id)sender {
    [_filter setDefaults];
}

- (void) reset {
    
    CIFilter *f = [CIFilter filterWithName:@"CIColorControls"];
    
    [f setDefaults];
    
    [self setFilter:f];
    
    CIImage *img = [(id<ACBitmapLayer>)[_workingDocument currentLayer] CIImage];
    
    [_filter setValue:img forKey:@"inputImage"];
}

- (CIFilter*)filter {
    return _filter;
}

- (void)setFilter:(CIFilter *)newFilter {

    if (_filter) {
        [_filter removeObserver:self forKeyPath:@"inputSaturation"];
        [_filter removeObserver:self forKeyPath:@"inputBrightness"];
        [_filter removeObserver:self forKeyPath:@"inputContrast"];
    }

    [newFilter retain];
    [_filter release];
    _filter = newFilter;
    
    if (_filter) {
        
        [_filter addObserver:self
                  forKeyPath:@"inputSaturation" 
                     options:(NSKeyValueObservingOptionNew)
                     context:NULL];
        
        [_filter addObserver:self
                  forKeyPath:@"inputBrightness" 
                     options:(NSKeyValueObservingOptionNew)
                     context:NULL];
        
        [_filter addObserver:self
                  forKeyPath:@"inputContrast" 
                     options:(NSKeyValueObservingOptionNew)
                     context:NULL];
    }
}



@end
