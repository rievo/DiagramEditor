//
//  CustomTableHeader.m
//  DiagramEditor
//
//  Created by Diego on 7/4/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "CustomTableHeader.h"
#import "ConnectionDetailsView.h"
@implementation CustomTableHeader

@synthesize countLabel, containerTable, sectionIndex, owner, openCloseOutlet;

-(void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer * tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGr];
}

-(void)handleTap:(UITapGestureRecognizer *)recog{
    
    
    if(sectionIndex == 0){ //Attributes
        if(owner.attributesCollapsed == YES){ //Expand
            owner.attributesCollapsed = NO;
            //Expand
            [containerTable reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            //[openClosebutton.titleLabel setText:@"-"];
            openCloseOutlet.image = [UIImage imageNamed:@"upArrowBlack"];
            
        }else{
            owner.attributesCollapsed = YES;
            //Collapse
            [containerTable reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            openCloseOutlet.image = [UIImage imageNamed:@"rightArrow"];
            
        }
        
    }else if(sectionIndex == 1){ //Instances
        if(owner.instancesCollapsed == YES){ //Expand
            owner.instancesCollapsed = NO;
            //Expand
            [containerTable reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            openCloseOutlet.image = [UIImage imageNamed:@"upArrowBlack"];
            
            
        }else{
            owner.instancesCollapsed = YES;
            //Collapse
            [containerTable reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            openCloseOutlet.image = [UIImage imageNamed:@"rightArrow"];
            
        }
    }

    
}



- (IBAction)openCloseSection:(id)sender {
    
}

@end
