//
//  TALAppDelegate.h
//  TwitterAPILab
//
//  Created by Tong G. on 4/9/15.
//
//

#import <Cocoa/Cocoa.h>

@class STTwitterAPI;

@interface TALAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property ( retain ) STTwitterAPI* twitterAPI;
    @property ( copy ) NSString* consumerName;
    @property ( copy ) NSString* consumerKey;
    @property ( copy ) NSString* consumerSecret;

#pragma mark Authorizaton
@property ( weak ) IBOutlet NSButton* fetchRequestToken;
@property ( weak ) IBOutlet NSTextField* requestTokenLabel;
@property ( copy ) NSString* requestToken;
- ( IBAction ) fetchRequestTokenAction: ( id )_Sender;

@property ( weak ) IBOutlet NSTextField* inputPINTextField;
@property ( weak ) IBOutlet NSButton* fetchAccessTokenButton;
@property ( weak ) IBOutlet NSTextField* accessTokenLabel;
- ( IBAction ) fetchAccessToken: ( id )_Sender;

#pragma mark Statuses
@property ( weak ) IBOutlet NSButton* GETMentionsTimeLineButton;
- ( IBAction ) GETMentionsTimeLineAction: ( id )_Sender;

@end
