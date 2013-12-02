//
//  GameOverLayer.m
//  zombieShooter
//
//  Created by Franco Arolfo on 12/2/13.
//  Copyright (c) 2013 Franco Arolfo. All rights reserved.
//

#import "GameOverLayer.h"
#import "HelloWorldLayer.h"
#import "IntroLayer.h"

@implementation GameOverLayer

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [[GameOverLayer alloc] init];
    [scene addChild: layer];
    return scene;
}

- (id) init
{
    if ((self = [super initWithColor:ccc4(255, 255, 255, 255)])) {
        
        NSString * message =@"You Lose :[";
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF * label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:32];
        label.color = ccc3(0,0,0);
        label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:label];
        
        CCScene * nextLayer = [HelloWorldLayer scene];
        
        [self runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:3],
          [CCCallBlockN actionWithBlock:^(CCNode *node) {
             [[CCDirector sharedDirector] replaceScene: nextLayer];
         }],
          nil]];
        
        
    }
    return self;
}

@end