//
//  AStar.h
//  TileGame
//
//  Created by Franco Arolfo on 11/7/13.
//  Copyright (c) 2013 charlie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Graph.h"

@interface AStar : NSObject
@property (nonatomic) CGSize tileSize;
@property (nonatomic) Graph * graph;

- (id) initWithGraph: (Graph *) graph andTileSize: (CGSize) tileSize;

// Returns an ordered set of CGPoints that are every move that needs to be done
// If destiny is not reachable, returns nil
- (NSMutableArray *) executeAlgorithmFromX: (int) x1 andY: (int) y1 toX: (int) x2 andY: (int) y2;

@end
