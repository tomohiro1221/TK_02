//
//  WPYTokenizer.m
//  Webpay
//
//  Created by yohei on 3/30/14.
//  Copyright (c) 2014 yohei, YasuLab. All rights reserved.
//

// This class is a Facade.
// A common pattern for using 3rd party libraries is
// 1. initialize library at appdelegate
// 2. call method in where it's needed
// This allows applicaiton to initialize all the 3rd party libraries
// in one place. Since the places of initialization and method call
// are different, to avoid the hassle of passing around a pointer of an
// instance, a lot of the libraries are implemented as static class or singleton.

// 1. static class
// [Class setKey:@"key"]; (usually at app delegate)
// [Class method:parameter]; (usually at somewhere else from app delegate)

// 2. singleton
// [[Class sharedInstance] setKey:@"key"]; (at app delegate)
// [[Class sharedInstance] method:parameter];

// Static class has cleaner interface, but it has to hold state as static variable.
// Singleton has uglier interface, and it is hard to test.
// This library is implemented as static class for the benifit of the interface.

#import "WPYTokenizer.h"

#import "WPYCreditCard.h"
#import "WPYCommunicator.h"
#import "WPYTokenBuilder.h"
#import "WPYToken.h"
#import "WPYAvailabilityBuilder.h"
#import "WPYErrorBuilder.h"

#import "WPYDeviceSettings.h"



@implementation WPYTokenizer

static NSString *publicKey = nil;

typedef NS_ENUM(NSInteger, WPYHTTPStatusCode) {
    WPYHTTPStatusCodeOK200 = 200,
    WPYHTTPStatusCodeCreated201 = 201
};

#pragma mark public key
+ (void)setPublicKey:(NSString *)key
{
    publicKey = key;
}

+ (NSString *)publicKey
{
    return publicKey;
}

+ (void)validatePublicKey
{
    BOOL isValidKey = [[self publicKey] hasPrefix:@"test_public_"] || [[self publicKey] hasPrefix:@"live_public_"];
    if (!isValidKey)
    {
        [NSException raise:@"InvalidPublicKey" format:@"You are using an invalid public key."];
    }
}



#pragma mark tokenizer
+ (void)createTokenFromCard:(WPYCreditCard *)card
            completionBlock:(WPYTokenizerCompletionBlock)completionBlock
{
    NSString *acceptLanguage = [WPYDeviceSettings isJapanese] ? @"ja" : @"en";
    [self createTokenFromCard:card
               acceptLanguage:acceptLanguage
              completionBlock:completionBlock];
}

+ (void)createTokenFromCard:(WPYCreditCard *)card
             acceptLanguage:(NSString *)acceptLanguage
            completionBlock:(WPYTokenizerCompletionBlock)completionBlock
{
    [self validatePublicKey];
    NSParameterAssert(card);
    NSParameterAssert(completionBlock);
    
    NSError *cardError = nil;
    if (![card validate:&cardError])
    {
        completionBlock(nil, cardError);
        return;
    }
    
    WPYCommunicator *communicator = [[WPYCommunicator alloc] initWithPublicKey:[self publicKey]
                                                                acceptLanguage:acceptLanguage];
    [communicator requestTokenWithCard:card
                       completionBlock:^(NSURLResponse *response, NSData *data, NSError *networkError) {
                           if (networkError)
                           {
                               completionBlock(nil, networkError);
                               return;
                           }
                           
                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                           if (httpResponse.statusCode == WPYHTTPStatusCodeCreated201)
                           {
                               WPYTokenBuilder *tokenBuilder = [[WPYTokenBuilder alloc] init];
                               NSError *tokenBuildError = nil;
                               WPYToken *token = [tokenBuilder buildTokenFromData:data error:&tokenBuildError];
                               completionBlock(token, tokenBuildError);
                           }
                           else
                           {
                               WPYErrorBuilder *errorBuilder = [[WPYErrorBuilder alloc] init];
                               NSError *error = [errorBuilder buildErrorFromData:data];
                               completionBlock(nil, error);
                           }
    }];
    
}

#pragma mark supported card brands
+ (void)fetchSupportedCardBrandsWithCompletionBlock:(WPYSupportedCardBrandsCompletionBlock)completionBlock
{
    NSString *acceptLanguage = [WPYDeviceSettings isJapanese] ? @"ja" : @"en";
    [self fetchSupportedCardBrandsWithAcceptLanguage:acceptLanguage
                                     completionBlock:completionBlock];
}

+ (void)fetchSupportedCardBrandsWithAcceptLanguage:(NSString *)acceptLanguage
                                   completionBlock:(WPYSupportedCardBrandsCompletionBlock)completionBlock
{
    [self validatePublicKey];
    NSParameterAssert(completionBlock);
    
    WPYCommunicator *communicator = [[WPYCommunicator alloc] initWithPublicKey:[self publicKey]
                                                                acceptLanguage:acceptLanguage];
    [communicator fetchAvailabilityWithCompletionBlock:^(NSURLResponse *response, NSData *data, NSError *networkError) {
        if (networkError)
        {
            completionBlock(nil, networkError);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == WPYHTTPStatusCodeOK200)
        {
            WPYAvailabilityBuilder *builder = [[WPYAvailabilityBuilder alloc] init];
            NSError *availabilityBuildError = nil;
            NSDictionary *availability = [builder buildAvailabilityFromData:data error:&availabilityBuildError];
            NSArray *supportedBrands = availability ? availability[@"card_types_supported"] : nil;
            completionBlock(supportedBrands, availabilityBuildError);
        }
        else
        {
            WPYErrorBuilder *errorBuilder = [[WPYErrorBuilder alloc] init];
            NSError *error = [errorBuilder buildErrorFromData:data];
            completionBlock(nil, error);
        }
    }];
}
@end
