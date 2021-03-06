//
//  InterfaceController.m
//  SpriteKitWatchFace WatchKit Extension
//
//  Created by Steven Troughton-Smith on 09/10/2018.
//  Copyright © 2018 Steven Troughton-Smith. All rights reserved.
//

#import "InterfaceController.h"
#import "FaceScene.h"

@import ObjectiveC.runtime;
@import SpriteKit;

@interface NSObject (fs_override)
+(id)sharedApplication;
-(id)keyWindow;
-(id)rootViewController;
-(NSArray *)viewControllers;
-(id)view;
-(NSArray *)subviews;
-(id)timeLabel;
-(id)layer;
@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"Theme":@(ThemeMarques)}];

	FaceScene *scene = [FaceScene nodeWithFileNamed:@"FaceScene"];
	
	CGSize currentDeviceSize = [WKInterfaceDevice currentDevice].screenBounds.size;
	
	/* Using the 44mm Apple Watch as the base size, scale down to fit */
	scene.camera.xScale = (184.0/currentDeviceSize.width);
	scene.camera.yScale = (184.0/currentDeviceSize.width);
	
	[self.scene presentScene:scene];
}

- (void)didAppear
{
	/* Hack to make the digital time overlay disappear */
	
	NSArray *views = [[[[[[[NSClassFromString(@"UIApplication") sharedApplication] keyWindow] rootViewController] viewControllers] firstObject] view] subviews];
	
	for (NSObject *view in views)
	{
		if ([view isKindOfClass:NSClassFromString(@"SPFullScreenView")])
			[[[view timeLabel] layer] setOpacity:0];
	}
	
	self.crownSequencer.delegate = self;
	[self.crownSequencer focus];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)onShapePress {
    FaceScene *scene = (FaceScene *)self.scene.scene;
    if (scene.faceStyle < FaceStyleMAX - 1)
        scene.faceStyle += 1;
    else
        scene.faceStyle = 0;
    [scene refreshTheme];
}

- (IBAction)onTicksPress {
    FaceScene *scene = (FaceScene *)self.scene.scene;
    if (scene.tickmarkStyle < TickmarkStyleMAX - 1)
        scene.tickmarkStyle += 1;
    else
        scene.tickmarkStyle = 0;
    [scene refreshTheme];
}

- (IBAction)onNumbersPress {
    FaceScene *scene = (FaceScene *)self.scene.scene;
    if (scene.numeralStyle < NumeralStyleMAX - 1)
        scene.numeralStyle += 1;
    else
        scene.numeralStyle = 0;
    [scene refreshTheme];
}

- (IBAction)onOutlineNumbersPress {
    FaceScene *scene = (FaceScene *)self.scene.scene;
    scene.useOutlinedNumbers = !scene.useOutlinedNumbers;
    [scene refreshTheme];
}

- (IBAction)onTickTypePress {
    FaceScene *scene = (FaceScene *)self.scene.scene;
    if (scene.majorTickmarkShape < TickmarkShapeMAX - 1)
        if (scene.minorTickmarkShape > scene.majorTickmarkShape)
            scene.majorTickmarkShape += 1;
        else
            scene.minorTickmarkShape += 1;
    else{
        scene.minorTickmarkShape = 0;
        scene.majorTickmarkShape = 0;
    }
    [scene refreshTheme];
}

- (IBAction)onFaceLeftSwipe {
    [self onRegionPress];
}

- (IBAction)onFaceRightSwipe {
    [self onTickTypePress];
}

- (IBAction)onRegionPress {
    FaceScene *scene = (FaceScene *)self.scene.scene;
    if (scene.colorRegionStyle < ColorRegionStyleMAX - 1)
        scene.colorRegionStyle += 1;
    else
        scene.colorRegionStyle = 0;
    [scene refreshTheme];
}


#pragma mark -

CGFloat totalRotation = 0;

- (void)crownDidRotate:(nullable WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
	int direction = 1;
	totalRotation += fabs(rotationalDelta);
	
	if (rotationalDelta < 0)
		direction = -1;
	
	if (totalRotation > (M_PI_4/2))
	{
		FaceScene *scene = (FaceScene *)self.scene.scene;
		
		if ((scene.theme+direction > 0) && (scene.theme+direction < ThemeMAX))
			scene.theme += direction;
		else
			scene.theme = 0;
		
		[scene refreshTheme];
		
		totalRotation = 0;
	}
}

@end



