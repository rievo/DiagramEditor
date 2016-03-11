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
    [background addGestureRecognizer:tapGr];
}

- (IBAction)coseView:(id)sender {
    [self removeFromSuperview];
    [delegate closedAttributesFilterView];
}


-(void)prepare{
    atrributesTable.delegate = self;
    atrributesTable.dataSource = self;
}

-(void)handleTap:(UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
    [delegate closedAttributesFilterView];
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
        
        
    }
    return rstvc;
    
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
*/

@end
