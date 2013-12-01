//
//  Point.m
//  TileGame
//
//  Created by Franco Arolfo on 11/14/13.
//  Copyright (c) 2013 charlie. All rights reserved.
//

#import "MyPoint.h"

@implementation MyPoint

- (id) initWithX:(int)x andY:(int)y
{
    if ( self = [super init] ) {
        self.x = x;
        self.y = y;
    }
    return self;
}

@end
