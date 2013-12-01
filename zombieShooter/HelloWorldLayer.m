#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "ChipmunkAutoGeometry.h"


@interface HelloWorldLayer()

@end

@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
        
        // Setup the space. We won't set a gravity vector since this is top-down
        //space = [[ChipmunkSpace alloc] init];

        self.touchEnabled = YES;
        
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"map.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        
        // Setup the space
		_space = [[ChipmunkSpace alloc] init];
		//_space.gravity = cpv(0.0f, -400.0f);
        
        CCTMXObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objectGroup != nil, @"tile map has no objects object layer");
        
        NSDictionary *spawnPoint = [objectGroup objectNamed:@"SpawnPoint"];
        int x = [spawnPoint[@"x"] integerValue];
        int y = [spawnPoint[@"y"] integerValue];
        
        _meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;
        
        [self addChild:_tileMap z:-1];
        
        [self createPlayer:y x:x];
        [self createTerrainGeometry];
        
        [self setViewPointCenter:_player.position];
        
        _nextPositions = [[NSMutableArray alloc] init];
        
        // schedule updates, which also steps the physics space:
        [self scheduleUpdate];
        
        //[self initializeGraph];
        //[self makePlayerMove];
    }
    return self;
}

- (void)createPlayer:(int)y x:(int)x
{
    // set up the player body and shape
    float playerMass = 1.0f;
    float playerRadius = 13.0f;
    
    _playerBody = [_space add:[ChipmunkBody bodyWithMass:playerMass andMoment:INFINITY]];
    
    _player = [CCPhysicsSprite spriteWithFile:@"Player.png"];
    _player.chipmunkBody = _playerBody;
    _playerBody.pos = ccp(x,y);
    NSLog(@"[LOG] - Player body created at (%d,%d)\n", x, y);
    
    [self addChild:_player];

    ChipmunkShape *playerShape = [_space add:[ChipmunkCircleShape circleWithBody:_playerBody radius:playerRadius offset:cpvzero]];
    playerShape.friction = 0.1;
    
    _targetPointBody = [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
    _targetPointBody.pos = ccp(x,y); // make the player's target destination start at the same place the player.
    
    NSLog(@"[LOG] - Target point body created at (%d,%d)\n", x, y);
    
    ChipmunkPivotJoint* joint = [_space add:[ChipmunkPivotJoint pivotJointWithBodyA:_targetPointBody bodyB:_playerBody anchr1:cpvzero anchr2:cpvzero]];
    joint.maxBias = 200.0f;
    joint.maxForce = 3000.0f;
}

- (void)createTerrainGeometry
{
    int tileCountW = _meta.layerSize.width;
    int tileCountH = _meta.layerSize.height;
    
    cpBB sampleRect = cpBBNew(-0.5, -0.5, tileCountW + 0.5, tileCountH + 0.5);
    
    // Create a sampler using a block that samples the tilemap in tile coordinates.
    ChipmunkBlockSampler * sampler = [[ChipmunkBlockSampler alloc] initWithBlock:^(cpVect point){
                                     
        // Clamp the point so that samples outside the tilemap bounds will sample the edges.
        point = cpBBClampVect(cpBBNew(0.5, 0.5, tileCountW - 0.5, tileCountH - 0.5), point);
                                     
        // The samples will always be at tile centers.
        // So we just need to truncate to an integer to convert to tile coordinates.
        int x = point.x;
        int y = point.y;
    
        // Flip the y-coord (Cocos2D tilemap coords are flipped this way)
        y = tileCountH - 1 - y;
    
        // Look up the tile to see if we set a Collidable property in the Tileset meta layer
        NSDictionary *properties = [_tileMap propertiesForGID:[_meta tileGIDAt:ccp(x, y)]];
        BOOL collidable = [[properties valueForKey:@"Collidable"] isEqualToString:@"true"];
    
        // If the tile is collidable, return a density of 1.0 (meaning solid)
        // Otherwise return a density of 0.0 meaning completely open.
        return (collidable ? 1.0f : 0.0f);
    }];
    
    ChipmunkPolylineSet * polylines = [sampler march:sampleRect xSamples:tileCountH + 2 ySamples:tileCountH + 2 hard:TRUE];
    
    cpFloat tileW = _tileMap.tileSize.width;
    cpFloat tileH = _tileMap.tileSize.height;
    for(ChipmunkPolyline * line in polylines){
        ChipmunkPolyline * simplified = [line simplifyCurves:0.0f];
        
        for(int i=0; i<simplified.count-1; i++){
            
            // The sampler coordinates were in tile coordinates.
            // Convert them to pixel coordinates by multiplying by the tile size.
            cpFloat tileSize = tileH; // fortunately our tiles are square, otherwise we'd need to multiply components independently
            cpVect a = cpvmult(simplified.verts[  i], tileSize);
            cpVect b = cpvmult(simplified.verts[i+1], tileSize);
            
            // Add the shape and set some properties.
            ChipmunkShape *seg = [_space add:[ChipmunkSegmentShape segmentWithBody:_space.staticBody from:a to:b radius:1.0f]];
            seg.friction = 1.0;
        }
    }
}

-(void)update:(ccTime)dt
{
    // update player motion based on last touch, if we have our finger down:
    if(_isTouching){
        _targetPointBody.pos = _lastTouchLocation;
        NSLog(@"[LOG] - touching at (%f,%f)\n", _lastTouchLocation.x, _lastTouchLocation.y);
    }
    // Update the physics
    ccTime fixed_dt = [CCDirector sharedDirector].animationInterval;
    [_space step:fixed_dt];
    
    //update camera
    [self setViewPointCenter:_playerBody.pos];
}

- (void) makePlayerMove
{
    AStar * aStar = [[AStar alloc] initWithGraph: _graph ];

    _nextPositions = [aStar executeAlgorithmFromX: 34 andY: 34 toX: 44 andY: 44];
    
    [self schedule:@selector(move) interval:1];
}

- (void) move
{
    if ( [_nextPositions count] == 0 ) {
        return;
    }
    
    MyPoint * point = [_nextPositions objectAtIndex:[_nextPositions count]-1];
    [_nextPositions removeLastObject];
}

- (void) initializeGraph
{
    int y,x,i;
    _graph = [[Graph alloc] initWithCollumns:_tileMap.mapSize.width andRows:_tileMap.mapSize.height];
    for ( x = 0; x < _tileMap.mapSize.width; x++) {
        for ( y = 0; y < _tileMap.mapSize.height; y++) {
            NSDictionary * props = [_tileMap propertiesForGID: [_background tileGIDAt: CGPointMake(x, y)]];
            if ( ! [[props objectForKey:@"walkable"] isEqualToString:@"NO"] ){
                [_graph addNodeWithX:x andY:y];
            }
        }
    }
    for ( x = 0; x < _tileMap.mapSize.width; x++) {
        for ( y = 0; y < _tileMap.mapSize.height; y++) {
            if ( [ self isNodeWalkableAtX: x andY: y ] ){
                NSMutableArray * siblingWalkableNodes = [self getSiblingWalkableNodesFromX: x andY: y];
                for (i = 0; i < [siblingWalkableNodes count]; i++) {
                    [_graph addEdgeFromNode:[_graph getNodeWithX:x andY:y] toNode:[siblingWalkableNodes objectAtIndex: i] directed:false];
                }
            }
        }
    }
}

- (Boolean) isNodeWalkableAtX: (int) x andY: (int) y
{
    NSDictionary * props = [_tileMap propertiesForGID: [_background tileGIDAt: CGPointMake(x, y)]];
    return  ! [[props objectForKey:@"walkable"] isEqualToString:@"NO"];
}

- (NSMutableArray *) getSiblingWalkableNodesFromX: (int) x andY: (int) y
{
    NSMutableArray * siblingWlakableNodes = [[NSMutableArray alloc] init];
    [self addAsSiblingNodeWithX: x + 1 andY: y in: siblingWlakableNodes];
    [self addAsSiblingNodeWithX: x - 1 andY: y in: siblingWlakableNodes];
    [self addAsSiblingNodeWithX: x andY: y + 1 in: siblingWlakableNodes];
    [self addAsSiblingNodeWithX: x andY: y - 1 in: siblingWlakableNodes];
    return siblingWlakableNodes;
}

- (void) addAsSiblingNodeWithX: (int) x andY: (int) y in: (NSMutableArray *) siblingWlakableNodes
{
    if ( [self isOutOfBoundX: x andY: y] ) {
        return;
    }
    
    if ( [self isNodeWalkableAtX: x andY: y] ) {
        [siblingWlakableNodes addObject: [_graph getNodeWithX: x andY: y]];
    }
    
    return;
}

- (Boolean) isOutOfBoundX: (int) x andY: (int) y
{
    return x < 0 || y < 0 || x >= _tileMap.mapSize.height || y >= _tileMap.mapSize.width;
}

- (void)setViewPointCenter:(CGPoint) position {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int x = MAX(position.x, winSize.width/2);
    int y = MAX(position.y, winSize.height/2);
    
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

#pragma mark - handle touches
-(void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:0
                                                       swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    _lastTouchLocation.x = touchLocation.x;
    _lastTouchLocation.y = touchLocation.y;
    
    NSLog(@"[LOG] - Touch began at (%f,%f)\n", touchLocation.x, touchLocation.y);
    
    _isTouching = true;

	return YES;
}

-(void)setPlayerPosition:(CGPoint)position {
	_player.position = position;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    NSLog(@"[LOG] - Touch ended at (%f,%f)\n", touchLocation.x, touchLocation.y);
    
    _isTouching = false;
}


@end