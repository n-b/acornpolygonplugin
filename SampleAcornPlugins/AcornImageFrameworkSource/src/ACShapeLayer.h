//
//  ACShapeLayer.h
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACLayer.h"

@interface ACShapeLayer : ACLayer {
    NSDictionary *_properties;
    
}

- (NSDictionary *)properties;
- (void)setProperties:(NSDictionary *)newProperties;


@end
