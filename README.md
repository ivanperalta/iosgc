# ios Garmin Connect

## Introduction

This is a non-commercial software, just for testing and personal performance analysis

The first release use synch methods. You could improve easily with async mechanism.

The goal of the project is evaluate the non-public integration specs from GARMIN

## Acknowledgment

The integration follow the principles explained on the great https://tapiriik.com/ software.

https://github.com/cpfair/tapiriik/blob/master/tapiriik/services/GarminConnect/garminconnect.py

So, although could be nice to receive contributions, you should considerate to contribute to the https://tapiriik.com/ project or become a https://tapiriik.com/ customer for 2$/yr.

## Disclosure

GARMIN has been published a new developer program. In that way the developers should pay for a fee to become members. 

So, this project doesn't exempts you to follow the new GARMIN policy

## Guidelines

Follow the following steps to use the library in your iOS projects:

1 - Check if you've an enabled session with the method

- (BOOL) isSessionEnabledForUsername:(NSString *) theUsername; 

2 - (If not) create a session

- (BOOL) enableSessionWithUsername:(NSString *) theUsername withPassword:(NSString *) thePassword;

3 - Download the list of workouts available with method

- (NSString *) downloadSessionsWithOffset:(NSInteger) theOffset andLimit:(NSInteger) theLimit;

That method will return the list of activities with a content overview

{"results": {
  "activities": [
    {
      "activity": {
        "activityId": 657605293,
...

4 - Download the workout's detail with one of the following methods using the activityId obtained in the previous request

- (NSString *) getSessionDetails:(NSString *) theSessionId;
- (NSString *) getSessionTCX:(NSString *) theSessionId;
- (NSString *) getSessionGPX:(NSString *) theSessionId;

There's an easy way to test that workflow, and evaluate the third step expected response:

* Open to the garmin portal https://connect.garmin.com/
* Sign In with your credentials
* Once you've logged In, go to the next page 

https://connect.garmin.com/proxy/activity-search-service-1.2/json/activities?start=0&limit=1 and the last activity will be displayed
