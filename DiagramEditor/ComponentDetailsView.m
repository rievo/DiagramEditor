//
//  ComponentDetailsViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "ComponentDetailsView.h"
#import "Component.h"
#import "AppDelegate.h"
#import "Connection.h"
#import "StringAttributeTableViewCell.h"
#import "BooleanAttributeTableViewCell.h"
#import "GenericAttributeTableViewCell.h"
#import "ClassAttribute.h"
#import "Reference.h"
#import "ReferenceTableViewCell.h"

@interface ComponentDetailsView ()

@end

@implementation ComponentDetailsView

@synthesize comp, delegate;



- (void)prepare {
    
    
    
    outConnectionsTable.delegate = self;
    outConnectionsTable.dataSource = self;
    
    // Do any additional setup after loading the view.
    nameTextField.text = comp.name;
    
    CGRect oldFrame = previewComponent.frame;
    temp = [[Component alloc] initWithFrame:CGRectMake(0, 0, oldFrame.size.width, oldFrame.size.height)];
    temp.name = comp.name;
    temp.fillColor = comp.fillColor;
    [temp updateNameLabel];
    temp.connections = [NSMutableArray arrayWithArray:comp.connections];
    temp.type = comp.type;
    temp.shapeType = comp.shapeType;
    
    for (UIGestureRecognizer *recognizer in temp.gestureRecognizers) {
        [temp removeGestureRecognizer:recognizer];
    }
    for (UIGestureRecognizer *recognizer in previewComponent.gestureRecognizers) {
        [previewComponent removeGestureRecognizer:recognizer];
    }
    
    //Remove all previewComponents subviews
    NSArray *viewsToRemove = [previewComponent subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [previewComponent addSubview:temp];
    
    [temp setNeedsDisplay];
    
    nameTextField.delegate = self;
    dele = [[UIApplication sharedApplication]delegate];
    
    typeLabel.text = comp.type;
    
    Connection * tc = nil;
    connections = [[NSMutableArray alloc] init];
    for(int i = 0; i< dele.connections.count; i++){
        tc = [dele.connections objectAtIndex:i];
        if(tc.source == comp)
            [connections addObject:tc];
    }
    
    [outConnectionsTable reloadData];
    
    [attributesTable setDelegate:self];
    [attributesTable setDataSource:self];
    [attributesTable reloadData];
}

- (IBAction)closeDetailsViw:(id)sender {
    [delegate closeDetailsViewAndUpdateThings];
}



-(void)updateLocalConenctions{
    Connection * tc = nil;
    connections = [[NSMutableArray alloc] init];
    for(int i = 0; i< dele.connections.count; i++){
        tc = [dele.connections objectAtIndex:i];
        if(tc.source == comp)
            [connections addObject:tc];
    }
    
    [outConnectionsTable reloadData];
}



#pragma mark UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField.text.length >0){
        comp.name = textField.text;
        temp.name = textField.text;
        [temp updateNameLabel];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }else{
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * new = [nameTextField.text stringByReplacingCharactersInRange:range withString:string];
    if(new.length > 0){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
        comp.name = new;
        temp.name = new;
        [temp updateNameLabel];
        return YES;
    }
    else
        return NO;
}


- (IBAction)deleteCurrentComponent:(id)sender {
    
    //Remove all connections for this element
    Connection * conn = nil;
    NSMutableArray * connsToRemove = [[NSMutableArray alloc] init];
    for(int i = 0; i<dele.connections.count; i++){
        conn = [dele.connections objectAtIndex:i];
        
        if(conn.target == comp || conn.source == comp){
            //Remove this connection
            [connsToRemove addObject:conn ];
        }
    }
    
    for(int i = 0; i<connsToRemove.count; i++){
        conn = [connsToRemove objectAtIndex:i];
        [dele.connections removeObject:conn];
    }
    
    
    //Remove this component
    [comp removeFromSuperview];
    [dele.components removeObject:comp];
    
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    
    
    [delegate closeDetailsViewAndUpdateThings];
}




#pragma mark UITableView Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == attributesTable){
        return comp.attributes.count;
    }else if(tableView == outConnectionsTable){
        return connections.count;
    }else return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell;
    
    if(tableView == outConnectionsTable){
        
        Connection * c = [connections objectAtIndex:indexPath.row];
        
        cell= [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier] ;
        }
        cell.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.text = c.name;
        return cell;
        
    }else if(tableView == attributesTable){
        
        //Check component type
        
        if([[comp.attributes objectAtIndex:indexPath.row]isKindOfClass:[ClassAttribute class]]){
            
            ClassAttribute * attr = [comp.attributes objectAtIndex:indexPath.row];
            NSString * type = attr.type;
            
            if([type isEqualToString:@"EString"]){
                StringAttributeTableViewCell * atvc = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
                
                if(atvc == nil){
                    NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"StringAttributeTableViewCell"
                                                                  owner:self
                                                                options:nil];
                    atvc = [nib objectAtIndex:0];
                    atvc.attributeNameLabel.text = attr.name;
                    atvc.typeLabel.text = attr.type;
                }
                return atvc;
                
            }else if([type isEqualToString:@"EBoolean"]){
                BooleanAttributeTableViewCell * batvc = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
                if(batvc == nil){
                    NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"BooleanAttributeTableViewCell"
                                                                  owner:self
                                                                options:nil];
                    batvc = [nib objectAtIndex:0];
                    batvc.nameLabel.text = attr.name;
                    batvc.typeLabel.text = attr.type;
                    
                    
                }
                return batvc;
            }else{
                GenericAttributeTableViewCell * gatvc = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
                if(gatvc == nil){
                    NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"GenericAttributeTableViewCell"
                                                                  owner:self
                                                                options:nil];
                    gatvc = [nib objectAtIndex:0];
                    gatvc.nameLabel.text = attr.name;
                    gatvc.typeLabel.text = attr.type;
                }
                return gatvc;
            }
            
            
            
            return nil;
        }else if([[comp.attributes objectAtIndex:indexPath.row] isKindOfClass:[Reference class]]){
            Reference * ref = [comp.attributes objectAtIndex:indexPath.row];
            ReferenceTableViewCell * rtvc = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
            if(rtvc == nil){
                NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReferenceTableViewCell" owner:self options:nil];
                rtvc = [nib objectAtIndex:0];
                
                rtvc.nameLabel.text = ref.name;
                rtvc.targetLabel.text = ref.target;
                rtvc.minLabel.text = [ref.min description];
                rtvc.maxLabel.text = [ref.max description];
                [rtvc.containmentSwitch setOn:ref.containment];
            }
            return rtvc;
        }
    }
    
    
    
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
/*
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 //add code here for when you hit delete
 Connection * toDelete = [connections objectAtIndex:indexPath.row];
 
 [dele.connections removeObject:toDelete];
 
 [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
 [self updateLocalConenctions];
 }
 }*/
@end
