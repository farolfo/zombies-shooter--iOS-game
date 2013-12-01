//
//  Graph.h
//  TileGame
//
//  Created by Franco Arolfo on 10/31/13.
//  Copyright (c) 2013 charlie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Node : NSObject

@property (nonatomic) int x;
@property (nonatomic) int y;

@property int g;
@property int h;
@property Node * parent;

@property (nonatomic) NSMutableArray * neighbours;

@property (nonatomic) NSMutableArray * edges;

-(id) initWithX: (int)x andY:(int)y;
-(Boolean) addEdgeTo: (Node *) node;
-(void) clearAll;
-(int) getF;
-(NSMutableArray *) getNeighbours;

@end

@interface Graph : NSObject

@property (nonatomic) NSMutableArray * nodes;

@property (nonatomic) int collumns;
@property (nonatomic) int rows;

- (id) initWithCollumns:(int)collumns andRows:(int)rows;

- (Node *)addNodeWithX: (int) x andY:(int) y;
- (Boolean)addEdgeFromNode:(Node *) node1 toNode:(Node *) node2 directed:(Boolean) value;
- (Node *) getNodeWithX:(int) x andY:(int) y;
- (void) clearAll;

@end

@interface Edge : NSObject

@property (nonatomic) Node* node;

-(id) initToNode: (Node *) node;

@end
