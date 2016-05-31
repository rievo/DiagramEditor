//
//  AttributesFilterView.m
//  DiagramEditor
//
//  Created by Diego on 10/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "AttributesFilterView.h"
#import "AppDelegate.h"
#import "RowSwitchTableViewCell.h"

@implementation AttributesFilterView

@synthesize delegate, attrsArray;



-(void)awakeFromNib{
    UITapGestureRecognizer * tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGr.delegate = self;
    [background addGestureRecognizer:tapGr];
    
    isEnabled = filterEnabled.isOn;
}

- (IBAction)coseView:(id)sender {
    [self removeFromSuperview];
    [delegate closedAttributesFilterViewWithEnabled:isEnabled];
}


-(void)prepare{
    atrributesTable.delegate = self;
    atrributesTable.dataSource = self;
}

-(void)handleTap:(UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
    [delegate closedAttributesFilterViewWithEnabled:isEnabled];
}
- (IBAction)setFilterEnabled:(id)sender {
    
    if(sender == filterEnabled){
        UISwitch * sen = (UISwitch *)sender;
        BOOL value = sen.isOn;
        
        if(value == true){
            atrributesTable.userInteractionEnabled = YES;
            atrributesTable.alpha = 1.0;
            [selectAllSwitch setEnabled:YES];
            selectAllSwitch.alpha = 1.0;
        }else{ //Disable everything
            atrributesTable.userInteractionEnabled = NO;
            atrributesTable.alpha = 0.5;
            [selectAllSwitch setEnabled:NO];
            selectAllSwitch.alpha = 0.5;
            
        }
        
        isEnabled = value;
    }   
}

- (IBAction)selectAllAttributes:(id)sender {
    
    BOOL value = selectAllSwitch.isOn;
    
    
    BOOL newval;
    
    
    newval = value;
    
    
    NSMutableDictionary * temp = nil;
    for(int i = 0; i< attrsArray.count; i++){
        temp = [attrsArray objectAtIndex:i];
        NSArray * keys = [temp allKeys];
        NSString * className = keys[0];
        
        //Lo pongo a sí
        [temp setObject:[NSNumber numberWithBool:newval] forKey:className];
    }
    
    [atrributesTable reloadData];
    
    NSString * newText = nil;
    
    if (newval == NO) { //El texto será poner a sí
        newText = @"Select all attributes";
    }else{
        newText = @"Deselect all attributes";
    }
    
    label.text = newText;
}

#pragma mark UITableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [attrsArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cfvc";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    NSMutableDictionary * dic = [attrsArray objectAtIndex:indexPath.row];
    
    NSArray * keys = [dic allKeys];
    
    NSString * attrName = keys[0];
    BOOL value = [[dic objectForKey:attrName]boolValue];
    
    
    RowSwitchTableViewCell * rstvc = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if(rstvc == nil){
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"RowSwitchTableViewCell"
                                                      owner:self
                                                    options:nil];
        rstvc = [nib objectAtIndex:0];
        
        
        [rstvc.switchValue setOn:value];
        [rstvc.nameLabel setText:attrName];
        
        rstvc.dictionary = dic;
        
        rstvc.backgroundColor = [UIColor clearColor];
    }
    return rstvc;
    
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
*/

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}


@end
