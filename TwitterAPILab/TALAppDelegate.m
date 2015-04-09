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

@end
