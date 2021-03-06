//
//  SketchyViewController.m
//  Sketchy

/*
 The MIT License
 
 This is a version of the popular kids Etcha-A-Sketch game. I wrote this app originally for 
 sale in the App Store, where it eventually ended up. However, I thought the game was old enough 
 to be out of copyright. I was wrong and they (The Ohio Art Company, and Freeze Tag) told me so 
 and I pulled it.
 
 It is important to note that this is still the case. You cannot, you must not, try to release 
 this app or they will, quite rightly, try to sue you. This is code that has just sat idle on my 
 computer and so it might as well get out there and be of use to people learning how to program for iOS. 
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE. 
 */

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "SketchyViewController.h"

#include "DLog.h"

#import "SketchyAppDelegate.h"
#import "RotaryDial.h"
#import "UIView+Snapshot.h"

@implementation SketchyViewController

@synthesize sketchingSpace, sketchyTitle, rotaryDialUpDown, rotaryDialLeftRight;

#define kDestructiveOptionsSheetTag 1
#define kSaveOptionsSheetTag 2

#define kPhoneDialRotationAttenuation 10
#define kPadDialRotationAttenuation 10

#define kStylusModifier 2.0

#pragma mark -

// I donwe if there is any maths we could do to calculate these values?

#define kiPhoneDialSizeEnlarged 150
#define kiPhoneDialSize (kiPhoneDialSizeEnlarged/2)
#define kiPhoneDialEdgePadding 8
-(void)resizeUIForPhone {
	switch(self.interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:	
			[sketchingSpace setFrame:CGRectMake(13, 24, 295, 360)];
			[rotaryDialUpDown setFrame:CGRectMake(0, 376, 85, 85)];		
			[rotaryDialLeftRight setFrame:CGRectMake(238, 376, 85, 85)];
			[sketchyTitle setFrame:CGRectMake(106, 405, 108, 30)];
			break;
			
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			[sketchingSpace setFrame:CGRectMake(20, 16, 440, 235)];
			[rotaryDialUpDown setFrame:CGRectMake(kiPhoneDialEdgePadding, 236, kiPhoneDialSize, kiPhoneDialSize)];		
			[rotaryDialLeftRight setFrame:CGRectMake(396, 236, kiPhoneDialSize, kiPhoneDialSize)];
			[sketchyTitle setFrame:CGRectMake(186, 259, 108, 30)];
			break;
	}
}

// make the dials grow/shrink under the users finger 
// on the iPhone so it's easy to use
-(void)resizeDial:(RotaryDial*)dial enlarged:(BOOL)enlarged{
	if([SketchyAppDelegate isPhoneIdiom]) {
		CGPoint center = dial.center;
		CGRect frame = dial.frame;
				
		if(enlarged == NO && dial.frame.size.width != kiPhoneDialSize) {
			frame.size.width = kiPhoneDialSize;
			frame.size.height = kiPhoneDialSize;

			[UIView beginAnimations:@"DialGrowShrinkAnimation" context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:0.5];
				dial.frame = frame;
			[UIView commitAnimations];	
			
			dial.center = center;		
		} else if(enlarged == YES && dial.frame.size.width != kiPhoneDialSizeEnlarged) {
			frame.size.width = kiPhoneDialSizeEnlarged;
			frame.size.height = kiPhoneDialSizeEnlarged;			
			[UIView beginAnimations:@"DialGrowShrinkAnimation" context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:0.1];
				dial.frame = frame;
			[UIView commitAnimations];	
			dial.center = center;		
		}	
	}
}


#define kiPadDialSize 150
#define kiPadDialEdgePadding 10
-(void)resizeUIForPad {
	switch(self.interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:	
			[sketchingSpace setFrame:CGRectMake(38, 58, 696, 776)];
			[rotaryDialUpDown setFrame:CGRectMake(kiPadDialEdgePadding, 845, kiPadDialSize, kiPadDialSize)];		
			[rotaryDialLeftRight setFrame:CGRectMake(608, 845, kiPadDialSize, kiPadDialSize)];
			[sketchyTitle setFrame:CGRectMake(204, 870, 360, 100)];
			break;
			
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			[sketchingSpace setFrame:CGRectMake(47, 43, 930, 578)];
			[rotaryDialUpDown setFrame:CGRectMake(kiPadDialEdgePadding, 610, kiPadDialSize, kiPadDialSize)];		
			[rotaryDialLeftRight setFrame:CGRectMake(864, 610, kiPadDialSize, kiPadDialSize)];
			[sketchyTitle setFrame:CGRectMake(332, 634, 360, 100)];
			break;
	}
}

-(void)resizeUI {
	if([SketchyAppDelegate isPhoneIdiom]) {
		[self resizeUIForPhone];
	} else {
		[self resizeUIForPad];
	}
}


#pragma mark -
#pragma mark Credits

static inline CGFloat degreesToRadians(CGFloat degrees)
{
    return M_PI * (degrees / 180.0);
}


#define kCreditsViewTag 0x01

-(IBAction)showCredits {
	NSString* imageName = nil;

	AudioServicesPlaySystemSound(buttonClickSoundEffect);		
	
	{
		// TODO: make orientation a stringByReplacingOrientationPLaceholder
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		switch(orientation) {
			case UIInterfaceOrientationPortrait:
			case UIInterfaceOrientationPortraitUpsideDown:
				imageName = [[SketchyAppDelegate stringByReplacingUserInterfaceIdiomPlaceholder:@"BackCredits-portrait-{idiom}.png"] retain];
				break;
				
			case UIInterfaceOrientationLandscapeLeft:
			case UIInterfaceOrientationLandscapeRight:
				imageName = [[SketchyAppDelegate stringByReplacingUserInterfaceIdiomPlaceholder:@"BackCredits-landscape-{idiom}.png"] retain];
				break;
		}
	}
	
	UIImageView *credits = nil;
	credits = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	[imageName release];
	credits.tag = kCreditsViewTag;
		
	[UIView beginAnimations:@"FlipToCredits" context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	[self.view addSubview:credits];
	[UIView commitAnimations];
	
	[credits release];	
	
	sketchyTitle.userInteractionEnabled = NO;
}

-(BOOL)removeCreditsIfShown {
	UIView* credits = [self.view viewWithTag:kCreditsViewTag];
	
	if(credits) {
		[UIView beginAnimations:@"FlipFromCredits" context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[credits removeFromSuperview];
		[UIView commitAnimations];

		sketchyTitle.userInteractionEnabled = YES;		
		
		return YES;
	}
		
	return NO;
}

#pragma mark -
#pragma mark Handle Shaking

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {	
	[super motionBegan:motion withEvent:event];
	
	if(self.modalViewController == nil) {
		if(motion == UIEventSubtypeMotionShake) {
			AudioServicesPlaySystemSound(shakingSoundEffect);
			
			if([self removeCreditsIfShown] == NO) {				
				UIActionSheet* optionsSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ClearConfirmation", @"")
																		  delegate:self 
																 cancelButtonTitle:nil
															destructiveButtonTitle:NSLocalizedString(@"YesText",@"")
																 otherButtonTitles:NSLocalizedString(@"NoText", @""), nil];
				
				optionsSheet.tag = kDestructiveOptionsSheetTag;
				
				[optionsSheet showInView:self.view];
				
				[optionsSheet autorelease];
			}
		}	
	}
}

#pragma mark -
#pragma mark Touches

-(IBAction)onUp:(id)sender {
	DLog(@"onUp:");
	
	if([sketchingSpace addStylusPositionChangeXMovement:0 yMovement:-kStylusModifier]) {
		[rotaryDialUpDown rotateByDegrees:+dialRotationAttenuation];
	} else {
		AudioServicesPlaySystemSound(dinkSoundEffect);
	}
}

-(IBAction)onDown:(id)sender {
	DLog(@"onDown:");
	
	if([sketchingSpace addStylusPositionChangeXMovement:0 yMovement:+kStylusModifier]) {
		[rotaryDialUpDown rotateByDegrees:-dialRotationAttenuation];
	} else {
		AudioServicesPlaySystemSound(dinkSoundEffect);
	}
}

-(IBAction)onLeft:(id)sender {
	DLog(@"onLeft:");
	
	if([sketchingSpace addStylusPositionChangeXMovement:-kStylusModifier yMovement:0]) {
		[rotaryDialLeftRight rotateByDegrees:-dialRotationAttenuation];
	} else {
		AudioServicesPlaySystemSound(dinkSoundEffect);
	}
}

-(IBAction)onRight:(id)sender {
	DLog(@"onRight:");	
	
	if([sketchingSpace addStylusPositionChangeXMovement:+kStylusModifier yMovement:0]) {
		[rotaryDialLeftRight rotateByDegrees:+dialRotationAttenuation];
	} else {
		AudioServicesPlaySystemSound(dinkSoundEffect);
	}
}

#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	UIView *touchView = touch.view;
	
	if([self removeCreditsIfShown] == NO) { 
		if(touch.tapCount > 1 && touchView == sketchingSpace) {	
			UIActionSheet* optionsSheet = [[UIActionSheet alloc] initWithTitle:nil
																	  delegate:self 
															 cancelButtonTitle:NSLocalizedString(@"CancelText", @"")
														destructiveButtonTitle:nil
															 otherButtonTitles:NSLocalizedString(@"SaveTitle", @""), 
										   ([MFMailComposeViewController canSendMail]) ? NSLocalizedString(@"EmailTitle",@"") : nil, nil];
			
			optionsSheet.tag = kSaveOptionsSheetTag;
			
			[optionsSheet showInView:touchView.superview];
			
			[optionsSheet autorelease];
		}
	}
}

#define kIsNotARotaryDial 0
#define kIsRotaryDialUpDown 1
#define kIsRotaryDialLeftRight 2
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	NSUInteger rotaryDialIdentifier = kIsNotARotaryDial;
	UITouch *touch = [touches anyObject];
	UIView *touchView = touch.view;
		
	if(touchView == rotaryDialUpDown) {
		rotaryDialIdentifier = kIsRotaryDialUpDown;
		[self resizeDial:(RotaryDial*)touchView enlarged:YES];
	} else if(touchView == rotaryDialLeftRight) {
		rotaryDialIdentifier = kIsRotaryDialLeftRight;
		[self resizeDial:(RotaryDial*)touchView enlarged:YES];
	}
	
	if(rotaryDialIdentifier > kIsNotARotaryDial) {
		wasDrawGesture = YES;

		CGPoint lastPosition = [touch previousLocationInView:touch.view];
		CGPoint currentPosition = [touch locationInView:touch.view];
		CGFloat yDiff = lastPosition.y - currentPosition.y;
		
		//TODO: attenuate for iPhone?
		if(abs(yDiff) > 3) {			
			// if the first touch we got was in the left side of the button
			// and it's incresing the Y, this must be a down twist
			// otherwise it's an up twist
			if(lastPosition.x < (touchView.frame.size.width / 2.0)) {
				if(yDiff > 0) {
					// turning dial up
					DLog(@"turning dial up on left");
					(rotaryDialIdentifier == kIsRotaryDialUpDown) ? [self onUp:touchView] : [self onRight:touchView];
				} else {
					// turning dial down
					DLog(@"turning dial down on left");
					(rotaryDialIdentifier == kIsRotaryDialUpDown) ? [self onDown:touchView] : [self onLeft:touchView];
				}
			} else {
				if(yDiff > 0) {
					// turning dial down
					DLog(@"turning dial down on right");
					(rotaryDialIdentifier == kIsRotaryDialUpDown) ? [self onDown:touchView] : [self onLeft:touchView];
				} else {
					// turning dial up
					DLog(@"turning dial up on right");
					(rotaryDialIdentifier == kIsRotaryDialUpDown) ? [self onUp:touchView] : [self onRight:touchView];
				}
			}
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];

	{
		UITouch *touch = [touches anyObject];
		UIView *touchView = touch.view;
		
		if(touchView == rotaryDialUpDown) {
			[self resizeDial:(RotaryDial*)touchView enlarged:NO];
		} else if(touchView == rotaryDialLeftRight) {
			[self resizeDial:(RotaryDial*)touchView enlarged:NO];
		}	
	}
	
	if(wasDrawGesture == NO) {
		UIView *touchView = [(UITouch *)[touches anyObject] view];
		
		if(touchView == rotaryDialLeftRight || touchView == rotaryDialUpDown) {	
			if([sketchingSpace undo]) {
				AudioServicesPlaySystemSound(buttonClickSoundEffect);
			}
		}
	}
	
	wasDrawGesture = NO;		
	sketchyTitle.alpha = 1.0;
}

//#pragma mark -

//-(void)actionRotaryDialTapped:(id)sender {
//	[sketchingSpace showStylusPosition];
//}

#pragma mark -
#pragma mark Save/Load Work In Progress

#define kStylusPointsDataKey @"StylusPoints"
#define kStylusPointsDataFilename @"stylusPoints.dat"

-(void)saveCurrentState {
	// serialise out of sketchingSpace.stylusPoints 
	NSString* dataPath = [[[SketchyAppDelegate documentsDirectory] stringByAppendingPathComponent:kStylusPointsDataFilename] retain]; 
	
	NSMutableData *stateInfo = [NSMutableData data];
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:stateInfo];
	
	[archiver encodeObject:sketchingSpace.stylusPoints forKey:kStylusPointsDataKey];
	
	[archiver finishEncoding];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		[[NSFileManager defaultManager] createFileAtPath:dataPath contents:stateInfo attributes:nil];
	}
	else {
		//BOOL result = 
		[stateInfo writeToFile:dataPath atomically:YES];
	}
	
	[archiver release];
	[dataPath release];
}

-(void)loadCurrentState {
	NSString* dataPath = [[[SketchyAppDelegate documentsDirectory] stringByAppendingPathComponent:kStylusPointsDataFilename] retain]; 
	
	// deserialise into sketchingSpace.stylusPoints 
	if([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		NSData *stateInfo = [[NSFileManager defaultManager] contentsAtPath:dataPath];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:stateInfo];
		
		[sketchingSpace.stylusPoints setArray:[unarchiver decodeObjectForKey:kStylusPointsDataKey]];
		
		[unarchiver finishDecoding];
		
		[unarchiver release];
		
		sketchingSpace.showCurrentPointOnNextDisplay = YES;
		
		[sketchingSpace setNeedsDisplay];
	}
	
	[dataPath release];	
}

-(void)releaseCurrentState {
	[sketchingSpace.stylusPoints removeAllObjects];
}

#pragma mark -
#pragma mark Copy The Sketch To Photo Album

-(void)animationWillStart:(NSString *)animationID context:(void *)context {
	AudioServicesPlaySystemSound(cameraClickSoundEffect);	
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	UIImage* snapshot = [[self.view takeSnapshot] retain];
	UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil);
	[snapshot release];
	
	[(UIView*)context removeFromSuperview];
}

-(void)actionSketchToPhotosAlbum {
	CGRect flashRect = self.view.superview.frame;
	
	switch([[UIApplication sharedApplication] statusBarOrientation]) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			//flashRect.size = CGSizeMake(flashRect, flashRect);
			break;
			
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			flashRect.size = CGSizeMake(flashRect.size.height, flashRect.size.width);
			break;
	}
	
	UIView *flash = [[UIView alloc] initWithFrame:flashRect];
	flash.backgroundColor = [UIColor clearColor];
	[self.view addSubview:flash];
	[self.view bringSubviewToFront:flash];
	[flash release];
	
	[UIView beginAnimations:@"Flash" context:flash];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationWillStartSelector:@selector(animationWillStart:context:)];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:1];
	flash.backgroundColor = [UIColor whiteColor];
	flash.backgroundColor = [UIColor clearColor];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Email The Sketch

- (void)actionMailSketch {
	if([MFMailComposeViewController canSendMail]) {		
		UIImage* snapshot = [[self.view takeSnapshot] retain];
		MFMailComposeViewController* mcvc = [[MFMailComposeViewController alloc] init];
		
		[mcvc setSubject:NSLocalizedString(@"EmailSubject", @"")];			
		[mcvc setMessageBody:NSLocalizedString(@"EmailMessage", @"") isHTML:NO];
		[mcvc addAttachmentData:UIImagePNGRepresentation(snapshot) mimeType:@"image/png" fileName:@"sketch.png"];
		[mcvc setMailComposeDelegate:self];
				
		[self presentModalViewController:mcvc animated:YES];
		
		[self resignFirstResponder];

		[mcvc release];
		[snapshot release];
	} else {
		//TODO: error
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
	
	[self becomeFirstResponder];
	
	if(error != nil && error.code != NSUserCancelledError) {
		//NSString* title = ([controller respondsToSelector:@selector(title)]) ? [controller title] : nil;
		
		//[[ShazamErrorHandler instance] showAlertUsingError:error title:title];	
	}
}

#pragma mark -
#pragma mark Popup Menu

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	//if(buttonIndex == [actionSheet destructiveButtonIndex]) {
	//	AudioServicesPlaySystemSound(shakingSoundEffect);
	//
	//	// clear
	//	[sketchingSpace clear];
	//} else if(buttonIndex == [actionSheet cancelButtonIndex]) {
	//	// cancel, do nothing
	//} else 
	if(actionSheet.tag == kDestructiveOptionsSheetTag) {
		switch (buttonIndex) {
			case 0:
				DLog(@"Clear Screen Shake Detected");
				[sketchingSpace clear];
				break;
				
			//case 1:
			//	DLog(@"Undo Shake Detected");
			//	[sketchingSpace undo];
			//	break;
		}
	} else {
		switch(buttonIndex) {
			case 0:		// save
				// save
				[self actionSketchToPhotosAlbum]; 
				break;
				
			case 1:		//email
				[self actionMailSketch];
				break;
		}
	}
}

#pragma mark -
#pragma mark View Methods

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

// TODO: on bg release the sound effects, then load on fg
// TODO: purge the button images on bg?

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if([SketchyAppDelegate isPhoneIdiom]) {
		dialRotationAttenuation = kPhoneDialRotationAttenuation;
	} else {
		dialRotationAttenuation = kPadDialRotationAttenuation;
	}
	
	// the shaking sound
	CFURLRef fileURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), 
											   (CFStringRef)@"shake", 
											   (CFStringRef)@"caf",
											   NULL);
	
	if(fileURL) {		
		//OSStatus status = 
		AudioServicesCreateSystemSoundID(fileURL, &shakingSoundEffect);
		
		DLog(@"AudioServicesCreateSystemSoundID:%d", (int)status);
		
		CFRelease(fileURL);
	}
	
	AudioServicesPlaySystemSound(shakingSoundEffect);
	
	// hitting the side of the screen
	fileURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), 
								   (CFStringRef)@"dink", 
								   (CFStringRef)@"caf",
								   NULL);
	
	if(fileURL) {		
		//OSStatus status = 
		AudioServicesCreateSystemSoundID(fileURL, &dinkSoundEffect);
		
		DLog(@"AudioServicesCreateSystemSoundID:%d", (int)status);
		
		CFRelease(fileURL);
	}

	// the camera click
	fileURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), 
									  (CFStringRef)@"click", 
									  (CFStringRef)@"caf",
									  NULL);
	
	if(fileURL) {		
		//OSStatus status = 
		AudioServicesCreateSystemSoundID(fileURL, &cameraClickSoundEffect);
		
		DLog(@"AudioServicesCreateSystemSoundID:%d", (int)status);
		
		CFRelease(fileURL);
	}
		
	// the button click
	fileURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), 
									  (CFStringRef)@"button_click", 
									  (CFStringRef)@"caf",
									  NULL);
	
	if(fileURL) {		
		//OSStatus status = 
		AudioServicesCreateSystemSoundID(fileURL, &buttonClickSoundEffect);
		
		DLog(@"AudioServicesCreateSystemSoundID (Button Click):%d", (int)status);
		
		CFRelease(fileURL);
	}
	
	[rotaryDialUpDown setDialImage:[UIImage imageNamed:@"button.png"]];		
	[rotaryDialLeftRight setDialImage:[UIImage imageNamed:@"button.png"]];
	
	[self resizeUI];	
	
	/*
	{
		UITapGestureRecognizer* tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionRotaryDialTapped:)];
		tapRecogniser.numberOfTapsRequired = 2;	
		[rotaryDialUpDown addGestureRecognizer:tapRecogniser];
		[tapRecogniser release];
	}
	
	{
		UITapGestureRecognizer* tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionRotaryDialTapped:)];
		tapRecogniser.numberOfTapsRequired = 2;	
		[rotaryDialLeftRight addGestureRecognizer:tapRecogniser];
		[tapRecogniser release];
	}
	*/
}

- (void)viewDidAppear:(BOOL)animated {
	[self becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated {
	[self resignFirstResponder];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.sketchingSpace = nil;
	self.sketchyTitle = nil;
	
	self.rotaryDialUpDown = nil;
	self.rotaryDialUpDown.dialImage = nil;
	
	self.rotaryDialLeftRight = nil;
	self.rotaryDialLeftRight.dialImage = nil;
	
	AudioServicesDisposeSystemSoundID(shakingSoundEffect);
	AudioServicesDisposeSystemSoundID(dinkSoundEffect);
	AudioServicesDisposeSystemSoundID(cameraClickSoundEffect);
	AudioServicesDisposeSystemSoundID(buttonClickSoundEffect);
}

#pragma mark -
#pragma mark Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	[self resizeUI];
	
	[sketchingSpace setNeedsDisplay];	
}

#pragma mark -

// we need this in order to receive motion events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

/*
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	// save the image and clear the drawing?
}
*/
  
#pragma mark -

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

- (void)dealloc {
	[sketchingSpace release];
	[sketchyTitle release];

	AudioServicesDisposeSystemSoundID(shakingSoundEffect);
	AudioServicesDisposeSystemSoundID(dinkSoundEffect);
	AudioServicesDisposeSystemSoundID(cameraClickSoundEffect);	
	AudioServicesDisposeSystemSoundID(buttonClickSoundEffect);
	
    [super dealloc];
}

@end
