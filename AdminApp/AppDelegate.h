//
//  AppDelegate.h
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 18/8/2561 BE.
//  Copyright © 2561 Jummum Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
@import UserNotifications;
@import Firebase;
@import FirebaseInstanceID;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UIViewController *vc;


@end

