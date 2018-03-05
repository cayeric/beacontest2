//
//  AppDelegate.m
//  beacontest2
//
//  Created by Cay-Eric Schimanski on 05.03.18.
//  Copyright © 2018 endform.net. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UserNotifications/UserNotifications.h"

#define STRING_SERVER_URL @"https://your.company.com/beacon.html"
#define STRING_BEACON_PROXIMITYUUID @"713E0000-503E-4C75-BA94-3148F18D941E"
#define STRING_BEACON_REGIONID @"beacontest2"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    CLLocationManager *_locManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _locManager = [[CLLocationManager alloc] init];
    _locManager.delegate = self;
    
    // Override point for customization after application launch.
    _locManager.allowsBackgroundLocationUpdates=YES;
    _locManager.pausesLocationUpdatesAutomatically = NO;
    [_locManager requestAlwaysAuthorization];
    NSUUID * proximityID = [[NSUUID alloc]  initWithUUIDString:STRING_BEACON_PROXIMITYUUID]; 
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                    initWithProximityUUID:proximityID
                                    identifier:STRING_BEACON_REGIONID];
    
    beaconRegion.notifyEntryStateOnDisplay = YES;
    
    // Register the beacon region with the location manager.
    [_locManager startMonitoringForRegion:beaconRegion];
    [_locManager startRangingBeaconsInRegion:beaconRegion];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!error) {
                                  NSLog(@"request succeeded!");
                              }
                          }];    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) 
    {
        NSLog(@"Background updates are available for the app.");
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    // create a message
    NSString * msgstring = [NSString stringWithFormat:@"Enter region: %@\n", region.identifier];

    // send region transition data to web service
    NSString * urlstring = [NSString stringWithFormat:@"%@?transition=enter&region=%@", STRING_SERVER_URL, region.identifier];
    NSLog([NSString stringWithFormat:@"url string: %@",urlstring]);
    NSURL *url = [NSURL URLWithString:urlstring];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         NSLog(@"received enter data!");
     }];

    // when in foreground - update view
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        ViewController* viewController = (ViewController*)  self.window.rootViewController;
        viewController.beaconState.text = @"in";
    }
    // else, in background, send local notification message
    else
    {
        UNMutableNotificationContent *localNotification = [UNMutableNotificationContent new];
        localNotification.title = [NSString localizedUserNotificationStringForKey:@"iBeacon Event" arguments:nil];
        localNotification.body = [NSString localizedUserNotificationStringForKey:msgstring arguments:nil];
        localNotification.sound = [UNNotificationSound defaultSound];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"iBeacon Event" content:localNotification trigger:trigger];
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"Notification created");
        }];
        
    }

    NSLog(msgstring);
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    // create a message
    NSString * msgstring = [NSString stringWithFormat:@"Exit region: %@\n", region.identifier];

    // send region transition data to web service
    NSString * urlstring = [NSString stringWithFormat:@"%@?transition=exit&region=%@", STRING_SERVER_URL, region.identifier];
    NSLog([NSString stringWithFormat:@"url string: %@",urlstring]);
    NSURL *url = [NSURL URLWithString:urlstring];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         NSLog(@"received exit data!");
     }];
    
    // when in foreground - update view
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        ViewController* viewController = (ViewController*)  self.window.rootViewController;
        viewController.beaconState.text = @"out";
    }
    // else, in background, send local notification message
    else
    {
        UNMutableNotificationContent *localNotification = [UNMutableNotificationContent new];
        localNotification.title = [NSString localizedUserNotificationStringForKey:@"iBeacon Event" arguments:nil];
        localNotification.body = [NSString localizedUserNotificationStringForKey:msgstring arguments:nil];
        localNotification.sound = [UNNotificationSound defaultSound];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"iBeacon Event" content:localNotification trigger:trigger];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) 
        {
            NSLog(@"Notification created");
        }];
    }

    NSLog(msgstring);
}

@end
