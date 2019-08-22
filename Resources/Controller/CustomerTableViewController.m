//
//  CustomerTableViewController.m
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 28/6/2562 BE.
//  Copyright © 2562 Jummum Tech. All rights reserved.
//

#import "CustomerTableViewController.h"
#import "CustomTableViewCellMenu.h"
#import "PrintQRTableViewController.h"
#import "CustomerTable.h"
#import "Zone.h"


@interface CustomerTableViewController ()
{
    NSMutableArray *_customerTableZoneList;
    NSMutableArray *_customerTableList;
    NSInteger _selectedZoneIndex;
}
@end

@implementation CustomerTableViewController
static NSString * const reuseIdentifierMenu = @"CustomTableViewCellMenu";

@synthesize tbvCustomerTable;
@synthesize branch;
@synthesize btnSelectAll;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tbvCustomerTable.delegate = self;
    tbvCustomerTable.dataSource = self;
    tbvCustomerTable.allowsMultipleSelection = YES;

    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierMenu bundle:nil];
        [tbvCustomerTable registerNib:nib forCellReuseIdentifier:reuseIdentifierMenu];
    }
    

    [self.homeModel downloadItems:dbCustomerTable withData:branch];
}

///tableview section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    Zone *zone = _customerTableZoneList[_selectedZoneIndex];
    NSMutableArray *customerTableList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:_customerTableList];
    return [customerTableList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    if([tableView isEqual:tbvCustomerTable])
    {
        CustomTableViewCellMenu *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierMenu];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
        Zone *zone = _customerTableZoneList[_selectedZoneIndex];
        NSMutableArray *customerTableList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:_customerTableList];
        CustomerTable *customerTable = customerTableList[item];
    
    
        cell.lblPrice.hidden = YES;
        cell.lblSpecialPrice.hidden = YES;
        cell.lblQuantity.hidden = YES;
        cell.imgTriangle.hidden = YES;
        cell.imgMenuPic.hidden = YES;
        cell.imgMenuPicWidthConstant.constant = 0;
        cell.lblMenuName.text = customerTable.tableName;
        cell.backgroundColor = customerTable.selected?cSystem1_30:[UIColor clearColor];
        NSLog(@"selected: %d",(int)customerTable.selected);
        
    
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
    
    
    Zone *zone = _customerTableZoneList[_selectedZoneIndex];
    NSMutableArray *customerTableList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:_customerTableList];
    CustomerTable *customerTable = customerTableList[item];
    customerTable.selected = YES;
    
    
    CustomTableViewCellMenu *cell = [tbvCustomerTable cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = cSystem1_30;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    Zone *zone = _customerTableZoneList[_selectedZoneIndex];
    NSMutableArray *customerTableList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:_customerTableList];
    CustomerTable *customerTable = customerTableList[item];
    customerTable.selected = NO;
    
    
    CustomTableViewCellMenu *cell = [tbvCustomerTable cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
}

- (void)createHorizontalScroll
{
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    float topPadding = window.safeAreaInsets.top;
    topPadding = topPadding == 0?20:topPadding;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topPadding+44, self.view.frame.size.width, 44)];
    scrollView.delegate = self;
    int buttonX = 15;
    for (int i = 0; i < [_customerTableZoneList count]; i++)
    {
        Zone *zone = _customerTableZoneList[i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, 0, 100, 44)];
        button.titleLabel.font = [UIFont fontWithName:@"Prompt-SemiBold" size:15];
        if(i==0)
        {
            [button setTitleColor:cSystem1 forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:cSystem4 forState:UIControlStateNormal];
        }
        [button setTitle:zone.name forState:UIControlStateNormal];
        [button sizeToFit];
        [scrollView addSubview:button];
        buttonX = 15 + buttonX+button.frame.size.width;
        [button addTarget:self action:@selector(zoneSelected:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i+1;
        
        CGRect frame = button.frame;
        frame.size.height = 2;
        frame.origin.y = button.frame.origin.y + button.frame.size.height-2;
        
        UIView *highlightBottomBorder = [[UIView alloc]initWithFrame:frame];
        highlightBottomBorder.backgroundColor = cSystem2;
        highlightBottomBorder.tag = i+1+100;
        highlightBottomBorder.hidden = i!=0;
        [scrollView addSubview:highlightBottomBorder];
    }
    
    scrollView.contentSize = CGSizeMake(buttonX, scrollView.frame.size.height);
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
}

-(void)zoneSelected:(UIButton*)sender
{
    UIButton *button = sender;
    _selectedZoneIndex = button.tag-1;
    
    
    for(int i=1; i<=[_customerTableZoneList count]; i++)
    {
        UIButton *eachButton = [self.view viewWithTag:i];
        [eachButton setTitleColor:cSystem4 forState:UIControlStateNormal];
        
        
        UIView *highlightBottomBorder = [self.view viewWithTag:i+100];
        highlightBottomBorder.hidden = YES;
    }
    
    
    [button setTitleColor:cSystem1 forState:UIControlStateNormal];
    UIView *highlightBottomBorder = [self.view viewWithTag:button.tag+100];
    highlightBottomBorder.hidden = NO;
    
    
    [tbvCustomerTable reloadData];
}

-(void)setData
{
    [self createHorizontalScroll];
    [tbvCustomerTable reloadData];
}

-(void)itemsDownloaded:(NSDictionary *)dicData manager:(NSObject *)objHomeModel
{
    HomeModel *homeModel = (HomeModel *)objHomeModel;
    if(homeModel.propCurrentDB == dbCustomerTable)
    {        
        _customerTableList = dicData[@"CustomerTable"];
        _customerTableZoneList = dicData[@"Zone"];
        
        [self setData];
    }
}

- (IBAction)selectAll:(id)sender
{
    Zone *zone = _customerTableZoneList[_selectedZoneIndex];
    NSMutableArray *customerTableList = [CustomerTable getCustomerTableListWithZone:zone.name customerTableList:_customerTableList];
    
    
    if([btnSelectAll.title isEqualToString:@"Select all"])
    {
        for(CustomerTable *item in customerTableList)
        {
            item.selected = YES;
        }
    }
    else
    {
        for(CustomerTable *item in customerTableList)
        {
            item.selected = NO;
        }
    }
    
    btnSelectAll.title = [btnSelectAll.title isEqualToString:@"Select all"]?@"Unselect all":@"Select all";
    
    [tbvCustomerTable reloadData];
}

- (IBAction)print:(id)sender
{
    [self performSegueWithIdentifier:@"segPrintQRTable" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segPrintQRTable"])
    {
        PrintQRTableViewController *vc = segue.destinationViewController;
        vc.branch = branch;
        vc.customerTableList = _customerTableList;
        vc.customerTableZoneList = _customerTableZoneList;
    }
}
@end
