//
//  Zombie.h
//  zombieShooter
//
//  Created by Franco Arolfo on 12/1/13.
//  Copyright (c) 2013 Franco Arolfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "AStar.h"
#import "HelloWorldLayer.h"

@interface Zombie : NSObject

- (id) initZombieAtX: (float) x y: (float) y inSpace: (ChipmunkSpace *) space graph: (Graph *) graph andLayer: (HelloWorldLayer *) gameLayer;

- (CCPhysicsSprite *) createSprite;

- (void) moveNextPosition;

- (void) updatePathToX: (float) x andY: (float) y;

@property Boolean shouldUpdateGraph;

@property (strong) AStar * aStar;

@property (strong) CCPhysicsSprite * zombie;
@property (strong) ChipmunkBody * targetPointBody;
@property (strong) ChipmunkBody * zombieBody;

@property (strong) CCLayer * gameLayer;

@property float x;
@property float y;

@property (strong) NSMutableArray * nextPositions;

@property (strong) ChipmunkSpace * space;

@end
