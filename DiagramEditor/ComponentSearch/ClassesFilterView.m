//
//  ClassesFilterView.m
//  DiagramEditor
//
//  Created by Diego on 10/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ClassesFilterView.h"
#import "AppDelegate.h"
#import "RowSwitchTableViewCell.h"

@implementation ClassesFilterView

@synthesize delegate, classesArray, background;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)awakeFromNib{
    UITapGestureRecognizer * tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapGr];
}
-(void)prepare{
    classesTable.delegate = self;
    classesTable.dataSource = self;
    
    [classesTable reloadData];
    
    dele = [[UIApplication sharedApplication]delegate];
    
}

- (IBAction)closeClassesFilterView:(id)sender {
    
    //TODO: Animate this view
    [self removeFromSuperview];
    [delegate closedClassedFilterView];
}

-(void)handleTap:(UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
    [delegate closedClassedFilterView];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}


#pragma mark UITableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [classesArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cfvc";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    NSMutableDictionary * dic = [classesArray objectAtIndex:indexPath.row];
    
    NSArray * keys = [dic allKeys];
    
    NSString * className = keys[0];
    BOOL value = [[dic objectForKey:className]boolValue];
    
    
    RowSwitchTableViewCell * rstvc = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if(rstvc == nil){
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"RowSwitchTableViewCell"
                                                      owner:self
                                                    options:nil];
        rstvc = [nib objectAtIndex:0];
        
        
        [rstvc.switchValue setOn:value];
        [rstvc.nameLabel setText:className];
        
        rstvc.dictionary = dic;
    
        
    }
    return rstvc;
    
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}*/

#pragma mark UISwitch delegate
- (IBAction)changeAllValues:(id)sender {
    BOOL value = selectAllSwitch.isOn;
    
    
    BOOL newval;

    
    newval = value;
    
    
    NSMutableDictionary * temp = nil;
    for(int i = 0; i< classesArray.count; i++){
        temp = [classesArray objectAtIndex:i];
        NSArray * keys = [temp allKeys];
        NSString * className = keys[0];
        
        //Lo pongo a sí
        [temp setObject:[NSNumber numberWithBool:newval] forKey:className];
    }
    
    [classesTable reloadData];
    
    NSString * newText = nil;
    
    if (newval == NO) { //El texto será poner a sí
        newText = @"Select all classes";
    }else{
        newText = @"Deselect all classes";
    }
    
    selectAllClassesLabel.text = newText;
}


@end
