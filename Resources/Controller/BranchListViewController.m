//
//  BranchListViewController.m
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 27/6/2562 BE.
//  Copyright © 2562 Jummum Tech. All rights reserved.
//

#import "BranchListViewController.h"
#import "CustomerTableViewController.h"
#import "Branch.h"

@interface BranchListViewController ()
{
    NSArray *_branchList;
    Branch *_selectedBranch;
}
@end

@implementation BranchListViewController
@synthesize tbvBranch;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    tbvBranch.delegate = self;
    tbvBranch.dataSource = self;
    
    
    self.homeModel = [[HomeModel alloc]init];
    self.homeModel.delegate = self;
    [self.homeModel downloadItems:dbBranch withData:@[]];
    
}

///tableview section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [_branchList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Branch *branch = _branchList[item];
    cell.textLabel.text = branch.name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    [cell setSeparatorInset:UIEdgeInsetsMake(16, 16, 16, 16)];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedBranch = _branchList[indexPath.item];
    [self performSegueWithIdentifier:@"segCustomerTable" sender:self];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 8;//CGFLOAT_MIN;
    }
    return tableView.sectionHeaderHeight;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segCustomerTable"])
    {
        CustomerTableViewController *vc = segue.destinationViewController;
        vc.branch = _selectedBranch;
    }
}

-(void)itemsDownloaded:(NSDictionary *)dicData manager:(NSObject *)objHomeModel
{
    HomeModel *homeModel = (HomeModel *)objHomeModel;
    if(homeModel.propCurrentDB == dbBranch)
    {
        [self removeOverlayViews];
        
        _branchList = dicData[@"Branch"];
        [tbvBranch reloadData];
    }
}
@end
