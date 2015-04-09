//
//  TALAppDelegate.m
//  TwitterAPILab
//
//  Created by Tong G. on 4/9/15.
//
//

#import "TALAppDelegate.h"
#import "STTwitter.h"

@implementation TALAppDelegate

@synthesize twitterAPI;
    @synthesize consumerKey;
    @synthesize consumerSecret;

- ( void ) awakeFromNib
    {
    NSURL* URLOfConsumerTokens = [ NSURL URLWithString: [ NSString stringWithFormat: @"file://%@", [ NSHomeDirectory() stringByAppendingString: @"/Documents/consumer-tokens.txt" ] ] ];
    NSString* consumerTokens = [ NSString stringWithContentsOfURL: URLOfConsumerTokens encoding: NSUTF8StringEncoding error: nil ];

    NSArray* components = [ consumerTokens componentsSeparatedByString: @"&" ];
    self.consumerName = components.firstObject;
    self.consumerKey = components[ 1 ] ;
    self.consumerSecret = components.lastObject;

    self.twitterAPI = [ STTwitterAPI twitterAPIWithOAuthConsumerName: self.consumerName
                                                         consumerKey: self.consumerKey
                                                      consumerSecret: self.consumerSecret ];
    }

#pragma mark Authorizaton
@synthesize fetchRequestToken;
@synthesize requestTokenLabel;
@synthesize requestToken = _requestToken;
- ( IBAction ) fetchRequestTokenAction: ( id )_Sender
    {
    [ self.twitterAPI postTokenRequest:
        ^( NSURL* _URL, NSString* _OAuthToken )
            {
            [ self.requestTokenLabel setStringValue: _OAuthToken ];
            [ [ NSWorkspace sharedWorkspace ] openURL: _URL ];
            }
        authenticateInsteadOfAuthorize: NO
                            forceLogin: @NO
                            screenName: @"@NSTongG"
                         oauthCallback: @"oob"
                            errorBlock: ^( NSError* _Error ) { NSLog( @"%@", _Error ); } ];
    }

@synthesize inputPINTextField;
@synthesize fetchAccessTokenButton;
- ( IBAction ) fetchAccessToken: ( id )_Sender
    {
    [ self.twitterAPI postAccessTokenRequestWithPIN: self.inputPINTextField.stringValue
                                       successBlock:
        ^( NSString* _OAuthToken, NSString* _OAuthTokenSecret, NSString* _UserID, NSString* _ScreenName )
            {
            NSString* formatString = [ NSString stringWithFormat: @"User ID: %@     Screen Name: %@     "
                                                                   "OAuth Token: %@     OAuth Token Secret: %@"
                                                                , _UserID, _ScreenName, _OAuthToken, _OAuthTokenSecret ];
            [ self.accessTokenLabel setStringValue: formatString ];
            NSLog( @"Consumer Key: %@ from self.twitterAPI", self.twitterAPI.oauthAccessToken );
            NSLog( @"Consumer Secret: %@ from self.twitterAPI", self.twitterAPI.oauthAccessTokenSecret );
            }
                                         errorBlock: ^( NSError* _Error ) { NSLog( @"%@", _Error ); } ];

    }

@end
