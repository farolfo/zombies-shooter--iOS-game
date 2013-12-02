//
//  AStar.m
//  TileGame
//
//  Created by Franco Arolfo on 11/7/13.
//  Copyright (c) 2013 charlie. All rights reserved.
//

#import "AStar.h"
#import "MyPoint.h"

@implementation AStar

- (id) initWithGraph: (Graph *) graph andTileSize: (CGSize) tileSize
{
    if ( self = [super init] ) {
        self.graph = graph;
        self.tileSize = tileSize;
    }
    return self;
}

- (Node *) getLowestNodeIn: (NSMutableArray *) array
{
    int size = [array count], i;

    if ( size == 0 ) {
        return nil;
    }
    
    Node * solution = [array objectAtIndex:0];
    for ( i = 1; i < size; i++){
        Node * current = [array objectAtIndex:i];
        if ( [current getF] < [solution getF] ) {
            solution = current;
        }
    }
    return solution;
}

-(int) getManhattanDistanceFromX1: (int) x1 y1: (int) y1 toX2: (int) x2 y2: (int) y2
{
    int yDiff = y2 - y1;
    int xDiff = x2 - x1;
    
    if ( yDiff < 0 ) {
        yDiff *= -1;
    }
    if ( xDiff < 0 ) {
        xDiff *= -1;
    }
    
    return xDiff + yDiff;
}

- (int) numberFromPixelInX: (int) num
{
    return floor(num / self.tileSize.width);
}

- (int) numberFromPixelInY: (int) num
{
    return 49 - floor(num / self.tileSize.height);
}

- (NSMutableArray *) executeAlgorithmFromX: (int) x1 andY: (int) y1 toX: (int) x2 andY: (int) y2
{
    int i = 0;
    
    x1 = [self numberFromPixelInX: x1];
    x2 = [self numberFromPixelInX: x2];
    y1 = [self numberFromPixelInY: y1];
    y2 = [self numberFromPixelInY: y2];
    
    printf("x1: %d - x2: %d - y1: %d - y2: %d\n", x1, x2, y1, y2);
    
    Node * nodeInit = [self.graph getNodeWithX:x1 andY:y1];
    Node * nodeDest = [self.graph getNodeWithX:x2 andY:y2];
    
    printf("nodes are %d, %d", nodeInit, nodeDest);
    
    NSMutableArray * openList = [[NSMutableArray alloc] init];
    NSMutableArray * closedList = [[NSMutableArray alloc] init];
    
    [self.graph clearAll]; //sets G and H in 0, and parents in nil
    
    [openList addObject: nodeInit];
    
    Node * node;
    
    while ( ( node = [self getLowestNodeIn: openList] ) != nil && node != nodeDest ) {
        [openList removeObject:node];
        if ( [node isKindOfClass: [NSNull class] ] ) {
            continue;
        }
        [closedList addObject:node];
        NSMutableArray * neighbours = [node getNeighbours];
        int size = [neighbours count];
        for ( i = 0; i < size; i++) {
            Node * neighbour = [neighbours objectAtIndex:i];
            if ( [closedList containsObject: neighbour] ) {
                continue;
            }
            if ( [openList containsObject:neighbour] ) {
                if ( neighbour.g > node.g + 1 ) {
                    neighbour.parent = node;
                    neighbour.g = node.g + 1;
                    neighbour.h = [self getManhattanDistanceFromX1: neighbour.x y1: neighbour.y toX2: nodeDest.x y2: nodeDest.y];
                }
            } else if ( ! [neighbour isKindOfClass: [NSNull class] ] ) {
                [openList addObject:neighbour];
                neighbour.parent = node;
                neighbour.g = node.g + 1;
                neighbour.h = [self getManhattanDistanceFromX1: neighbour.x y1: neighbour.y toX2: nodeDest.x y2: nodeDest.y];
            }
        }
    }
    
    NSMutableArray * path = [[NSMutableArray alloc] init];
    
    while ( node != nil ) {
        [path addObject:[[MyPoint alloc] initWithX: node.x andY: node.y]];
        node = node.parent;
    }
    
    return path;
}

@end
