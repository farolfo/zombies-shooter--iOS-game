#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
//#import "ChipmunkPro/ObjectiveChipmunk.h"
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "CCPhysicsSprite.h"
#import "Graph.h"
#import "AStar.h"
#import "MyPoint.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer

    @property (strong) CCTMXTiledMap * tileMap;
    @property (strong) CCTMXLayer *background;
    @property (strong) Graph * graph;
    @property (strong) CCTMXLayer * meta;
    
    @property (strong) CCPhysicsSprite * player;
    @property (strong) ChipmunkBody * targetPointBody;
    @property (strong) ChipmunkBody * playerBody;

    @property (strong) ChipmunkSpace * space;

    @property (atomic) BOOL * isTouching;

    @property CGPoint lastTouchLocation;
    @property CGPoint lastTargetPoint;

    @property (strong) NSMutableArray * nextPositions;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;


@end