//
//  PrintQRTableViewController.h
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 28/6/2562 BE.
//  Copyright © 2562 Jummum Tech. All rights reserved.
//

#import "CustomViewController.h"
#import "Branch.h"
#import "CustomerTable.h"
//#import "OptionView.h"
#import "PDFSelectVIewControllerViewController.h"
#import <BRPtouchPrinterKit/BRPtouchPrinterKit.h>


typedef enum : NSInteger {
    DocumentKindToPrintImage = 0,
    DocumentKindToPrintPDF
} DocumentKindToPrint;
NS_ASSUME_NONNULL_BEGIN

@interface PrintQRTableViewController : CustomViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSArray         *printerList;
    NSInteger selectedPrinterIndex;
    DocumentKindToPrint printKind;
    UIBackgroundTaskIdentifier bgTask;
}
@property (strong, nonatomic) Branch *branch;
@property (strong, nonatomic) NSMutableArray *customerTableList;
@property (strong, nonatomic) NSMutableArray *customerTableZoneList;
//@property(nonatomic, retain) OptionView *option;
@property (strong, nonatomic) IBOutlet UILabel *lblPrinterStatus;
@property (strong, nonatomic) IBOutlet UITableView *tbvQRTable;
- (IBAction)print:(id)sender;
- (IBAction)connectPrinter:(id)sender;

@end

NS_ASSUME_NONNULL_END
