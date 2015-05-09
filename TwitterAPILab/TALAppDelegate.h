//
//  TALAppDelegate.h
//  TwitterAPILab
//
//  Created by Tong G. on 4/9/15.
//
//

#import <Cocoa/Cocoa.h>
#import "Objectwitter-C.h"

@class STTwitterAPI;

@interface TALAppDelegate : NSObject <NSApplicationDelegate, NSURLSessionDataDelegate>

@property (assign) IBOutlet NSWindow *window;

@property ( copy ) NSURLSession* defaultSession;
    @property ( strong ) NSURLSessionDataTask* dataTask;
    @property ( strong ) NSMutableData* receivedData;

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

@property ( weak ) IBOutlet NSTextField* userScreenNameTextField;
@property ( weak ) IBOutlet NSButton* GETUserTimelineButton;
- ( IBAction ) GETUserTimelineAction: ( id )_Sender;

@property ( weak ) IBOutlet NSTextField* userIDTextField;
@property ( weak ) IBOutlet NSButton* fetchUserTimelineWithStreamingAPIButton;

@property (nonatomic, retain) STTwitterStreamParser *streamParser;

@end

NSString* TGSignWithHMACSHA1( NSString* _SignatureBaseString, NSString* _SigningKey );
NSString* TGTimestamp();
NSString* TGNonce();
NSString* TGSignatureBaseString( NSString* _HTTPMethod, NSURL* _APIURL, NSArray* _RequestParams );
NSString* TGPercentEncodeString( NSString* _String );
NSString* TGPercentEncodeURL( NSURL* _URL );
NSString* TGAuthorizationHeaders( NSArray* _RequestParams );