//
//  Zombie.m
//  zombieShooter
//
//  Created by Franco Arolfo on 12/1/13.
//  Copyright (c) 2013 Franco Arolfo. All rights reserved.
//

#import "Zombie.h"
#import "MyPoint.h"
#import "AStar.h"
#import "HelloWorldLayer.h"

@implementation Zombie

-(id) initZombieAtX: (float) x y: (float) y inSpace: (ChipmunkSpace *) space graph: (Graph * ) graph andLayer:(HelloWorldLayer *) gameLayer
{
    if ( self = [super init] ){
        _x = x;
        _y = y;
        _space = space;
        _nextPositions = [[NSMutableArray alloc] init];
        _gameLayer = gameLayer;
        _shouldUpdateGraph = false;
        _aStar = [[AStar alloc] initWithGraph: graph andTileSize: gameLayer.tileMap.tileSize];
    }
    return self;
}

- (CCPhysicsSprite *) createSprite
{
    // set up the player body and shape
    float zombieMass = 1.0f;
    float zombieRadius = 13.0f;
    
    _zombieBody = [_space add:[ChipmunkBody bodyWithMass:zombieMass andMoment:INFINITY]];
    
    _zombie = [CCPhysicsSprite spriteWithFile:@"zombie.png"];
    _zombie.chipmunkBody = _zombieBody;
    _zombieBody.pos = ccp(_x,_y);
    NSLog(@"[LOG] - Zombie body created at (%f,%f)\n", _x, _y);
        
    ChipmunkShape *zombieShape = [_space add:[ChipmunkCircleShape circleWithBody:_zombieBody radius:zombieRadius offset:cpvzero]];
    zombieShape.friction = 0.1;
    
    _targetPointBody = [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
    _targetPointBody.pos = ccp(_x,_y); // make the player's target destination start at the same place the player.
    
    NSLog(@"[LOG] - Target point body created at (%f,%f)\n", _x, _y);
    
    ChipmunkPivotJoint* joint = [_space add:[ChipmunkPivotJoint pivotJointWithBodyA:_targetPointBody bodyB:_zombieBody anchr1:cpvzero anchr2:cpvzero]];
    joint.maxBias = 200.0f;
    joint.maxForce = 3000.0f;
    
    return _zombie;
}

-(void) moveNextPosition
{
    if ( _nextPositions.count == 0 ) {
        return;
    }
    
    MyPoint * nextPosition = [_nextPositions objectAtIndex:_nextPositions.count];
    [_nextPositions removeLastObject];

    _targetPointBody.pos = [_gameLayer convertToNodeSpace:CGPointMake(nextPosition.x, nextPosition.y)];
}

- (void) updatePathToX: (float) x andY: (float) y
{
    _nextPositions = [_aStar executeAlgorithmFromX: _zombie.position.x andY: _zombie.position.y toX: x andY: y];
}

@end
