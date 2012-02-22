/*
 *  tester.m
 *  libpsd
 *
 *  Created by August Mueller on 9/18/07.
 *  Copyright 2007 Flying Meat Inc. All rights reserved.
 *
 */

#include "tester.h"


#import <AppKit/AppKit.h>
#include "libpsd.h"

int main(int argc, const char **argv) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	psd_context * pdfContext = NULL;
	psd_status status;
    
    
    status = psd_image_load(&pdfContext, (psd_char*)"/Volumes/srv/Users/gus/Desktop/fsstuff/BORKED_PSD/troubled_file_from_jcb_small.psd");
	
    
    
    [pool release];
    
    return 0;
}

