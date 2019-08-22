//
//  PrintQRTableViewController.m
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 28/6/2562 BE.
//  Copyright © 2562 Jummum Tech. All rights reserved.
//

#import "PrintQRTableViewController.h"
#import "CustomTableViewCellQRTable.h"
#import "Zone.h"
#import "ReachabilityBrother.h"
#import "PrinterView.h"
#import "Utilities.h"
//#import "AESCrypt.h"
//#import <CryptoSwift/CryptoSwift.h>
//#import "AdminApp-Swift.h"


#define kBROTHERPJ673   @"Brother PJ-673"

#define    EXT_PJ673_ENCRYPT        0x01
#define    EXT_PJ673_CARBON        0x02
#define    EXT_PJ673_DASHPRINT        0x04
#define    EXT_PJ673_NFD            0x08
#define    EXT_PJ673_EOP            0x10
#define    EXT_PJ673_EPR            0x20


#define kPrinterCapabilitiesKey     @"Capabilities"
#define kPrinterPaperSizeKey        @"PaperSize"

#define kFuncDensity                @"FuncDensity"
#define kFuncCustomPaper            @"FuncCustomPaper"
#define kFuncAutoCut                @"FuncAutoCut"
#define kFuncChainPrint             @"FuncChainPrint"
#define kFuncHalfCut                @"FuncHalfCut"
#define kFuncSpecialTape            @"FuncSpecialTape"
#define kFuncCopies                 @"FuncCopies"
#define kFuncCarbonPrint            @"FuncCarbonPrint"
#define kFuncDashPrint              @"FuncDashPrint"
#define kFuncFeedMode               @"FuncFeedMode"


@interface PrintQRTableViewController () < UITableViewDataSource, UITableViewDelegate>
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSString *_ip;
    BRPtouchPrinter *ptp;
    NSArray *_printCustomerTableList;
}

@end


@implementation PrintQRTableViewController
static NSString * const reuseIdentifierQRTable = @"CustomTableViewCellQRTable";


@synthesize branch;
@synthesize customerTableList;
@synthesize customerTableZoneList;
@synthesize lblPrinterStatus;
@synthesize tbvQRTable;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(TARGET_OS_SIMULATOR == 0)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            BOOL printStatus = [self checkPrinterReady];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                if(printStatus)
                {
                    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
                    NSString *selectedPrinterName = [userSettings stringForKey:@"LastSelectedPrinter"];
                    
                    if(selectedPrinterName && [selectedPrinterName length]>0)
                    {
                        NSString *strStatus = [NSString stringWithFormat:@"Printer name: %@ (ready)",selectedPrinterName];
                        lblPrinterStatus.text = strStatus;
                    }
                }
                else
                {
                    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
                    NSString *selectedPrinterName = [userSettings stringForKey:@"LastSelectedPrinter"];
                    
                    if(selectedPrinterName && [selectedPrinterName length]>0)
                    {
                        NSString *strStatus = [NSString stringWithFormat:@"Printer name: %@ (not ready)",selectedPrinterName];
                        lblPrinterStatus.text = strStatus;
                    }
                    else
                    {
                        lblPrinterStatus.text = @"No printer selected";
                    }
                }
                
            });
        });
    }
}

-(NSString *)getPrinterName
{
    NSUserDefaults *printSetting = [NSUserDefaults standardUserDefaults];
    NSString *printerName = [printSetting stringForKey:@"LastSelectedPrinter"];
    if(!printerName)
    {
        printerName = @"Brother QL-720NW";
    }
    return printerName;
}

-(BOOL)checkPrinterReady
{
    BRPtouchPrintInfo*    printInfo;
    BOOL    isCarbon;
    BOOL    isDashPrint;
    int        feedMode;
    int copies;
    
    
    //    Create BRPtouchPrintInfo
    printInfo = [[BRPtouchPrintInfo alloc] init];
    
    
    //    Load Paramator from UserDefault
    NSUserDefaults *printSetting = [NSUserDefaults standardUserDefaults];
    NSString *printerName = [self getPrinterName];
//    _printerName = printerName;
    if([printerName isEqualToString:@"Brother QL-720NW"])
    {
        printInfo.strPaperName      = @"29mm";
    }
    else if([printerName isEqualToString:@"Brother RJ-3150"])
    {
        printInfo.strPaperName      = @"RD 76mm";
    }
    else
    {
        printInfo.strPaperName      = @"62mm";
    }
    
    
    ptp = [[BRPtouchPrinter alloc] initWithPrinterName:printerName];
    
    
    if (0 != printInfo.strPaperName)
    {
        if (![supportedPaperSizeForPrinter(printerName) containsObject:printInfo.strPaperName]) {
            printInfo.strPaperName = @"Custom";
        }
        NSLog(@"paper: %@",printInfo.strPaperName);
        NSInteger density            = [printSetting integerForKey:@"density"];
        if (!isAvailableDensity(printerName, density)) {
            density = 0;
            NSUserDefaults *printSetting = [NSUserDefaults standardUserDefaults];
            [printSetting setInteger: density forKey:@"density"];
        }
        
        
        if([printerName isEqualToString:@"Brother QL-720NW"])
        {
            printInfo.nPrintMode = PRINT_FIT;
//            printInfo.nDensity = 0;
            printInfo.nOrientation = ORI_LANDSCAPE;
            printInfo.nHalftone = HALFTONE_BINARY;
            printInfo.nHorizontalAlign = ALIGN_CENTER;
            printInfo.nVerticalAlign = ALIGN_MIDDLE;
            printInfo.nPaperAlign = PAPERALIGN_LEFT;
            printInfo.nAutoCutFlag = 1;
        }
//        else if([printerName isEqualToString:@"Brother RJ-3150"])
//        {
//            //    Set printInfo for rj-3150**** have to set papername or try to use custompaper
//            printInfo.nPrintMode = PRINT_FIT;//fit
//            printInfo.nDensity = 5;
//            printInfo.nOrientation = ORI_PORTRATE;
//            printInfo.nHalftone = HALFTONE_BINARY;
//            printInfo.nHorizontalAlign = ALIGN_CENTER;
//            printInfo.nVerticalAlign = ALIGN_MIDDLE;
//            printInfo.nPaperAlign = PAPERALIGN_LEFT;
//            printInfo.nAutoCutFlag = 0;
//        }
        else
        {
            printInfo.nPrintMode = PRINT_FIT;
            printInfo.nDensity = 0;
            printInfo.nOrientation = ORI_PORTRATE;
            printInfo.nHalftone = HALFTONE_BINARY;
            printInfo.nHorizontalAlign = ALIGN_LEFT;
            printInfo.nVerticalAlign = ALIGN_TOP;
            printInfo.nPaperAlign = PAPERALIGN_LEFT;
            printInfo.nAutoCutFlag = 0;
        }
        
        
        
        if (isFuncAvailable(kFuncAutoCut, printerName)) {
            printInfo.nAutoCutFlag      = 1;
        }
        
        if (isFuncAvailable(kFuncChainPrint, printerName) ||
            isFuncAvailable(kFuncSpecialTape, printerName) ||
            isFuncAvailable(kFuncHalfCut, printerName)) {
            printInfo.nExMode = [printSetting integerForKey:@"ExMode"];
        }
        
        if (isFuncAvailable(kFuncCopies, printerName)) {
            copies = [printSetting integerForKey:@"Copies"];
        }
        else{
            copies = 0;
        }
        
        if (isFuncAvailable(kFuncCarbonPrint, printerName)) {
            isCarbon = [printSetting boolForKey:@"isCarbon"];
        }
        
        if (isFuncAvailable(kFuncDashPrint, printerName)) {
            isDashPrint = [printSetting boolForKey:@"isDashPrint"];
        }
        
        if (isFuncAvailable(kFuncFeedMode, printerName)) {
            feedMode = [printSetting integerForKey:@"feedMode"];
        }
    }
    else
    {
        if ([printerName isEqualToString:@"Brother PJ-673"]) {
            printInfo.strPaperName = @"A4_CutSheet";
        }
        else{
            //            printInfo.strPaperName = @"RD 102mm";
            printInfo.strPaperName = @"RD 76mm";
        }
        printInfo.nPrintMode = PRINT_FIT;
        printInfo.nDensity = 0;
        printInfo.nOrientation = ORI_PORTRATE;
        printInfo.nHalftone = HALFTONE_ERRDIF;
        printInfo.nHorizontalAlign = ALIGN_CENTER;
        printInfo.nVerticalAlign = ALIGN_MIDDLE;
        printInfo.nPaperAlign = PAPERALIGN_LEFT;
        
        if (isFuncAvailable(kFuncCarbonPrint, printerName)) {
            isCarbon = false;
        }
        
        if (isFuncAvailable(kFuncDashPrint, printerName)) {
            isDashPrint = false;
        }
        
        if (isFuncAvailable(kFuncFeedMode, printerName)) {
            feedMode = 0;
        }
    }
    
    
    if (isFuncAvailable(kFuncCarbonPrint, printerName) ||
        isFuncAvailable(kFuncDashPrint, printerName) ||
        isFuncAvailable(kFuncFeedMode, printerName))
    {
        if (isCarbon) {
            printInfo.nExtFlag |= EXT_PJ673_CARBON;
        }
        if (isDashPrint) {
            printInfo.nExtFlag |= EXT_PJ673_DASHPRINT;
        }
        
        printInfo.nExtFlag |= feedMode;
    }
    
    _ip = [printSetting stringForKey:@"ipAddress"] == nil?@"":[printSetting stringForKey:@"ipAddress"];
//    _ip = @"192.168.100.55";
    [ptp setIPAddress:_ip];
    
    /********************************************************************************************
     // Refer to the following structure members in order to get tape color or printing color,
     // every color is associated with an ID, the IDs are all described in the User's Manual.
     
     // For tape color -> (PTSTATUSINFO)status.byLabelColor
     // For printing color -> (PTSTATUSINFO)status.byFontColor
     
     // for example:
     PTSTATUSINFO    status;
     [ptp getPTStatus:&status];
     NSLog(@"byLabelColor[%d]",status.byLabelColor);
     NSLog(@"byFontColor[%d]",status.byFontColor);
     *******************************************************************************************/
    
    if (isFuncAvailable(kFuncCustomPaper, printerName)) {
        //    Set custom paper
        if (0 == [printInfo.strPaperName compare:@"Custom"]) {
            NSString* strPaper = [printSetting stringForKey:@"customPaper"];
            NSString* strPath = nil;
            if (strPaper) {
                if (![customizedPapers(printerName) containsObject:strPaper]) {
                    strPaper = defaultCustomizedPaper(printerName);
                    NSLog(@"custom paper: %@",strPaper);
                }
                strPath = [[NSBundle mainBundle] pathForResource:strPaper ofType:@"bin"];
            }
            else{
                strPath = [[NSBundle mainBundle] pathForResource:defaultCustomizedPaper(printerName) ofType:@"bin"];
            }
            [ptp setCustomPaperFile:strPath];
        }
    }
    

//    if([printerName isEqualToString:@"Brother RJ-3150"])
//    {
//        //    Set printInfo
//        printInfo.nPrintMode = 1;//fit
//        printInfo.nDensity = 3;
//        printInfo.nOrientation = 1;
//        printInfo.nHalftone = 0;
//        printInfo.nHorizontalAlign = 1;
//        printInfo.nVerticalAlign = 1;
//    }
    [ptp setPrintInfo:printInfo];
    
    
    if ([ptp isPrinterReady]) {
        NSLog(@"Will start to print image file...");
        NSLog(@"Printer is ready !");
        return YES;
    }
    else
    {
        return NO;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tbvQRTable.dataSource = self;
    tbvQRTable.delegate = self;
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierQRTable bundle:nil];
        [tbvQRTable registerNib:nib forCellReuseIdentifier:reuseIdentifierQRTable];
    }
    
    
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    NSString *selectedPrinterName = [userSettings stringForKey:@"LastSelectedPrinter"];
    
    if(selectedPrinterName && [selectedPrinterName length]>0)
    {
        NSString *strStatus = [NSString stringWithFormat:@"Printer name: %@ (connecting)",selectedPrinterName];
        lblPrinterStatus.text = strStatus;
    }
    else
    {
        lblPrinterStatus.text = @"No printer selected";
    }
    
    if (printerList == nil) {
        printerList = [[NSArray alloc] initWithArray:[self getPrinterList]];
    }
    [self initStoredSettings];
    

    
    printKind = DocumentKindToPrintImage;
    
    
    NSMutableArray *selectedCustomerTableList = [[NSMutableArray alloc]init];
    self.homeModel = [[HomeModel alloc]init];
    self.homeModel.delegate = self;
    for(Zone *zone in customerTableZoneList)
    {
        NSMutableArray *customerTableForZoneList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:customerTableList];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_selected = YES"];
        NSArray *filterCustomerTableList = [customerTableForZoneList filteredArrayUsingPredicate:predicate1];
        [selectedCustomerTableList addObjectsFromArray:filterCustomerTableList];
    }


    [self.homeModel downloadItemsJson:dbQRTable withData:@[selectedCustomerTableList,branch]];
}

- (BOOL)shouldStartSearch
{
    BOOL shouldStart = NO;
    
    ReachabilityBrother *wifiReachability = [ReachabilityBrother reachabilityForLocalWiFi];
    if ((![wifiReachability currentReachabilityStatus]) == NotReachable) {
        shouldStart = YES;
    }
    
    return shouldStart;
}

- (IBAction)connectPrinter:(id)sender {
    if (![self shouldStartSearch]) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Please check your Network settings"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    PrinterView *pv = [[PrinterView alloc] initWithNibName: @"PrinterView" bundle: nil];
    UINavigationController* nv = [[UINavigationController alloc] initWithRootViewController:pv];
    
    [self presentViewController:nv animated:YES completion:nil];
}

///tableview section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
//    return [customerTableZoneList count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
//    Zone *zone = customerTableZoneList[section];
//    NSMutableArray *customerTableForZoneList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:customerTableList];
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_selected = YES"];
//    NSArray *filterCustomerTableList = [customerTableForZoneList filteredArrayUsingPredicate:predicate1];
//    return [filterCustomerTableList count];
    return [_printCustomerTableList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    if([tableView isEqual:tbvQRTable])
    {
        CustomTableViewCellQRTable *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierQRTable];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
//        Zone *zone = customerTableZoneList[section];
//        NSMutableArray *customerTableForZoneList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:customerTableList];
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_selected = YES"];
//        NSArray *filterCustomerTableList = [customerTableForZoneList filteredArrayUsingPredicate:predicate1];
//        CustomerTable *customerTable = filterCustomerTableList[item];
        
        CustomerTable *customerTable = _printCustomerTableList[item];
    
        
//        NSString *message = [NSString stringWithFormat:@"Shop:%ld,TableNo:%ld",branch.branchID,customerTable.customerTableID];
//        NSString *password = encryptedPassword;
//        NSString *encryptedData = @"";//[AESCrypt encrypt:message password:password];
        NSString *encryptedData = customerTable.encryptedMessage;
        NSString *strQR = [NSString stringWithFormat:@"%@%@",qrUrl,encryptedData];
        cell.imgVwQR.image = [self generateQRCodeWithString:strQR scale:5];
        cell.lblBranch.text = branch.name;
        cell.lblCustomerTable.text = [NSString stringWithFormat:@"Table no. %@", customerTable.tableName];
        
    
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 400;
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
//    cell.backgroundColor = [UIColor whiteColor];
    [cell setSeparatorInset:UIEdgeInsetsMake(16, 16, 16, 16)];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;

}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
}

- (IBAction)print:(id)sender
{
    BOOL printerReady = [self checkPrinterReady];
    
    
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler: ^{
        //A handler to be called shortly before the app’s remaining background time reaches 0.
        // You should use this handler to clean up and mark the end of the background task.
    }];
    
    if (printerReady)
    {
        NSLog(@"Will start to print image file...");
        NSLog(@"Printer is ready !");
        
        
        CGImageRef    imgRef;
        NSString *printerName = [self getPrinterName];
        NSInteger margin;
        if ([printerName isEqualToString:@"Brother QL-720NW"])
        {
            margin = 10;
        }
    //            else if([printerName isEqualToString:@"Brother RJ-3150"])
    //            {
    //                margin = 20;
    //            }
        else
        {
            margin = 20;
        }
//        for(Zone *zone in customerTableZoneList)
        {
//            NSMutableArray *customerTableForZoneList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:customerTableList];
//            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_selected = YES"];
//            NSArray *filterCustomerTableList = [customerTableForZoneList filteredArrayUsingPredicate:predicate1];

//            for(CustomerTable *item in filterCustomerTableList)
            for(CustomerTable *item in _printCustomerTableList)
            {
                CustomTableViewCellQRTable *cell = [tbvQRTable dequeueReusableCellWithIdentifier:reuseIdentifierQRTable];
//                NSString *message = [NSString stringWithFormat:@"Shop:%ld,TableNo:%ld",branch.branchID,item.customerTableID];
//                NSString *password = encryptedPassword;
//                NSString *encryptedData = @"";//[AESCrypt encrypt:message password:password];
                NSString *encryptedData = item.encryptedMessage;
                NSString *strQR = [NSString stringWithFormat:@"%@%@",qrUrl,encryptedData];
                cell.imgVwQR.image = [self generateQRCodeWithString:strQR scale:5];
                cell.lblBranch.text = branch.name;
                cell.lblCustomerTable.text = [NSString stringWithFormat:@"Table no. %@", item.tableName];
                
                
                
                UIImage *imagePrint = [self imageForView:cell.vwQRTable];
//                UIImageWriteToSavedPhotosAlbum(imagePrint, nil, nil, nil);//test
                
                imgRef = [imagePrint CGImage];
                if (!imgRef) {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                   message:@"Bad image"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    return;
                }
                
                
                [ptp printImage:imgRef copy:1 timeout:500];
            }
        }
        
    
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Please check your Network settings"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [app endBackgroundTask:bgTask];
}

- (NSArray *)getPrinterList
{
    NSArray *list;
    
    NSString *    path = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if( path )
    {
        NSDictionary *printerDict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        list = [[NSArray alloc] initWithArray:printerDict.allKeys];
    }
    else{
        NSLog(@"Path is not existed !");
        return nil;
    }
    
    return list;
}
- (void)initStoredSettings
{
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    NSString *selectedPrinterName = [userSettings stringForKey:@"LastSelectedPrinter"];
    if (selectedPrinterName) {
        selectedPrinterIndex = [printerList indexOfObject:selectedPrinterName];
        if (![selectedPrinterName isEqualToString:@"Brother PJ-673"]) {
            if (printKind == DocumentKindToPrintPDF) {
                printKind = DocumentKindToPrintImage;
            }
        }
    }
    else{
        selectedPrinterIndex = 0;
    }
}
- (NSString *)optionViewForPrinter:(NSString *)printerName
{
    NSString *optionView;
    
    if ( !([printerName rangeOfString:@"PT-"].location == NSNotFound) ) {
        optionView = @"OptionView_PT";
    }
    else if( !([printerName rangeOfString:@"QL-"].location == NSNotFound) ){
        optionView = @"OptionView_QL";
    }
    else if (!([printerName rangeOfString:@"PJ-"].location == NSNotFound) ){
        optionView = @"OptionView_PJ";
    }
    else if (!([printerName rangeOfString:@"TD-"].location == NSNotFound) ){
        optionView = @"OptionView_TD";
    }
    else if (!([printerName rangeOfString:@"RJ-"].location == NSNotFound) ){
        optionView = @"OptionView_RJ";
    }
    else{
        optionView = @"Not Supported";
    }
    
    return optionView;
}

- (UIImage *)imageForView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];  // if we have efficient iOS 7 method, use it ...
    else
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];         // ... otherwise, fall back to tried and true methods
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage *) generateQRCodeWithString:(NSString *)string scale:(CGFloat) scale{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Render the image into a CoreGraphics image
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[filter outputImage] fromRect:[[filter outputImage] extent]];
    
    //Scale the image usign CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake([[filter outputImage] extent].size.width * scale, [filter outputImage].extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *preImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up .
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage = [UIImage imageWithCGImage:[preImage CGImage]
                                           scale:[preImage scale]
                                     orientation:UIImageOrientationDownMirrored];
    return qrImage;
}

-(void)itemsDownloaded:(NSDictionary *)dicData manager:(NSObject *)objHomeModel
{
    HomeModel *homeModel = (HomeModel *)objHomeModel;
    if(homeModel.propCurrentDB == dbQRTable)
    {
        _printCustomerTableList = dicData[@"CustomerTable"];
        [tbvQRTable reloadData];
    }
}

@end
