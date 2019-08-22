//
//  CustomTableViewCellQRTable.h
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 28/6/2562 BE.
//  Copyright © 2562 Jummum Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellQRTable : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *vwQRTable;
@property (strong, nonatomic) IBOutlet UIImageView *imgVwQR;
@property (strong, nonatomic) IBOutlet UILabel *lblBranch;
@property (strong, nonatomic) IBOutlet UILabel *lblCustomerTable;

@end

NS_ASSUME_NONNULL_END
