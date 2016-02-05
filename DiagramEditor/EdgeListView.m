//
//  EdgeListView.m
//  DiagramEditor
//
//  Created by Diego on 4/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "EdgeListView.h"
#import "AppDelegate.h"
#import "PaletteItem.h"

@implementation EdgeListView


@synthesize table, background, delegate;



-(void)awakeFromNib{
    
    table.delegate = self;
    table.dataSource = self;
    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    tapgr.delegate = self;
    edges = [[NSMutableArray alloc] init];
    
    //Recover all edges from appdelegate
    
    dele = [[UIApplication sharedApplication]delegate];
    for(PaletteItem * pi in dele.paletteItems){
        if([pi.type isEqualToString:@"graphicR:Edge"]){
            [edges addObject:pi];
        }
    }
}



#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [edges count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    PaletteItem * temp = [edges objectAtIndex:indexPath.row];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
        cell.textLabel.text = temp.className;
        cell.textLabel.textColor = dele.blue4;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


-(void)setSelectedPaletteItem:(PaletteItem *)pi{
    [self setHidden:YES];
    [self removeFromSuperview];
    [delegate selectedEdge:pi];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self setSelectedPaletteItem:[edges objectAtIndex:indexPath.row]];
    
}

#pragma UITapGestureRecognizer methods
-(void)handleTap: (UITapGestureRecognizer *)recog{
    [self setHidden:YES];
    [self removeFromSuperview];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}
@end
