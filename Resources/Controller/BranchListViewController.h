//
//  BranchListViewController.h
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 27/6/2562 BE.
//  Copyright © 2562 Jummum Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface BranchListViewController : CustomViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tbvBranch;

@end

NS_ASSUME_NONNULL_END
