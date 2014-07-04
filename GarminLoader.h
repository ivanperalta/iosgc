//
//  GarminLoader.h
//
//  Created by Ivan Peralta Santana on 25/05/14.
//

#import <Foundation/Foundation.h>

@interface GarminLoader : NSObject<NSURLConnectionDelegate>

// Garmin API methods
- (BOOL) isSessionEnabledForUsername:(NSString *) theUsername;
- (BOOL) enableSessionWithUsername:(NSString *) theUsername withPassword:(NSString *) thePassword;
- (NSString *) getSessionDetails:(NSString *) theSessionId;
- (NSString *) getSessionTCX:(NSString *) theSessionId;
- (NSString *) getSessionGPX:(NSString *) theSessionId;

// Shortcuts
- (NSString *) downloadSessionsWithOffset:(NSInteger) theOffset andLimit:(NSInteger) theLimit;

@end
