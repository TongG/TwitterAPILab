//
//  TALAppDelegate.m
//  TwitterAPILab
//
//  Created by Tong G. on 4/9/15.
//
//

#import "TALAppDelegate.h"
#import "STTwitter.h"
#import "OTCTweet.h"

@implementation TALAppDelegate

@synthesize twitterAPI;
    @synthesize consumerKey;
    @synthesize consumerSecret;

- ( void ) awakeFromNib
    {
    NSURL* URLOfConsumerTokens = [ NSURL URLWithString: [ NSString stringWithFormat: @"file://%@", [ NSHomeDirectory() stringByAppendingString: @"/Documents/consumer-tokens.txt" ] ] ];
    NSURL* URLOfAccessTokens = [ NSURL URLWithString: [ NSString stringWithFormat: @"file://%@", [ NSHomeDirectory() stringByAppendingString: @"/Documents/access-tokens.txt" ] ] ];
    NSString* consumerTokens = [ NSString stringWithContentsOfURL: URLOfConsumerTokens encoding: NSUTF8StringEncoding error: nil ];
    NSString* accessTokens = [ NSString stringWithContentsOfURL: URLOfAccessTokens encoding: NSUTF8StringEncoding error: nil ];

    NSArray* consumerTokenComponents = [ consumerTokens componentsSeparatedByString: @"&" ];
    NSArray* accessTokenComponents = [ accessTokens componentsSeparatedByString: @"&" ];
    self.consumerName = consumerTokenComponents.firstObject;
    self.consumerKey = consumerTokenComponents[ 1 ] ;
    self.consumerSecret = consumerTokenComponents.lastObject;

    self.accessTokenLabel.stringValue = [ NSString stringWithFormat: @"%@   %@"
                                                                   , accessTokenComponents.firstObject
                                                                   , accessTokenComponents.lastObject ];

    self.twitterAPI = [ STTwitterAPI twitterAPIWithOAuthConsumerName: self.consumerName
                                                         consumerKey: self.consumerKey
                                                      consumerSecret: self.consumerSecret
                                                          oauthToken: accessTokenComponents.firstObject
                                                    oauthTokenSecret: accessTokenComponents.lastObject ];
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

#pragma mark Statuses
@synthesize GETMentionsTimeLineButton;
- ( IBAction ) GETMentionsTimeLineAction: ( id )_Sender
    {
    [ self.twitterAPI getStatusesMentionTimelineWithCount: @"10"
                                                  sinceID: nil
                                                    maxID: nil
                                                 trimUser: @NO
                                       contributorDetails: @NO
                                          includeEntities: @YES
                                             successBlock:
        ^( NSArray* _Statuses )
            {
            OTCTweet* status = [ OTCTweet tweetWithJSON: _Statuses[ 0 ] ];
            NSLog( @"%@", status );
            }
                                               errorBlock: ^( NSError* _Error ) { NSLog( @"%@", _Error ); } ];
    }

@synthesize GETUserTimelineButton;
- ( IBAction ) GETUserTimelineAction: ( id )_Sender
    {
    [ self.twitterAPI getUserTimelineWithScreenName: @"BotOfNSTongG"
                                              count: 10
                                       successBlock:
        ^( NSArray* _Statuses )
            {
            OTCTweet* status = [ OTCTweet tweetWithJSON: _Statuses[ 1 ] ];
            NSLog( @"%@", status );
            }
                                             errorBlock: ^( NSError* _Error ) { NSLog( @"%@", _Error ); } ];
    }

@end
