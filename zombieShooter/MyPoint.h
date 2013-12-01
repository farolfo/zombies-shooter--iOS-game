//
//  Point.h
//  TileGame
//
//  Created by Franco Arolfo on 11/14/13.
//  Copyright (c) 2013 charlie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPoint : NSObject

@property (nonatomic) int x;
@property (nonatomic) int y;

- (id) initWithX: (int) x andY: (int) y;

@end
