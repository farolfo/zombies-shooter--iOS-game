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

- (id) initWithGraph: (Graph *) graph
{
    if ( self = [super init] ) {
        self.graph = graph;
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

- (NSMutableArray *) executeAlgorithmFromX: (int) x1 andY: (int) y1 toX: (int) x2 andY: (int) y2
{
    int i = 0;
     
    Node * nodeInit = [self.graph getNodeWithX:x1 andY:y1];
    Node * nodeDest = [self.graph getNodeWithX:x2 andY:y2];
    
    NSMutableArray * openList = [[NSMutableArray alloc] init];
    NSMutableArray * closedList = [[NSMutableArray alloc] init];
    
    [self.graph clearAll]; //sets G and H in 0, and parents in nil
    
    [openList addObject: nodeInit];
    
    Node * node;
    
    while ( ( node = [self getLowestNodeIn: openList] ) != nil && node != nodeDest ) {
        [openList removeObject:node];
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
            } else {
                [openList addObject:neighbour];
                neighbour.parent = node;
                neighbour.g = node.g + 1;
                neighbour.h = [self getManhattanDistanceFromX1: neighbour.x y1: neighbour.y toX2: nodeDest.x y2: nodeDest.y];
            }
        }
    }
    
    if ( node == nil ) {
        return nil;
    }
    
    NSMutableArray * path = [[NSMutableArray alloc] init];
    
    while ( node != nil ) {
        [path addObject:[[MyPoint alloc] initWithX: node.x andY: node.y]];
        node = node.parent;
    }
    
    return path;
}

@end
