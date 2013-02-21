//
//  NSString+QMAdditions.m
//  SignatureTravel11
//
//  Created by Ryan Jennings on 11-09-23.
//  Copyright 2011 QuickMobile. All rights reserved.
//

#import "NSString+QMAdditions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NSString_QMAdditions)

//
// returns a substring in between two search strings
//
- (NSString *) substringInBetween: (NSString *)begin: (NSString *) end
{
    NSRange range = [self rangeOfString:begin];
    
    if(range.location != NSNotFound)
    {       
        int beginIndex = range.location + range.length;
        
        NSRange endRange =  [self rangeOfString:end options:NSLiteralSearch 
                                      range:NSMakeRange(beginIndex, self.length - range.location - range.length)];
        
        if(endRange.location  != NSNotFound)
        {
            return [self substringWithRange:NSMakeRange(beginIndex, endRange.location - range.location - range.length)];
        }
    }
    return nil;
}

+ (NSString*)firstWords:(NSString*)theStr howMany:(NSInteger)maxWords {
    
    NSArray *theWords = [theStr componentsSeparatedByString:@" "];
    if ([theWords count] < maxWords) {
        maxWords = [theWords count];
    }
    NSRange wordRange = NSMakeRange(0, maxWords);
    NSArray *firstWords = [theWords subarrayWithRange:wordRange];               
    return [firstWords componentsJoinedByString:@" "];
}

- (NSString*)md5HexDigest {
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (NSString*)sha256Digest {
    const char *cData = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cData, strlen(cData), cHMAC);
    
    NSData *dataResult = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString* hash = [NSString stringWithFormat:@"%@", dataResult];
    
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hash;
}

- (BOOL)isEmptyOrWhitespace {
    return !self.length || 
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (BOOL)isWhitespace {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}

@end
