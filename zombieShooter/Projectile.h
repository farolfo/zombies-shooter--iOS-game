//
//  Projectile.h
//  zombieShooter
//
//  Created by Franco Arolfo on 12/2/13.
//  Copyright (c) 2013 Franco Arolfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "HelloWorldLayer.h"


@interface Projectile : NSObject

- (id) initFromX: (float) fromX y: (float) fromY toX: (float) toX y: (float) toY inSpace: (ChipmunkSpace *) space andLayer: (HelloWorldLayer *) gameLayer;

- (CCPhysicsSprite *) createSprite;

- (void) trigger;

- (float) calculateIncrementFrom: (float) from to: (float) to;


@property (strong) CCPhysicsSprite * projectile;
@property (strong) ChipmunkBody * targetPointBody;
@property (strong) ChipmunkBody * projectileBody;
@property (nonatomic) Boolean triggered;

@property (strong) CCLayer * gameLayer;

@property float fromX;
@property float fromY;
@property float toX;
@property float toY;

@property (strong) ChipmunkSpace * space;

@end
