//
//  Graph.m
//  TileGame
//
//  Created by Franco Arolfo on 10/31/13.
//  Copyright (c) 2013 charlie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Graph.h"

@implementation Graph : NSObject

- (id) initWithCollumns:(int)collumns andRows:(int)rows
{
    if ( self = [super init] ){
        self.collumns = collumns;
        self.rows = rows;
        self.nodes = [[NSMutableArray alloc] initWithCapacity: collumns * rows];
        [self fillArrayAsEmpty];
    }
    return self;
}

- (void) clearAll
{
    int size = [self.nodes count], i;
    for ( i = 0; i < size; i++) {
        Node * node = [self.nodes objectAtIndex:i];
        if ( ! [node isKindOfClass: [NSNull class]] ) {
            [node clearAll];
        }
    }
}

- (void) fillArrayAsEmpty {
    int size = self.collumns * self.rows, i = 0;
    for ( i = 0; i < size; i++ ) {
        [self.nodes addObject:[NSNull null]];
    }
}

- (int) getIndexWithX: (int) x andY: (int) y
{
    return y * self.collumns + x;
}

- (Node *) getNodeWithX:(int) x andY:(int) y;
{
    return [ self.nodes objectAtIndex: [self getIndexWithX: x andY: y ] ];
}
 
- (Node *) addNodeWithX: (int) x andY:(int) y
{
    int index = [self getIndexWithX: x andY: y];
    NSObject * node = [self getNodeWithX: x andY: y];
    
    if ( [node isKindOfClass: [NSNull class] ]) {
        node = [[Node alloc] initWithX:x andY:y ];
        [self clearAll];
        [self.nodes replaceObjectAtIndex: index withObject: node];
    }
    
    return (Node *) node;
}

- (Boolean) addEdgeFromNode:(Node *) node1 toNode:(Node *) node2 directed:(Boolean) value
{
    if ( [node1 isKindOfClass:[NSNull class]] || [node2 isKindOfClass:[NSNull class]]) {
        return false;
    }
    [node1 addEdgeTo: node2];
    if ( value ) {
        [node2 addEdgeTo: node1];
    }
    return true;
}

@end


@implementation Node : NSObject

-(id) initWithX: (int)x andY:(int)y
{
    if ( self = [super init] ){
        self.x = x;
        self.y = y;
        self.edges = [[NSMutableArray alloc] init];
        self.neighbours = nil;
    }
    return self;
}

-(NSMutableArray *) calculateNeighbours
{
    NSMutableArray * neighbours = [[NSMutableArray alloc] init];
    int size = [self.edges count], i;
    for ( i = 0; i < size; i++) {
        [neighbours addObject:((Edge *)[self.edges objectAtIndex:i]).node];
    }
    return neighbours;
}

-(NSMutableArray *) getNeighbours
{
    if ( self.neighbours == nil ) {
        self.neighbours = [self calculateNeighbours];
    }
    
    return self.neighbours;
}

-(Boolean) addEdgeTo: (Node *) node
{
    if ( ! [self.edges containsObject: node] ) {
        [self.edges addObject: [[Edge alloc] initToNode: node] ];
        return true;
    }
    return false;
}

-(void) clearAll
{
    _g = 0;
    _h = 0;
    _parent = nil;
}

-(int) getF
{
    return _g + _h;
}

@end


@implementation Edge

-(id) initToNode:(Node *) node
{
    if ( self = [super init] ){
        self.node = node;
    }
    return self;
}

@end


