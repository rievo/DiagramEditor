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



@synthesize delegate, sourceLabel, targetLabel, background, connection;

- (void)awakeFromNib {
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];
    
    //[nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    //nameTextField.text = connection.name;
    //attributesTable.delegate = self;
    //attributesTable.dataSource = self;
    sourceLabel.text = [NSString stringWithFormat:@"Name: %@",connection.source.name];
    targetLabel.text = [NSString stringWithFormat:@"Name: %@", connection.target.name];
    
    
    associatedComponentsArray = [[NSMutableArray alloc] init];
    //Llenamos ese array con las instancias asociadas a esta conexión
    
    instancesTable.delegate = self;
    instancesTable.dataSource = self;
    
    
    for (NSString * key in [connection.instancesOfClassesDictionary allKeys]) {
        NSLog(@"%@", key);
        NSMutableArray * tempArray = [connection.instancesOfClassesDictionary objectForKey:key];
        
        for(Component * comp in tempArray){
            [associatedComponentsArray addObject:comp];
        }
    }
    
    [instancesTable reloadData];
}


-(void)textFieldDidChange :(UITextField *)textField{
    if(textField.text.length == 0){
        
    }else{
        //connection.name = textField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }
}

#pragma mark UITableViewDelegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return associatedComponentsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell;
    
    Component * c = [associatedComponentsArray objectAtIndex:indexPath.row];
    
    
    cell= [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    cell.textLabel.text = [NSString stringWithFormat:@"--: %@", c.name];
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
