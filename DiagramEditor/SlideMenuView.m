//
//  SlideMenuView.m
//  DiagramEditor
//
//  Created by Diego on 9/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "SlideMenuView.h"
#import "AppDelegate.h"

@implementation SlideMenuView
@synthesize delegate;

-(void)awakeFromNib{
    [super awakeFromNib];
    table.dataSource = self;
    table.delegate = self;
    
    dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0){ //Old models
        return 1;
    }else if(section == 1){ //Create palette
        return 1;
    }else if(section == 2){ //Info
        return 2;
    }else{
        return 0;
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"menuId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
    }
    
    [cell setLayoutMargins:UIEdgeInsetsZero];
    

    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    [cell.textLabel setMinimumScaleFactor:7.0/[UIFont labelFontSize]];
    
    cell.textLabel.textColor = dele.blue4;
    
    
    if(indexPath.section == 0){
        cell.textLabel.text = @"Load old model";
    }else if(indexPath.section == 1){
        cell.textLabel.text = @"Create palette";
    }else if(indexPath.section == 2){
        if(indexPath.row == 0){
            cell.textLabel.text = @"Who are we?";
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Tutorial";
        }
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
       return @"  Old files";
    }else if(section == 1){
        return @"  Palettes";
    }else if(section == 2){
        return @"  Information";
    }else{
        return @"";
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    header.backgroundColor = dele.blue3;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];

    label.textColor = dele.blue1;
    label.textAlignment = NSTextAlignmentCenter;
    
    [header addSubview:label];
    
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [delegate menuSelectedOption:(int)indexPath.row inSection:(int)indexPath.section];
}




@end
