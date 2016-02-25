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

@implementation NoDraggableComponentView

@synthesize elementName, delegate, paletteItem;


-(void)awakeFromNib{
    UITapGestureRecognizer * tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapGr];
    [tapGr setDelegate:self];
    
    table.delegate = self;
    table.dataSource = self;
    
    
    attributesTable.delegate = self;
    attributesTable.dataSource = self;
    
    dele = [[UIApplication sharedApplication]delegate];
    
    oldFrame = itemInfoGroup.frame;
    outCenter = CGPointMake(container.center.x, background.frame.size.height + itemInfoGroup.frame.size.height);
    
    [itemInfoGroup setHidden:YES];
}

-(void)updateNameLabel{
    [nodeTypeLabel setText:elementName];
    
    thisArray = [dele.elementsDictionary objectForKey:elementName];
}



-(void)showItemInfoGroup{
    
    temporalComponent = [paletteItem getComponentForThisPaletteItem];
    
    
    
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
    
    [self showItemInfoGroup];
    
    /*if(textField.text.length == 0){
     
     }else{
     [thisArray addObject:textField.text];
     [table reloadData];
     textField.text = @"";
     }*/
    
    
    
    
}

- (IBAction)cancelItemInfo:(id)sender {
    [self hideAndResetItemInfoGroup];
    temporalComponent = nil;
}

- (IBAction)confirmSaveNode:(id)sender {
    [thisArray addObject:temporalComponent];
    [table reloadData];
    temporalComponent = nil;
    
    [self hideAndResetItemInfoGroup];
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
            cell.textLabel.text = [NSString stringWithFormat:@"Name: %@", comp.name];
            
            cell.backgroundColor = [UIColor clearColor];
        }else if(tableView == attributesTable){
            /*cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier] ;
            ClassAttribute * atr = [temporalComponent.attributes objectAtIndex:indexPath.row];
            cell.textLabel.text = atr.name;
            //cell.textLabel.text = @"--";
            //Component * comp = [thisArray objectAtIndex:indexPath.row];*/
            if([[temporalComponent.attributes objectAtIndex:indexPath.row]isKindOfClass:[ClassAttribute class]]){
                
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
                        //atvc.detailsPreview = previewComponent;
                        
                        for(ClassAttribute * atr in temporalComponent.attributes){
                            if([atr.name isEqualToString:atvc.attributeNameLabel.text]){
                                atvc.textField.text =  atr.currentValue ;
                            }
                        }
                        //[comp updateNameLabel];
                        
                        
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
                        //gatvc.typeLabel.text = attr.type;
                        gatvc.backgroundColor = [UIColor clearColor];
                    }
                    return gatvc;
                }
                
                
                
                return nil;
            }

        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == table){
        Component * comp = [thisArray objectAtIndex:indexPath.row];
        temporalComponent = comp;
        [self showItemInfoGroupForItem:comp];
    }
    
}

//Hide references
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(tableView == attributesTable){
        if([[temporalComponent.attributes objectAtIndex:indexPath.row] isKindOfClass:[ClassAttribute class]]){
            return 47;
        }else{
            return 0;
        }
    }else{
        return 30;
    }
    
    
    
}



@end
