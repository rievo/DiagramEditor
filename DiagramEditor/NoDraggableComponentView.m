//
//  NoDraggableComponentView.m
//  DiagramEditor
//
//  Created by Diego on 22/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NoDraggableComponentView.h"
#import "AppDelegate.h"

@implementation NoDraggableComponentView

@synthesize elementName, delegate;


-(void)awakeFromNib{
    UITapGestureRecognizer * tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapGr];
    [tapGr setDelegate:self];
    
    table.delegate = self;
    table.dataSource = self;
    dele = [[UIApplication sharedApplication]delegate];
}

-(void)updateNameLabel{
    [nodeTypeLabel setText:elementName];
    
     thisArray = [dele.elementsDictionary objectForKey:elementName];
}


- (IBAction)addCurrentNode:(id)sender {
    
    if(textField.text.length == 0){
        
    }else{
        [thisArray addObject:textField.text];
        [table reloadData];
    }
    

}


-(void)handleTap:(UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}



#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return thisArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
        cell.textLabel.text = [thisArray objectAtIndex:indexPath.row];

        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    
}


@end
