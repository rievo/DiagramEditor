//
//  ExpandableItemView.m
//  DiagramEditor
//
//  Created by Diego on 16/6/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ExpandableItemView.h"
#import "Component.h"
#import "PaletteItem.h"
#import "Reference.h"
#import "ClassAttribute.h"
#import "StringAttributeTableViewCell.h"
#import "BooleanAttributeTableViewCell.h"
#import "GenericAttributeTableViewCell.h"

@implementation ExpandableItemView

@synthesize background, lp, comp;

-(void)setTitle:(NSString *)title{
    titleLabel.text = title;
    [titleLabel setNeedsDisplay];
}

-(PaletteItem *)getPaletteItemForClassName:(NSString *)name{
    PaletteItem * temp = nil;
    for(PaletteItem * pi in dele.noVisibleItems){
        if([pi.className isEqualToString:name]){
            temp = pi;
        }
    }
    
    for(PaletteItem * pi in dele.paletteItems){
        if([pi.className isEqualToString:name]){
            temp = pi;
        }
    }
    return temp;
}

- (IBAction)cancelInstanceCreation:(id)sender {
    [createInstanceView setHidden:YES];
    creatingComponent= nil;
}

- (IBAction)confirmInstanceCreation:(id)sender {
    
    if(![lp.instances containsObject:creatingComponent]){
        [lp.instances addObject:creatingComponent];
        
    }
   
    
    [table reloadData];
    creatingComponent = nil;
    [createInstanceView setHidden:YES];
    
}

-(void)prepare{
    table.dataSource = self;
    table.delegate = self;
    dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    tapgr.delegate = self;
    
    [createInstanceView setHidden:YES];
    
    creatingComponent = nil;
    
    componentTable.dataSource = self;
    componentTable.delegate = self;
}

- (IBAction)addNewItem:(id)sender {
    [createInstanceView setHidden:NO];
    
    PaletteItem * whichItemRepresentsMe  =[self getPaletteItemForClassName:lp.className];
    Reference * refToCheck = [whichItemRepresentsMe getReferenceForName:lp.referenceInClass];
    
    NSString * targetClass = refToCheck.target;
    
    
    PaletteItem * destinyItem = [self getPaletteItemForClassName:targetClass];
    creatingComponent = [destinyItem getComponentForThisPaletteItem];
    
    [componentTable reloadData];
}


-(NSString *)getNameForComponent:(Component *)c{
    NSString * text = @"";
    
    for(ClassAttribute * ca in c.attributes){
        text = [text stringByAppendingString:[NSString stringWithFormat:@"%@ : \"%@\" ", ca.name, ca.currentValue]];
        
    }
    
    return text;
}

#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == componentTable){
        if(creatingComponent == nil)
            return 0;
        else
            return creatingComponent.attributes.count;
    }else if(tableView == table){
        return lp.instances.count;
    }else
        return 0;
    
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


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == table){
        static NSString *MyIdentifier = @"instanceCell";
        
        Component * instance = [lp.instances objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        //if (cell == nil)
        //{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier] ;
            //cell.textLabel.text = [NSString stringWithFormat:@"->%@",[instance getName]];
            cell.textLabel.text = [self getNameForComponent:instance];
            cell.textLabel.minimumScaleFactor = 0.5;
            cell.textLabel.textColor = dele.blue4;
            cell.backgroundColor = [UIColor clearColor];
        //}
        return cell;
    }else if(tableView == componentTable){
        /*static NSString *MyIdentifier = @"cellCompAttribute";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        
        ClassAttribute * ca = [creatingComponent.attributes objectAtIndex:indexPath.row];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier] ;
            cell.textLabel.text = ca.name;
            cell.textLabel.minimumScaleFactor = 0.5;
            cell.textLabel.textColor = dele.blue4;
            cell.backgroundColor = [UIColor clearColor];
        }
        return cell;*/
        static NSString *MyIdentifier = @"AttrCellID";
        
        //Check component type
        
        if([[creatingComponent.attributes objectAtIndex:indexPath.row]isKindOfClass:[ClassAttribute class]]){
            
            ClassAttribute * attr = [creatingComponent.attributes objectAtIndex:indexPath.row];
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
                    atvc.comp = creatingComponent;
                    atvc.associatedAttribute = attr;
                    //atvc.detailsPreview = previewComponent;
                    
                    
                    
                    for(ClassAttribute * atr in creatingComponent.attributes){
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
        }
    
    }else{
        return nil;
    }
    
    return nil;
}

-(void)showInstanceInfo:(Component *)c{
    creatingComponent = c;
    [createInstanceView setHidden:NO];
    [componentTable reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //[self setSelectedPaletteItem:[edges objectAtIndex:indexPath.row]];
    
    if(tableView == table){
        Component * selected = [lp.instances objectAtIndex:indexPath.row];
        [self showInstanceInfo:selected];
    }
    
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
