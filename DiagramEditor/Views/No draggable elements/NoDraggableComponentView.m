//
//  NoDraggableComponentView.m
//  DiagramEditor
//
//  Created by Diego on 22/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NoDraggableComponentView.h"
#import "AppDelegate.h"
#import "Component.h"
#import "ClassAttribute.h"

#import "StringAttributeTableViewCell.h"
#import "BooleanAttributeTableViewCell.h"
#import "GenericAttributeTableViewCell.h"
#import "ReferenceTableViewCell.h"
#import "DoubleTableViewCell.h"
#import "IntegerTableViewCell.h"
#import "EnumTableViewCell.h"

@implementation NoDraggableComponentView

@synthesize elementName, delegate, paletteItem;


-(void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer * tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapGr];
    [tapGr setDelegate:self];
    
    table.delegate = self;
    table.dataSource = self;
    
    
    attributesTable.delegate = self;
    attributesTable.dataSource = self;
    
    dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if([dele amITheMaster] || dele.inMultipeerMode == NO){
        
        [createInstanceButton setEnabled:YES];
        [createInstanceButton setAlpha:1.0];
    }else{
        [createInstanceButton setEnabled:NO];
        [createInstanceButton setAlpha:0.5];
    }
    
    oldFrame = itemInfoGroup.frame;
    outCenter = CGPointMake(container.center.x, background.frame.size.height + itemInfoGroup.frame.size.height);
    
    [itemInfoGroup setHidden:YES];
    
     [self updateInstancesCount];
}

-(void)updateInstancesCount{
    instancesCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)thisArray.count];
}

-(void)updateNameLabel{
    [nodeTypeLabel setText:elementName];
    
    thisArray = [dele.elementsDictionary objectForKey:elementName];
}



-(void)showItemInfoGroup{
    
    
    if(temporalComponent == nil){
        temporalComponent = [paletteItem getComponentForThisPaletteItem]; //Me crea un component vacío (Para cuando quiero añadir)
    }
    
    
    itemInfoGroup.center = outCenter;
    [itemInfoGroup setHidden:NO];
    [itemInfoGroup setAlpha:0];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [itemInfoGroup setAlpha:1];
                         [itemInfoGroup setFrame:oldFrame];
                     }
                     completion:^(BOOL finished) {
                         [attributesTable reloadData];
                         
                     }];
}

-(void)hideAndResetItemInfoGroup{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [itemInfoGroup setCenter:outCenter];
                     }
                     completion:^(BOOL finished) {
                         
                         [itemInfoGroup setAlpha:0];
                         [itemInfoGroup setHidden:YES];
                         temporalComponent = nil;
                     }];
}

-(void)showItemInfoGroupForItem: (Component *)component{
    temporalComponent = component;
    [self showItemInfoGroup];
    
}

- (IBAction)addCurrentNode:(id)sender {
    
    temporalComponent = nil;
    [self showItemInfoGroup];
    
    
}

- (IBAction)cancelItemInfo:(id)sender {
    [self hideAndResetItemInfoGroup];
    temporalComponent = nil;
     [self updateInstancesCount];
}

- (IBAction)confirmSaveNode:(id)sender {
    [thisArray removeObject:temporalComponent];
    [thisArray addObject:temporalComponent];
    [table reloadData];
    temporalComponent = nil;
    [table reloadData];
    [attributesTable reloadData];
    [self hideAndResetItemInfoGroup];
     [self updateInstancesCount];
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
    
    
    if(tableView == table)
        return thisArray.count;
    else if(tableView == attributesTable)
        return temporalComponent.attributes.count;
    else
        return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    
    if (cell == nil)
    {
        if(tableView == table){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier] ;
            Component * comp = [thisArray objectAtIndex:indexPath.row];
            
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.text = [NSString stringWithFormat:@"Name: %@", [comp getName]];
        }else if(tableView == attributesTable){
            /*cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier] ;
            ClassAttribute * atr = [temporalComponent.attributes objectAtIndex:indexPath.row];
            cell.textLabel.text = atr.name;
            //cell.textLabel.text = @"--";
            //Component * comp = [thisArray objectAtIndex:indexPath.row];*/
            /*if([[temporalComponent.attributes objectAtIndex:indexPath.row]isKindOfClass:[ClassAttribute class]]){
                
                ClassAttribute * attr = [temporalComponent.attributes objectAtIndex:indexPath.row];
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
                        atvc.comp = temporalComponent;
                        atvc.associatedAttribute = attr;
                        atvc.textField.text = attr.currentValue;
                        atvc.textField.textColor = dele.blue4;

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
                        batvc.nameLabel.textColor = dele.blue4;
                        //batvc.typeLabel.text = attr.type;
                        batvc.backgroundColor = [UIColor clearColor];
                        
                        
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
                        gatvc.nameLabel.textColor = dele.blue4;
                        //gatvc.typeLabel.text = attr.type;
                        gatvc.backgroundColor = [UIColor clearColor];
                    }
                    return gatvc;
                }
                
                
                
                return nil;
            }*/
            
            
            ClassAttribute * attr = [temporalComponent.attributes objectAtIndex:indexPath.row];
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
                    atvc.comp = temporalComponent;
                    atvc.associatedAttribute = attr;
                
                    
                    
                    if([dele amITheMaster] || dele.inMultipeerMode == NO){
                        [atvc.textField setEnabled:YES];
                    }else{
                        [atvc.textField setEnabled:NO];
                    }
                    
                    for(ClassAttribute * atr in temporalComponent.attributes){
                        if([atr.name isEqualToString:atvc.attributeNameLabel.text]){
                            atvc.textField.text =  atr.currentValue ;
                        }
                    }

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
                    
                    if([dele amITheMaster]|| dele.inMultipeerMode == NO){
                        [batvc.switchValue setEnabled:YES];
                    }else{
                        [batvc.switchValue setEnabled:NO];
                    }
                    
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
            }else if([type isEqualToString:@"EDouble"] || [type isEqualToString:@"EFloat"]){
                
                DoubleTableViewCell * datvc = [tableView dequeueReusableCellWithIdentifier:@"DoubleCell"];
                if(datvc == nil){
                    NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"DoubleTableViewCell"
                                                                  owner:self
                                                                options:nil];
                    datvc = [nib objectAtIndex:0];
                    datvc.label.text = attr.name;
                    datvc.associatedAttribute = attr;
                    datvc.backgroundColor = [UIColor clearColor];
                    datvc.comp = temporalComponent;
                    
                    if([dele amITheMaster]|| dele.inMultipeerMode == NO){
                        [datvc.textField setEnabled:YES];
                    }else{
                        [datvc.textField setEnabled:NO];
                    }
                    
                    //Update textfield value for this attribute value
                    [datvc.textField setText:attr.currentValue];
                    datvc.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return  datvc;
                
            }else if([type isEqualToString:@"EInt"] || [type isEqualToString:@"EInteger"]){
                
                IntegerTableViewCell * iatvc = [tableView dequeueReusableCellWithIdentifier:@"IntCell"];
                if(iatvc == nil){
                    NSArray * nib = [[NSBundle mainBundle]loadNibNamed:@"IntegerTableViewCell" owner:self options:nil];
                    iatvc  = [nib objectAtIndex:0];
                    iatvc.label.text = attr.name;
                    iatvc.associatedAttribute = attr;
                    iatvc.backgroundColor = [UIColor clearColor];
                    iatvc.comp = temporalComponent;
                    
                    if([dele amITheMaster]|| dele.inMultipeerMode == NO){
                        [iatvc.textField setEnabled:YES];
                    }else{
                        [iatvc.textField setEnabled:NO];
                    }
                    [iatvc.textField setText:attr.currentValue];
                    iatvc.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return iatvc;
            }else{
                
                //It is an enum?
                if([dele.enumsDic objectForKey:attr.type] != nil){
                    NSArray * options = [dele.enumsDic objectForKey:attr.type];
                    EnumTableViewCell * etvc = [tableView dequeueReusableCellWithIdentifier:@"enumID"];
                    if(etvc == nil){
                        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"EnumTableViewCell"
                                                                      owner:self
                                                                    options:nil];
                        etvc = [nib objectAtIndex:0];
                        etvc.options = options;
                        etvc.label.text = attr.name;
                        etvc.backgroundColor = [UIColor clearColor];
                        etvc.comp = temporalComponent;
                        etvc.associatedAttribute = attr;
                
                        if([dele amITheMaster]|| dele.inMultipeerMode == NO){
                            [etvc.optionsPicker setUserInteractionEnabled:YES];
                        }else{
                            [etvc.optionsPicker setUserInteractionEnabled:NO];
                        }
                        
                        [etvc prepare];
                        etvc.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                    }
                    return etvc;
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
                
            }

        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == table){
        Component * comp = [thisArray objectAtIndex:indexPath.row];
        //temporalComponent = comp;
        [self showItemInfoGroupForItem:comp];
    }
    
}

//Hide references
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(tableView == attributesTable){
        if([[temporalComponent.attributes objectAtIndex:indexPath.row] isKindOfClass:[ClassAttribute class]]){
            return 45;
        }else{
            return 0;
        }
    }else{
        return 45;
    }
    
    return 45;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == attributesTable){
        return NO;
    }else if(tableView == table){
        return YES;
    }else
        return NO;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == table){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            Component * comp = [thisArray objectAtIndex:indexPath.row];
            [thisArray removeObject:comp];
            [table reloadData];
            [self hideAndResetItemInfoGroup];
            
            [self updateInstancesCount];
        }
    }

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


@end
