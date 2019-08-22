//
//  AppDelegate.m
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 18/8/2561 BE.
//  Copyright © 2561 Jummum Tech. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "Utility.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage
{
    NSLog(@"remoteMessageAppData: %@",remoteMessage.appData);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"token---%@", token);
    
    
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *strplistPath = [[NSBundle mainBundle] pathForResource:@"Property List" ofType:@"plist"];
    
    // read property list into memory as an NSData  object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:strplistPath];
    NSError *strerrorDesc = nil;
    NSPropertyListFormat plistFormat;
    
    // convert static property list into dictionary object
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&plistFormat error:&strerrorDesc];
    if (!temp)
    {
        NSLog(@"Error reading plist: %@, format: %lu", strerrorDesc, (unsigned long)plistFormat);
    }
    else
    {
        // assign values
        [Utility setPingAddress:[temp objectForKey:@"PingAddress"]];
        [Utility setDomainName:[temp objectForKey:@"DomainName"]];
        [Utility setSubjectNoConnection:[temp objectForKey:@"SubjectNoConnection"]];
        [Utility setDetailNoConnection:[temp objectForKey:@"DetailNoConnection"]];
        [Utility setDetailNoConnection:[temp objectForKey:@"DetailNoConnection"]];
        [Utility setKey:[temp objectForKey:@"Key"]];
        [Utility setBundleID:[temp objectForKey:@"BundleID"]];
    }
    
    
    //push notification
    {
        [FIRApp configure];
        if ([UNUserNotificationCenter class] != nil)//version >= 10
        {
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
             {
                 if( !error )
                 {
                     NSLog( @"Push registration success." );
                 }
                 else
                 {
                     NSLog( @"Push registration FAILED" );
                     NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                     NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
                 }
             }];
        }
        else
        {
            UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [application registerUserNotificationSettings:settings];
        }
        [application registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
        [FIRMessaging messaging].delegate = self;
    }
    
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    NSDictionary *myAps = [userInfo objectForKey:@"aps"];
    NSString *categoryIdentifier = [myAps objectForKey:@"category"];
    if([categoryIdentifier isEqualToString:@"Print"])
    {
        NSNumber *receiptID;
        NSDictionary *data = [myAps objectForKey:@"data"];
        if(data && ![data isEqual:[NSNull null]])
        {
            receiptID = [data objectForKey:@"receiptID"];
        }
        else
        {
            receiptID = [myAps objectForKey:@"receiptID"];            
        }
    }
    

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


@end
