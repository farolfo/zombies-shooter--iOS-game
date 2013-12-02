//
//  Projectile.m
//  zombieShooter
//
//  Created by Franco Arolfo on 12/2/13.
//  Copyright (c) 2013 Franco Arolfo. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile

-(id) initFromX: (float) fromX y: (float) fromY toX: (float) toX y: (float) toY inSpace: (ChipmunkSpace *) space andLayer:(HelloWorldLayer *) gameLayer
{
    if ( self = [super init] ){
        _fromX = fromX + [self calculateIncrementFrom: fromX to: toX];
        _fromY = fromY + [self calculateIncrementFrom: fromY to: toY];
        _toY = toY;
        _toX = toX;
        _space = space;
        _gameLayer = gameLayer;
        _triggered = false;
    }
    return self;
}

- (float) calculateIncrementFrom: (float) from to: (float) to
{
    //If the projectile touches the body of the player, it goes anywhere. So we have to initialize it a little bit far from it
    float inc = 30;
    if ( to < from ) {
        inc *= -1;
    }
    return inc;
}

- (CCPhysicsSprite *) createSprite
{
    float projectileMass = 0.5f;
    float projectileRadius = 4.0f;
    
    _projectileBody = [_space add:[ChipmunkBody bodyWithMass:projectileMass andMoment:INFINITY]];
    
    _projectile = [CCPhysicsSprite spriteWithFile:@"projectile.png"];
    _projectile.chipmunkBody = _projectileBody;
    _projectileBody.pos = ccp(_fromX, _fromY);
    
    ChipmunkShape * projectileShape = [_space add:[ChipmunkCircleShape circleWithBody:_projectileBody radius:projectileRadius offset:cpvzero]];
    projectileShape.friction = 0.0;
    
    _targetPointBody = [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
    _targetPointBody.pos = ccp(_fromX,_fromY); // make the player's target destination start at the same place the player.
        
    ChipmunkPivotJoint* joint = [_space add:[ChipmunkPivotJoint pivotJointWithBodyA:_targetPointBody bodyB:_projectileBody anchr1:cpvzero anchr2:cpvzero]];
    joint.maxBias = 200.0f;
    joint.maxForce = 3000;
    
    return _projectile;
}

- (void) trigger
{
    if ( _triggered ) {
        return;
    }
    
    _targetPointBody.pos = [_gameLayer convertToNodeSpace:CGPointMake(_toX, _toY)];
    _triggered = true;
}

@end
