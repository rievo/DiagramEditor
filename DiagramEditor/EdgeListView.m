//
//  EdgeListView.m
//  DiagramEditor
//
//  Created by Diego on 4/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "EdgeListView.h"
#import "AppDelegate.h"
#import "PaletteItem.h"
#import "Component.h"

@implementation EdgeListView


@synthesize table, background, delegate, sourceComponent, targetComponent, edges;



-(void)awakeFromNib{
    
    table.delegate = self;
    table.dataSource = self;
    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    tapgr.delegate = self;
    edges = [[NSMutableArray alloc] init];
    
    //Recover all edges from appdelegate
    
    dele = [[UIApplication sharedApplication]delegate];

}


//true: show view
//false: there are no possible edges, don't show view

-(BOOL)reloadView{
    
    //Tengo el sourceComponent.className y el targetComponent.className
    
    edges = [[NSMutableArray alloc] init];
    
    for(PaletteItem * pi in dele.paletteItems){
        if([pi.type isEqualToString:@"graphicR:Edge"]){
            
            //aa
            //NO ME VALEN, SON REFERENCIAS
            if(([[pi getSourceClassName] isEqualToString:sourceComponent.className] || [sourceComponent.parentClassArray containsObject:[pi getSourceClassName]]) &&
               ([[pi getTargetClassName] isEqualToString:targetComponent.className] || [targetComponent.parentClassArray containsObject:[pi getTargetClassName]])){
                [edges addObject:pi];
            }
            
        }
    }
    
    
    if(edges.count == 0){ //There is no edges
        return false;
    }else{
        return true;
    }
}



#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [edges count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cellPossibleEdges";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    PaletteItem * temp = [edges objectAtIndex:indexPath.row];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
        cell.textLabel.text = temp.className;
        cell.textLabel.textColor = dele.blue4;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


-(void)setSelectedPaletteItem:(PaletteItem *)pi{
    [self setHidden:YES];
    [self removeFromSuperview];
    [delegate selectedEdge:pi];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self setSelectedPaletteItem:[edges objectAtIndex:indexPath.row]];
    
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
