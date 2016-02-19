//
//  ConnectionDetailsView.m
//  DiagramEditor
//
//  Created by Diego on 26/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ConnectionDetailsView.h"
#import "Connection.h"
#import "ReferenceTableViewCell.h"
#import "AppDelegate.h"
#import "Component.h"

@implementation ConnectionDetailsView



@synthesize delegate, nameTextField, sourceLabel, targetLabel, attributesTable, background, connection;

- (void)awakeFromNib {
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];
    
    [nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}


-(void)handleTap: (UITapGestureRecognizer *)recog{
    [self closeConnectionDetailsView];
}

-(void)closeConnectionDetailsView{
    [self removeFromSuperview];
}

- (IBAction)removeThisConnection:(id)sender {
    
    AppDelegate * dele = [[UIApplication sharedApplication] delegate];
    [dele.connections removeObject:self.connection];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    [self closeConnectionDetailsView];
}

-(void)prepare{
    nameTextField.text = connection.name;
    attributesTable.delegate = self;
    attributesTable.dataSource = self;
    sourceLabel.text = connection.source.name;
    targetLabel.text = connection.target.name;
}


-(void)textFieldDidChange :(UITextField *)textField{
    if(textField.text.length == 0){
        
    }else{
        connection.name = textField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }
}

#pragma mark UITableViewDelegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return connection.attributes.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    ReferenceTableViewCell *cell;
    
    Reference * ref = [connection.attributes objectAtIndex:indexPath.row];
    
    cell= [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReferenceTableViewCell"
                                                      owner:self
                                                    options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.nameLabel.text = ref.name;
        [cell.containmentSwitch setOn:ref.containment];
        [cell.containmentSwitch setEnabled:NO];
        cell.targetLabel.text = ref.target;
        
    }
    cell.backgroundColor = [UIColor clearColor];
    
    //cell.textLabel.text = .name;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReferenceTableViewCell"
                                                  owner:self
                                                options:nil];
    ReferenceTableViewCell * temp = [nib objectAtIndex:0];
    return temp.frame.size.height;
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}



@end
