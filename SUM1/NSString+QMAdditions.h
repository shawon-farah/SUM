//
//  NSString+QMAdditions.h
//  SignatureTravel11
//
//  Created by Ryan Jennings on 11-09-23.
//  Copyright 2011 QuickMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_QMAdditions)

//
// returns a substring in between two search strings
//
- (NSString *) substringInBetween: (NSString *)begin: (NSString *) end;
+ (NSString*)firstWords:(NSString*)theStr howMany:(NSInteger)maxWords;
- (NSString*)md5HexDigest;
- (NSString*)sha256Digest;
- (BOOL)isEmptyOrWhitespace;
- (BOOL)isWhitespace;

@end
