//
//  GarminLoader.m
//
//  Created by Ivan Peralta Santana on 25/05/14.
//

#import "GarminLoader.h"

@implementation GarminLoader

// Internal method to evaluate the Status Code of the GARMIN Response
- (NSInteger) loadStatusCode:(NSURLResponse *) theResponse
{
    NSInteger statusCode = -1;
    if ([theResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = [((NSHTTPURLResponse *)theResponse) statusCode];
        return statusCode;
    }
    return statusCode;
}

// Check if exist any cookie with the session enabled for our user
- (BOOL) isSessionEnabledForUsername:(NSString *) theUsername
{
    // Lets try to download the fake activity track information
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://connect.garmin.com/proxy/activity-search-service-1.2/json/activities?usename=%@&start=0&limit=1", theUsername]]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSInteger statusCode = [self loadStatusCode:response];
    if (statusCode == 403)
        return NO;
    if (statusCode >= 200 && statusCode < 400)
        return YES;

    return YES;
}

// Garmin API methods

// Enabling a new session with username/password authentication
// The process follow the different steps according to tapiriik project
- (BOOL) enableSessionWithUsername:(NSString *) theUsername withPassword:(NSString *) thePassword
{
    // GET the login page
    NSString *params = @"service=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&webhost=olaxpw-connect07.garmin.com&source=http%3A%2F%2Fconnect.garmin.com%2Fde-DE%2Fsignin&redirectAfterAccountLoginUrl=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&redirectAfterAccountCreationUrl=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&gauthHost=https%3A%2F%2Fsso.garmin.com%2Fsso&locale=de&id=gauth-widget&cssUrl=https%3A%2F%2Fstatic.garmincdn.com%2Fcom.garmin.connect%2Fui%2Fsrc-css%2Fgauth-custom.css&clientId=GarminConnect&rememberMeShown=true&rememberMeChecked=false&createAccountShown=true&openCreateAccount=false&usernameShown=true&displayNameShown=false&consumeServiceTicket=false&initialFocus=true&embedWidget=false";
    NSString *urlAddress = [NSString stringWithFormat:@"https://sso.garmin.com/sso/login?%@", params];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAddress]];
    NSURLResponse *response2 = nil;
    NSError *error2 = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response2 error:&error2];
    NSInteger statusCode = [self loadStatusCode:response2];
    if (statusCode != 200){
        return NO;
    } else {
        // We look for the lt hidden input field
        // We will use it on the next request
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSRange range = NSMakeRange(0, responseString.length);
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"name=\"lt\"\\s+value=\"([^\"]+)\""
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        
        NSTextCheckingResult *match = [regex firstMatchInString:responseString
                                                        options:0
                                                          range:range];
        NSString *ltContet = [responseString substringWithRange:[match rangeAtIndex:1]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAddress]];
        [request setHTTPMethod:@"POST"];
        
        // Lets autenticate on the server
        NSMutableString *dataContent = [NSMutableString stringWithFormat:@"username=%@&password=%@&_eventId=submit&embed=true&lt=%@", theUsername, thePassword, ltContet];
        [request setHTTPBody:[dataContent dataUsingEncoding:NSUTF8StringEncoding]];
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response2 error:&error2];
        statusCode = [self loadStatusCode:response2];

        if (statusCode >= 200 && statusCode < 400) {
            if (statusCode != 200){
                return NO;
            } else {
                // We need to get the ticket "ticket=([^']+)'"
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSRange range = NSMakeRange(0, responseString.length);
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ticket=([^']+)'"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
                
                NSTextCheckingResult *match = [regex firstMatchInString:responseString
                                                                options:0
                                                                  range:range];
                NSString *ticket = [responseString substringWithRange:[match rangeAtIndex:1]];
                
                // Now we need to create a login with the received ticket
                NSString *urlString = [NSString stringWithFormat:@"http://connect.garmin.com/post-auth/login?ticket=%@", ticket];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                NSURLResponse *response2 = nil;
                [NSURLConnection sendSynchronousRequest:request returningResponse:&response2 error:nil];
                statusCode = [self loadStatusCode:response2];
                if (statusCode != 302 && statusCode != 200){
                    return NO;
                }
                return YES;
            }
        }
    }
    return NO;
}

// Method for donwload one sessions details
- (NSString *) getSessionDetails:(NSString *) theSessionId withURL:(NSString *) theURLString{
    // Lets try to download the fake activity track information
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:theURLString]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSInteger statusCode = [self loadStatusCode:response];
    if (statusCode >= 200 && statusCode < 400) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        return responseString;
    } else
        return nil;
}

// Short-cut to download the JSON content
- (NSString *) getSessionDetails:(NSString *) theSessionId {
    NSString * urlString = [NSString stringWithFormat:@"http://connect.garmin.com/proxy/activity-service-1.3/json/activity/%@", theSessionId];
    return [self getSessionDetails:theSessionId withURL:urlString];
}

// Short-cut to download the TCX content
- (NSString *) getSessionTCX:(NSString *) theSessionId {
    NSString * urlString = [NSString stringWithFormat:@"http://connect.garmin.com/proxy/activity-service-1.1/tcx/activity/%@?full=true", theSessionId];
    return [self getSessionDetails:theSessionId withURL:urlString];
}

// Short-cut to download the GPX content
- (NSString *) getSessionGPX:(NSString *) theSessionId {
    NSString * urlString = [NSString stringWithFormat:@"http://connect.garmin.com/proxy/activity-service-1.1/gpx/activity/%@?full=true", theSessionId];
    return [self getSessionDetails:theSessionId withURL:urlString];
}

// Method to get the headers of the activities following the pagination
- (NSString *) downloadSessionsWithOffset:(NSInteger) theOffset andLimit:(NSInteger) theLimit{
    // Lets try to download the fake activity track information
    NSString *urlString = [NSString stringWithFormat:@"http://connect.garmin.com/proxy/activity-search-service-1.2/json/activities?start=%d&limit=%d"
                           , theOffset, theLimit];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSInteger statusCode = [self loadStatusCode:response];
    if (statusCode >= 200 && statusCode < 400) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        return responseString;
    }
    
    return nil;
}

@end
