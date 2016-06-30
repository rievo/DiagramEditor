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
#import "LinkPalette.h"
#import "ExpandableItemView.h"
#import "EditorViewController.h"

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
    
    previewComponent.layer.masksToBounds = NO;
}
- (void)prepare {
    
    
    
    table.delegate = self;
    table.dataSource = self;
    
    //remove all subviews from previewcomponentView
    NSArray *vtr = [previewComponentView subviews];
    for (UIView *v in vtr) {
        [v removeFromSuperview];
    }
    

    NSData * buff = [NSKeyedArchiver archivedDataWithRootObject:comp];
    previewComponent = [NSKeyedUnarchiver unarchiveObjectWithData:buff];
    
    CGRect frame = previewComponent.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = previewComponentView.frame.size.width;
    frame.size.height = previewComponentView.frame.size.height;
    [previewComponent setFrame:frame];
    
    [previewComponentView addSubview:previewComponent];
    
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
    
    
    
    
    //[previewComponent setNeedsDisplay];
    
    classLabel.text = comp.className;
    
    //Tap to close
    
    [table reloadData];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateThisView:)
                                                 name:@"repaintCanvas" object:nil];
    
}

-(void)updateThisView: (NSNotification *)not{
    [self setNeedsDisplay];
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
    
    [table reloadData];
}



#pragma mark UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField.text.length >0){
        [previewComponent updateNameLabel];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }else{
        
    }
}
/*
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
}*/


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
    if(comp.isExpandable == YES){
        int count = 2;
        
        count = count + (int)comp.expandableItems.count;
        /*NSArray * keys = [comp.linkPaletteDic allKeys];
        for(NSString * key in keys){
            LinkPalette * lp = [comp.linkPaletteDic objectForKey:key];
            if(lp.isExpandableItem == YES){
                count ++;
            }
        }*/
        return count;
    }else
        return 2;    //0-> Attributes   1->Out connections
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0){
        return comp.attributes.count;
    }else if(section == 1){
        return connections.count;
    }else{
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"Attributes";
    }else if(section == 1){
        return @"Out connections";
    }else{
        int index = (int)section -2;
        LinkPalette * lp = comp.expandableItems[index];
        return [NSString stringWithFormat:@"Expandable item %d", lp.expandableIndex];
    }

}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section >= 1){
        return YES;
    }else{
        return NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section > 1){ //It is a ExpandableItem
        int index = (int)indexPath.section -2;
        LinkPalette * lp = comp.expandableItems[index];
        ExpandableItemView * eiv = [[[NSBundle mainBundle] loadNibNamed:@"ExpandableItemView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        
        [eiv prepare];
        eiv.lp = lp;
        eiv.comp = comp;
        [eiv setTitle:lp.paletteName];
        
        [eiv setFrame:dele.evc.view.frame];
        
        [dele.evc.view addSubview:eiv];
        
    }else if(indexPath.section == 1){
        
            Connection * conn = [connections objectAtIndex:indexPath.row];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"showConnNot" object: conn];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell;
    
    if(indexPath.section == 1){
        static NSString *MyIdentifier = @"outCellID";
        
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
        cell.textLabel.text = [NSString stringWithFormat:@"Name: %@",c.className];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if(indexPath.section == 0){
        static NSString *MyIdentifier = @"AttrCellID";
        
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
                    [previewComponent updateNameLabel];
                    //[previewComponent updateNameLabel];

                    
                    //atvc.typeLabel.text = attr.type;
                    atvc.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return atvc;
                
            }else if([type isEqualToString:@"EBoolean"] || [type isEqualToString:@"EBooleanObject"]){
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
                    
                    batvc.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                }
                return batvc;
            }else{
                GenericAttributeTableViewCell * gatvc = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
                if(gatvc == nil){
                    NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"GenericAttributeTableViewCell"
                                                                  owner:self
                                                                options:nil];
                    gatvc = [nib objectAtIndex:0];
                    gatvc.nameLabel.text =  [NSString stringWithFormat:@"%@: %@", attr.name, attr.type];//attr.name;
                    //gatvc.typeLabel.text = attr.type;
                    gatvc.backgroundColor = [UIColor clearColor];
                    gatvc.selectionStyle = UITableViewCellSelectionStyleNone;
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
                rtvc.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            //[rtvc setHidden:YES];
            return rtvc;
        }
    }else{
        //Expandable item
        int index = (int)indexPath.section -2;
        LinkPalette * lp = comp.expandableItems[index];
        NSString *MyIdentifier = [NSString stringWithFormat:@"ExpItemId%d",lp.expandableIndex];
        
       
        
        cell= [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier] ;
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumScaleFactor = 0.5;
        cell.textLabel.textColor = dele.blue4;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",lp.paletteName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
    
    
    
    
    return cell;
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
        return YES;
    else
        return NO;
}
*/


//Hide references
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.section == 1){
        return 47;
    }else if(indexPath.section == 0){
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
    
    if(indexPath.section == 1){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            //add code here for when you hit delete
            Connection * toDelete = [connections objectAtIndex:indexPath.row];
            
            [dele.connections removeObject:toDelete];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
            [self updateLocalConenctions];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color

    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:dele.blue1];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
     header.contentView.backgroundColor = dele.blue3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        // whatever height you'd want for a real section header
        return 20;
    }
}


#pragma mark UITapGestureRecognizer methods
-(void)handleTap: (UITapGestureRecognizer *)recog{
    
    [self setHidden:YES];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background || touch.view != blurView) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}


@end
