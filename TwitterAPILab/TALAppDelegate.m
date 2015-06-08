//
//  TALAppDelegate.m
//  TwitterAPILab
//
//  Created by Tong G. on 4/9/15.
//
//

#import <CommonCrypto/CommonHMAC.h>
#import "TALAppDelegate.h"
#import "OTCTweet.h"
#import "NSColor+Objectwitter-C.h"

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

    self.testTwitterAPI = [ STTwitterAPI twitterAPIWithOAuthConsumerName: self.consumerName
                                                             consumerKey: self.consumerKey
                                                          consumerSecret: self.consumerSecret
                                                              oauthToken: accessTokenComponents.firstObject
                                                        oauthTokenSecret: accessTokenComponents.lastObject ];

    self.twitterAPI.delegate = self;
    self.testTwitterAPI.delegate = self;

    NSURLSessionConfiguration* defaultConfig = [ NSURLSessionConfiguration defaultSessionConfiguration ];
//    self.defaultSession = [ NSURLSession sessionWithConfiguration: defaultConfig ];
    self.defaultSession = [ NSURLSession sessionWithConfiguration: defaultConfig delegate: self delegateQueue: [ [ NSOperationQueue alloc ] init ] ];
    self.receivedData = [ NSMutableData data ];
    }

#pragma mark Conforms to <OTCSTTwitterStreamingAPIDelegate> protocol
- ( void )      twitterAPI: ( STTwitterAPI* )_TwitterAPI
    didReceiveFriendsLists: ( NSArray* )_Friends
    {
    NSLog( @"Friends: %@", _Friends );
    }

- ( void ) twitterAPI: ( STTwitterAPI* )_TwitterAPI
      didReceiveTweet: ( OTCTweet* )_ReceivedTweet
    {
    NSLog( @"%@", _ReceivedTweet );
    }

- ( void ) twitterAPI: ( STTwitterAPI* )_TwitterAPI
     sentOrReceivedDM: ( OTCDirectMessage* )_DirectMessage
    {
    NSLog( @"DM: %@", _DirectMessage );
    }

- ( void ) twitterAPI: ( STTwitterAPI* )_TwitterAPI
  tweetHasBeenDeleted: ( NSString* )_DeletedTweetID
               byUser: ( NSString* )_UserID
                   on: ( NSDate* )_DeletionDate
    {
    NSLog( @"%@", [ @{ @"Deleted Tweet ID" : _DeletedTweetID ?: [ NSNull null ]
                     , @"User ID" : _UserID ?: [ NSNull null ]
                     , @"Deletion Date" : _DeletionDate ?: [ NSNull null ]
                     } description ] );
    }

- ( void )             twitterAPI: ( STTwitterAPI* )_TwitterAPI
    streamingEventHasBeenDetected: ( OTCStreamingEvent* )_DetectedEvent
    {
    id targetObject = _DetectedEvent.targetObject;
    if ( [ targetObject isKindOfClass: [ OTCTweet class ] ] )
        NSLog( @"Is faved by me: %@", ( ( OTCTweet* )targetObject ).isFavoritedByMe ? @"YES" : @"NO" );

    NSLog( @"Event: %@", _DetectedEvent );
    }

- ( void )    twitterAPI: ( STTwitterAPI* )_TwitterAPI
               streaming: ( NSString* )_StreamName
    wasDisconnectedDueTo: ( NSString* )_Reason
                    code: ( NSString* )_Code
    {
    NSLog( @"%@", [ @{ @"Stream Name" : _StreamName
                     , @"Reason" : _Reason
                     , @"Code" : _Code
                     } description ] );
    }

- ( void )   twitterAPI: ( STTwitterAPI* )_TwitterAPI
    fuckingErrorOccured: ( NSError* )_Error
    {
    NSLog( @"%@", _Error );
    }

- ( void )      twitterAPI: ( STTwitterAPI* )_TwitterAPI
    didTriggerStallWarning: ( NSString* )_WarningMessage
                      code: ( NSString* )_Code
               percentFull: ( NSString* )_PercentFull
    {
    NSLog( @"%@", [ @{ @"Warning Code" : _Code
                     , @"_PercentFull" : _PercentFull
                     } description ] );
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

- ( IBAction ) fetchSampleTweets: ( id )_Sender
    {
    [ self.twitterAPI fetchStatusesSample ];
    }

- ( IBAction ) fetchHomeTimelineAction: ( id )_Sender
    {
    [ self.twitterAPI fetchUserStreamIncludeMessagesFromFollowedAccounts: @NO
                                                          includeReplies: @NO
                                                         keywordsToTrack: nil
                                                   locationBoundingBoxes: nil ];
    }

- ( IBAction ) fetchTimelineOfSpecifiedUser: ( id )_Sender
    {
    [ self.twitterAPI fetchStatusesFilterKeyword: @"" users: @[ @"3166701426,3107332168" ] locationBoundingBoxes: nil ];
    }

- ( IBAction ) fetchPublicTweetsWithFilter: ( id )_Sender
    {
    [ self.testTwitterAPI fetchStatusesFilterKeyword: @"🗽"
                                           users: nil
                           locationBoundingBoxes: nil ];
    }

- ( IBAction ) firehose: ( id )_Sender
    {
    [ self.twitterAPI fetchStatusesFirehoseWithCount: @"0" ];
    }

- ( IBAction ) fetchUserTimelineWithStreamingAPIAction: ( id )_Sender
    {
#if 0
    self.streamParser = [[STTwitterStreamParser alloc] init];
    __weak STTwitterStreamParser *streamParser = self.streamParser;

    [ self.twitterAPI getResource: @"statuses/filter.json"
                    baseURLString: @"https://stream.twitter.com/1.1"
                       parameters: @{ @"stringify_friend_ids" : @"1"
                                    , @"delimited" : @"length"
                                    , @"stall_warnings" : @"0"
//                                    , @"count" : @"20"
                                    , @"track" : @"Microsoft"
//                                    , @"with" : @"followings"
//                                    , @"language" : @"en,zh,fr"
                                    , @"follow" : [ NSString stringWithFormat: @"%@", self.userIDTextField.stringValue/*, @"3166701426" */]
                                    }
            downloadProgressBlock:
                ^( id response )
                    {
                    [streamParser parseWithStreamData:response parsedJSONBlock:^(NSDictionary *json, STTwitterStreamJSONType _JSONType )
                        {
                        NSLog( @"%@", [ OTCTweet tweetWithJSON: json ].tweetText );
                        } ];
                    }
                    successBlock: ^(NSDictionary *rateLimits, id json) { }
                    errorBlock: ^( NSError* _Error ) { NSLog( @"%@", _Error ); } ];
#endif
    [ self.twitterAPI fetchStatusesFilterKeyword: @"🇨🇳,🇺🇸,Microsoft Apple" users: nil locationBoundingBoxes: nil ];
    }

- ( IBAction ) fetchPublicTimelineWithManualOAuthSigning: ( id )_Sender
    {
    NSURL* APIURL = [ NSURL URLWithString: @"https://stream.twitter.com/1.1/statuses/filter.json" ];

    NSString* HTTPMethod = @"POST";
    NSMutableArray* requestParameters = [ NSMutableArray arrayWithObjects:
                                    @{ @"delimited" : @"length" }
                                  , @{ @"language" : @"zh%2Cen" }
                                  , @{ @"oauth_consumer_key" : self.consumerKey }
                                  , @{ @"oauth_nonce" : TGNonce() }
                                  , @{ @"oauth_signature_method" : @"HMAC-SHA1" }
                                  , @{ @"oauth_timestamp" : TGTimestamp() }
                                  , @{ @"oauth_token" : self.twitterAPI.oauthAccessToken }
                                  , @{ @"oauth_version" : @"1.0" }
                                  , @{ @"stall_warnings" : @"0" }
                                  , @{ @"track" : @"%F0%9F%87%A8%F0%9F%87%B3%2C%F0%9F%87%BA%F0%9F%87%B8%2CMicrosoft%2CApple" }
                                  , nil
                                  ];

    NSString* signatureBaseString = TGSignatureBaseString( HTTPMethod, APIURL, requestParameters );

    NSMutableString* signingKey = [ NSMutableString stringWithFormat: @"%@&%@", self.consumerSecret, self.twitterAPI.oauthAccessTokenSecret ];
    NSString* OAuthSignature = TGPercentEncodeString( TGSignWithHMACSHA1( signatureBaseString, signingKey ) );

    NSString* authorizationHeader = TGAuthorizationHeaders( [ requestParameters arrayByAddingObject: @{ @"oauth_signature" : OAuthSignature } ] );

    NSMutableURLRequest* request = [ NSMutableURLRequest requestWithURL: APIURL ];
    [ request setHTTPMethod: HTTPMethod ];

    NSData* bodyData = [ @"delimited=length&language=zh%2Cen&stall_warnings=0&track=%F0%9F%87%A8%F0%9F%87%B3%2C%F0%9F%87%BA%F0%9F%87%B8%2CMicrosoft%2CApple" dataUsingEncoding: NSUTF8StringEncoding ];
    [ request setHTTPBody: bodyData ];

    [ request addValue: [ NSString stringWithFormat: @"%u", ( unsigned int )[ bodyData length ] ] forHTTPHeaderField: @"Content-Length" ];
    [ request addValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField: @"Content-Type" ];
    [ request addValue: authorizationHeader forHTTPHeaderField: @"Authorization" ];
    [ request addValue: @"deflate, gzip" forHTTPHeaderField: @"Accept-Encoding" ];

    self.dataTask = [ self.defaultSession dataTaskWithRequest: request
                                            completionHandler: nil ];
    [ self.dataTask resume ];
    }

- ( IBAction ) fetchHomeTimelineWithManualOAuthSigning: ( id )_Sender
    {
    NSURL* APIURL = [ NSURL URLWithString: @"https://userstream.twitter.com/1.1/user.json" ];

    NSString* HTTPMethod = @"POST";
    NSMutableArray* requestParameters = [ NSMutableArray arrayWithObjects:
                                    @{ @"delimited" : @"length" }
                                  , @{ @"oauth_consumer_key" : self.consumerKey }
                                  , @{ @"oauth_nonce" : TGNonce() }
                                  , @{ @"oauth_signature_method" : @"HMAC-SHA1" }
                                  , @{ @"oauth_timestamp" : TGTimestamp() }
                                  , @{ @"oauth_token" : self.twitterAPI.oauthAccessToken }
                                  , @{ @"oauth_version" : @"1.0" }
                                  , @{ @"stall_warnings" : @"1" }
                                  , nil
                                  ];

    NSString* signatureBaseString = TGSignatureBaseString( HTTPMethod, APIURL, requestParameters );

    NSMutableString* signingKey = [ NSMutableString stringWithFormat: @"%@&%@", self.consumerSecret, self.twitterAPI.oauthAccessTokenSecret ];
    NSString* OAuthSignature = TGPercentEncodeString( TGSignWithHMACSHA1( signatureBaseString, signingKey ) );

    NSString* authorizationHeader = TGAuthorizationHeaders( [ requestParameters arrayByAddingObject: @{ @"oauth_signature" : OAuthSignature } ] );

    NSMutableURLRequest* request = [ NSMutableURLRequest requestWithURL: APIURL ];
    [ request setHTTPMethod: HTTPMethod ];

    NSData* bodyData = [ @"delimited=length&stall_warnings=1" dataUsingEncoding: NSUTF8StringEncoding ];
    [ request setHTTPBody: bodyData ];

    [ request addValue: [ NSString stringWithFormat: @"%u", ( unsigned int )[ bodyData length ] ] forHTTPHeaderField: @"Content-Length" ];
    [ request addValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField: @"Content-Type" ];
    [ request addValue: authorizationHeader forHTTPHeaderField: @"Authorization" ];
    [ request addValue: @"deflate, gzip" forHTTPHeaderField: @"Accept-Encoding" ];

    self.dataTask = [ self.defaultSession dataTaskWithRequest: request
                                            completionHandler: nil ];
    [ self.dataTask resume ];
    }

- ( void ) URLSession: ( NSURLSession* )_URLSession
             dataTask: ( NSURLSessionDataTask* )_DataTask
       didReceiveData: ( NSData* )_Data
    {
    NSString* JSONString = [ [ NSString alloc ] initWithData: _Data encoding: NSUTF8StringEncoding ];

    NSDictionary* JSONDict = [ NSJSONSerialization JSONObjectWithData: [ JSONString dataUsingEncoding: NSUTF8StringEncoding ] options: 0 error: nil ];
    NSLog( @"%@", JSONDict );

//    NSArray* components = [ JSONString componentsSeparatedByString: @"\r\n" ];
//    for ( NSString* sub in components )
//        {
//        NSDictionary* JSONDict = [ NSJSONSerialization JSONObjectWithData: [ sub dataUsingEncoding: NSUTF8StringEncoding ] options: 0 error: nil ];
//
//        if ( JSONDict )
//            {
//            OTCTweet* tweet = [ OTCTweet tweetWithJSON: JSONDict ];
//            NSLog( @"%@\n\n\n", tweet.tweetText );
//            }
//        else
//            NSLog( @"%@", sub );
//        }
//
//    if ( components.count == 0 && JSONString )
//        NSLog( @"%@", JSONString );
    }

- ( void ) URLSession: ( NSURLSession* )_URLSession
             dataTask: ( NSURLSessionDataTask* )_DataTask
   didReceiveResponse: ( NSURLResponse* )_Response
    completionHandler: ( void (^)( NSURLSessionResponseDisposition ) )_CompletionHandler
    {
    if ( _Response )
        NSLog( @"%@", _Response );

    _CompletionHandler( NSURLSessionResponseAllow );
    }

@synthesize userScreenNameTextField;
@synthesize GETUserTimelineButton;
- ( IBAction ) GETUserTimelineAction: ( id )_Sender
    {
    [ self.twitterAPI getUserTimelineWithScreenName: userScreenNameTextField.stringValue
                                              count: 10
                                       successBlock:
        ^( NSArray* _Statuses )
            {
            OTCTweet* status = [ OTCTweet tweetWithJSON: _Statuses[ 0 ] ];
            NSLog( @"%@", status );
            }
                                             errorBlock: ^( NSError* _Error ) { NSLog( @"%@", _Error ); } ];
    }

@end

NSString* TGSignWithHMACSHA1( NSString* _SignatureBaseString, NSString* _SigningKey )
    {
    unsigned char buffer[ CC_SHA1_DIGEST_LENGTH ];
    CCHmac( kCCHmacAlgSHA1
          , _SigningKey.UTF8String, _SigningKey.length
          , _SignatureBaseString.UTF8String, _SignatureBaseString.length
          , buffer
          );

    NSData* signatureData = [ NSData dataWithBytes: buffer length: CC_SHA1_DIGEST_LENGTH ];
    NSString* base64 = [ signatureData base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength ];

    return base64;
    }

NSString* TGTimestamp()
    {
    NSTimeInterval UnixEpoch = [ [ NSDate date ] timeIntervalSince1970 ];
    NSString* timestamp = [ NSString stringWithFormat: @"%lu", ( NSUInteger )floor( UnixEpoch ) ];
    return timestamp;
    }

NSString* TGNonce()
    {
    CFUUIDRef UUID = CFUUIDCreate( kCFAllocatorDefault );
    CFStringRef cfStringRep = CFUUIDCreateString( kCFAllocatorDefault, UUID ) ;
    NSString* stringRepresentation = [ ( __bridge NSString* )cfStringRep copy ];

    if ( UUID )
        CFRelease( UUID );

    if ( cfStringRep )
        CFRelease( cfStringRep );

    return stringRepresentation;
    }

NSString* TGSignatureBaseString( NSString* _HTTPMethod, NSURL* _APIURL, NSArray* _RequestParams )
    {
    NSMutableString* signatureBaseString = [ NSMutableString stringWithString: _HTTPMethod ];
    [ signatureBaseString appendString: @"&" ];
    [ signatureBaseString appendString: TGPercentEncodeURL( _APIURL ) ];
    [ signatureBaseString appendString: @"&" ];

    for ( NSDictionary* _Param in _RequestParams )
        {
        NSString* key = [ _Param allKeys ].firstObject;
        [ signatureBaseString appendString: key ];
        [ signatureBaseString appendString: TGPercentEncodeString( @"=" ) ];
        [ signatureBaseString appendString: TGPercentEncodeString( _Param[ key ] ) ];
        [ signatureBaseString appendString: TGPercentEncodeString( @"&" ) ];
        }

    [ signatureBaseString deleteCharactersInRange: NSMakeRange( signatureBaseString.length - 3, 3 ) ];
    return [ signatureBaseString copy ];
    }

NSString* TGPercentEncodeString( NSString* _String )
    {
    NSArray* reservedChars = @[ @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"

                              , @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M"
                              , @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"

                              , @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m"
                              , @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"

                              , @"-", @".", @"_", @"~"
                              ];

    NSMutableString* percentEncodedString = [ NSMutableString string ];
    for ( int _Index = 0; _Index < _String.length; _Index++ )
        {
        NSString* charElem = [ _String substringWithRange: NSMakeRange( _Index, 1 ) ];

        if ( [ reservedChars containsObject: charElem ] )
            [ percentEncodedString appendString: charElem ];
        else
            {
            char const* UTF8Char = [ charElem UTF8String ];
            NSMutableString* percentEncodedChar = [ NSMutableString stringWithString: @"%" ];
            [ percentEncodedChar appendString: [ NSString stringWithFormat: @"%x", *UTF8Char ] ];
            percentEncodedChar = [ percentEncodedChar.uppercaseString mutableCopy ];

            [ percentEncodedString appendString: percentEncodedChar ];
            }
        }

    return percentEncodedString;
    }

NSString* TGPercentEncodeURL( NSURL* _URL )
    {
    NSString* absoluteString = [ _URL absoluteString ];
    return TGPercentEncodeString( absoluteString );
    }

NSString* TGAuthorizationHeaders( NSArray* _RequestParams )
    {
    NSMutableString* authorizationHeader = [ NSMutableString stringWithFormat: @"OAuth " ];

    for ( NSDictionary* _Param in _RequestParams )
        {
        NSString* key = [ _Param allKeys ].firstObject;
        [ authorizationHeader appendString: [ NSString stringWithFormat: @"%@=\"%@\", ", key, _Param[ key ] ] ];
        }

    [ authorizationHeader deleteCharactersInRange: NSMakeRange( authorizationHeader.length - 1, 1 ) ];

    return [ authorizationHeader copy ];
    }