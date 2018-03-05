//
//  AppDelegate.h
//  beacontest2
//
//  Created by Cay-Eric Schimanski on 05.03.18.
//  Copyright © 2018 endform.net. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoreLocation/CoreLocation.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,  CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

