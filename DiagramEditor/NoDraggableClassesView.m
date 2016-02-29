//
//  NoDraggableClassesView.m
//  DiagramEditor
//
//  Created by Diego on 29/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NoDraggableClassesView.h"
#import "AppDelegate.h"
#import "PaletteItem.h"
#import "Connection.h"

@implementation NoDraggableClassesView

@synthesize itemsArray, delegate, connection;

-(void)awakeFromNib{
    
    dele = [[UIApplication sharedApplication]delegate];
    
    
    [table setDataSource:self];
    [table setDelegate:self];
}


#pragma mark UITableView Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return itemsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell;
    
    PaletteItem * pi = [itemsArray objectAtIndex:indexPath.row];
    
    
    cell= [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    cell.textLabel.text = pi.className;//[NSString stringWithFormat:@"--: "];
    return cell;
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return NO;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PaletteItem * selected = [itemsArray objectAtIndex:indexPath.row];
    
    
    //[delegate closeDraggableListWithReturnedItem:selected];
    [delegate closeDraggableLisView:self
                  WithReturnedItem:selected
                      andConnection:connection];
}


-(void)reloadInfo{
    [table reloadData];
}

- (IBAction)cancelAssociatingComponent:(id)sender {
    
    [self removeFromSuperview];
}




@end
