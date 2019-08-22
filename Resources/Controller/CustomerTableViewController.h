//
//  CustomerTableViewController.h
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 28/6/2562 BE.
//  Copyright © 2562 Jummum Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "Branch.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomerTableViewController : CustomViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tbvCustomerTable;
@property (strong, nonatomic) Branch *branch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSelectAll;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnPrint;
- (IBAction)selectAll:(id)sender;
- (IBAction)print:(id)sender;


@end

NS_ASSUME_NONNULL_END
