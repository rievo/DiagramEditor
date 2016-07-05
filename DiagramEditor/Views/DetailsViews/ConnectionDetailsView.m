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
#import "PaletteItem.h"
#import "NoDraggableComponentView.h"
#import "ClassAttribute.h"

#import "StringAttributeTableViewCell.h"
#import "BooleanAttributeTableViewCell.h"
#import "GenericAttributeTableViewCell.h"

#import "CustomTableHeader.h"

@implementation ConnectionDetailsView



@synthesize delegate, background, connection,instancesCollapsed, attributesCollapsed;


- (void)awakeFromNib {
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];
    
    informationTable.delegate = self;
    informationTable.dataSource = self;
    
    instancesCollapsed = YES;
    attributesCollapsed = YES;
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

- (IBAction)associateNewInstance:(id)sender {
    
    
    [connection.source showAddReferencePopupForConnection:connection];
    
    [informationTable reloadData];
}

-(void)prepare{
    
    
    
    associatedComponentsArray = [[NSMutableArray alloc] init];
    //Llenamos ese array con las instancias asociadas a esta conexión
    
    //instancesTable.delegate = self;
    //instancesTable.dataSource = self;
    
    
    for (NSString * key in [connection.instancesOfClassesDictionary allKeys]) {
        NSLog(@"%@", key);
        NSMutableArray * tempArray = [connection.instancesOfClassesDictionary objectForKey:key];
        
        for(Component * comp in tempArray){
            [associatedComponentsArray addObject:comp];
        }
    }
    
    //[instancesTable reloadData];
    
    attributesArray = [[NSMutableArray alloc] init];
    
    
    for(int i = 0; i< connection.attributes.count; i++){
        [attributesArray addObject:[connection.attributes objectAtIndex:i]];
    }
    
    //[attributesTable reloadData];
    
    classLabel.text = connection.className;
    
    
    sourceComponentViewContainer.backgroundColor = [UIColor clearColor];
    targetComponentViewContainer.backgroundColor = [UIColor clearColor];
    
    //Load components preview
    
    NSData * sourceBuf = [NSKeyedArchiver archivedDataWithRootObject:connection.source];
    NSData * targetBuf = [NSKeyedArchiver archivedDataWithRootObject:connection.target];
    
    sourceComp = [NSKeyedUnarchiver unarchiveObjectWithData:sourceBuf];
    targetComp = [NSKeyedUnarchiver unarchiveObjectWithData:targetBuf];
    
    CGRect srect = sourceComponentViewContainer.bounds;
    CGRect trect = targetComponentViewContainer.bounds;
    
    
    [sourceComp setFrame:srect];
    [targetComp setFrame:trect];
    
    
    //Remove all subviews from containers
    
    NSArray *viewsToRemove = [sourceComponentViewContainer subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    NSArray *vtr = [targetComponentViewContainer subviews];
    for (UIView *v in vtr) {
        [v removeFromSuperview];
    }
    
    
    [sourceComponentViewContainer addSubview:sourceComp];
    [targetComponentViewContainer addSubview:targetComp];
    
    [targetComp updateNameLabel];
    [sourceComp updateNameLabel];
    
    NSMutableArray * nodragarray = [connection.source getDraggablePaletteItems];
    
    if(nodragarray.count == 0){
        [addReferenceButton setHidden:YES];
    }
    
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
    return 2;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(indexPath.section == 1){ //References
        
        Component * com = [associatedComponentsArray objectAtIndex:indexPath.row];
        //PaletteItem * sender = (PaletteItem *)recog.view;
        
        NoDraggableComponentView * nod = [[[NSBundle mainBundle] loadNibNamed:@"NoDraggableComponentView"
                                                                        owner:self
                                                                      options:nil] objectAtIndex:0];
        
        nod.elementName = com.className;
        //nod.paletteItem = sender;
        
        [nod updateNameLabel];
        [nod setFrame:self.frame];
        [self addSubview:nod];
        
        [nod showItemInfoGroupForItem:com];
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CustomTableHeader * head = [[[NSBundle mainBundle]loadNibNamed:@"CustomTableHeader" owner:self options:nil]objectAtIndex:0];
    if(section == 0){ //Attributes
        return head.bounds.size.height;
    }else if(section == 1){ //Instances
        if(associatedComponentsArray.count == 0){
            return 0;
        }else{
            return head.bounds.size.height;
        }
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if(section == 0){ //Attributes
        if(attributesCollapsed == YES)
            return 0;
        else
            return attributesArray.count;
    }else if(section == 1){ //Instances
        //if(instancesCollapsed == YES)
        //    return 0;
        //else
            return  associatedComponentsArray.count;
    }else{
        return 0;
    }
    /*if (tableView == instancesTable) {
     return associatedComponentsArray.count;
     }else{
     return 0;
     }*/
    //return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cdvcell";
    
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0){ //Attributes
        static NSString *MyIdentifier = @"AttrCellID";
        
        //Check component type
        
        if([[connection.attributes objectAtIndex:indexPath.row]isKindOfClass:[ClassAttribute class]]){
            
            ClassAttribute * attr = [connection.attributes objectAtIndex:indexPath.row];
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
                    //atvc.comp = connection;
                    atvc.associatedAttribute = attr;
                    //atvc.detailsPreview = previewComponent;
                    
                    
                    
                    for(ClassAttribute * atr in connection.attributes){
                        if([atr.name isEqualToString:atvc.attributeNameLabel.text]){
                            atvc.textField.text =  atr.currentValue ;
                        }
                    }
                    //[comp updateNameLabel];
                    //[previewComponent updateNameLabel];
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
        }
        //return nil;
        
    }else if(indexPath.section == 1){ //Instances
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
        cell.textLabel.text = [NSString stringWithFormat:@"· %@", c.name];
    }else{
        return nil;
    }
    
    /* if(tableView == instancesTable){
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
     }*/
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    //if(indexPath.section == 0){ //Attributes
    //    return 0;
    //}else if(indexPath.section == 1){ //Instances
    /*    NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReferenceTableViewCell"
     owner:self
     options:nil];
     ReferenceTableViewCell * temp = [nib objectAtIndex:0];
     return temp.frame.size.height;*/
    //}
    /*if(tableView == instancesTable){
     NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReferenceTableViewCell"
     owner:self
     options:nil];
     ReferenceTableViewCell * temp = [nib objectAtIndex:0];
     return temp.frame.size.height;
     }else{
     return 30;
     }*/
    return 40;
    
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CustomTableHeader * head = [[[NSBundle mainBundle]loadNibNamed:@"CustomTableHeader" owner:self options:nil]objectAtIndex:0];
    head.sectionIndex = section;
    head.containerTable = tableView;
    head.owner = self;
    if(section == 0){//Attributes
        head.sectionNameLabel.text = @"Attributes";
        head.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)attributesArray.count];
        
        if(attributesCollapsed == true){
            head.openCloseOutlet.image  = [UIImage imageNamed:@"rightArrow"];
            
        }else{
            head.openCloseOutlet.image  = [UIImage imageNamed:@"upArrowBlack"];
        }
        
    }else if(section == 1){ //Instances
        
        if(associatedComponentsArray.count == 0){
            return nil;
        }else{
            head.sectionNameLabel.text = @"References";
            head.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)associatedComponentsArray.count];
            if(instancesCollapsed == true){
                head.openCloseOutlet.image  = [UIImage imageNamed:@"rightArrow"];
                
            }else{
                head.openCloseOutlet.image  = [UIImage imageNamed:@"upArrowBlack"];
            }
        }

    
        
    }else{
        
    }
    
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // To "clear" the footer view
    return [UIView new] ;
}
@end
