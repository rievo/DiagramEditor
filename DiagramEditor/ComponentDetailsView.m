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

@synthesize comp, delegate, background;


-(void)awakeFromNib{
    tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleTap:)];
    [tapgr setDelegate:self];
    [background addGestureRecognizer:tapgr];
    [previewComponent setNeedsDisplay];
    [previewComponent updateNameLabel];
}
- (void)prepare {
    
    
    
    outConnectionsTable.delegate = self;
    outConnectionsTable.dataSource = self;
    
    // Do any additional setup after loading the view.
    
    //CGRect oldFrame = previewComponent.frame;
    //temp = [[Component alloc] initWithFrame:CGRectMake(0, 0, oldFrame.size.width, oldFrame.size.height)];
    previewComponent.fillColor = comp.fillColor;
    
    previewComponent.type = comp.type;
    previewComponent.shapeType = comp.shapeType;
    previewComponent.name = comp.name;
    previewComponent.isImage = comp.isImage;
    previewComponent.image = comp.image;
    [previewComponent prepare];
    [previewComponent updateNameLabel];

    
    /*for (UIGestureRecognizer *recognizer in previewComponent.gestureRecognizers) {
        [previewComponent removeGestureRecognizer:recognizer];
    }*/
    for (UIGestureRecognizer *recognizer in previewComponent.gestureRecognizers) {
        [previewComponent removeGestureRecognizer:recognizer];
    }
    
    //Remove all previewComponents subviews
    NSArray *viewsToRemove = [previewComponent subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    //[previewComponent addSubview:temp];
    
    [previewComponent setNeedsDisplay];
    
    dele = [[UIApplication sharedApplication]delegate];
    
    NSArray * parsedArr = [comp.type componentsSeparatedByString:@":"];
    typeLabel.text = [parsedArr objectAtIndex:parsedArr.count-1];
    
    //Connection * tc = nil;
    connections = [[NSMutableArray alloc] init];
    for(int i = 0; i< dele.connections.count; i++){
        Connection * tc = [dele.connections objectAtIndex:i];
        if(tc.source == comp)
            [connections addObject:tc];
    }
    
    
    
    [attributesTable setDelegate:self];
    [attributesTable setDataSource:self];
    [attributesTable reloadData];
    
    
    @try {
        [outConnectionsTable reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
    }
    
    
    [previewComponent setNeedsDisplay];
    
    //Tap to close
    
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
    
    //[outConnectionsTable reloadData];
}



#pragma mark UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField.text.length >0){
        [previewComponent updateNameLabel];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }else{
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * new = [nameTextField.text stringByReplacingCharactersInRange:range withString:string];
    if(new.length > 0){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
        [previewComponent updateNameLabel];
        [comp updateNameLabel];
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
    [previewComponent setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated{

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
cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
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
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumScaleFactor = 0.5;
        cell.textLabel.text = [NSString stringWithFormat:@"Name: "];
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
                    atvc.backgroundColor = [UIColor clearColor];
                    atvc.comp = comp;
                    atvc.associatedAttribute = attr;
                    atvc.detailsPreview = previewComponent;
                    
                    for(ClassAttribute * atr in comp.attributes){
                        if([atr.name isEqualToString:atvc.attributeNameLabel.text]){
                            atvc.textField.text =  atr.currentValue ;
                        }
                    }
                    [comp updateNameLabel];

                    
                    //atvc.typeLabel.text = attr.type;
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
                    //batvc.typeLabel.text = attr.type;
                    batvc.associatedAttribute = attr;
                    batvc.backgroundColor = [UIColor clearColor];
                    
                    //Update switch value for this attribute value
                    if(attr.currentValue == nil){
                        [batvc.switchValue setOn:NO];
                    }else if([attr.currentValue isEqualToString: @"false"]){
                        [batvc.switchValue setOn:NO];
                    }else if([attr.currentValue isEqualToString:@"true"]){
                        [batvc.switchValue setOn:YES];
                    }
                    
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
                    //gatvc.typeLabel.text = attr.type;
                    gatvc.backgroundColor = [UIColor clearColor];
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
            
            //[rtvc setHidden:YES];
            return rtvc;
        }
    }
    
    
    
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == outConnectionsTable)
        return YES;
    else
        return NO;
}



//Hide references
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(tableView == outConnectionsTable){
        return 47;
    }else if(tableView == attributesTable){
        if([[comp.attributes objectAtIndex:indexPath.row] isKindOfClass:[Reference class]]){
            return 0;
        }else{
            return 47;
        }
    }else{
        return 47;
    }
    
   
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == outConnectionsTable){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            //add code here for when you hit delete
            Connection * toDelete = [connections objectAtIndex:indexPath.row];
            
            [dele.connections removeObject:toDelete];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
            [self updateLocalConenctions];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // [[NSNotificationCenter defaultCenter]postNotificationName:@"showConnNot" object: conn];
    if(tableView == outConnectionsTable){
        Connection * conn = [connections objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showConnNot" object: conn];
    }
}


#pragma mark UITapGestureRecognizer methods
-(void)handleTap: (UITapGestureRecognizer *)recog{
    
    [self setHidden:YES];
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
