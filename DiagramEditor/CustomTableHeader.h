//
//  CustomTableHeader.h
//  DiagramEditor
//
//  Created by Diego on 7/4/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConnectionDetailsView;

@interface CustomTableHeader : UITableViewHeaderFooterView{
    
   
}
@property (weak, nonatomic) IBOutlet UILabel *sectionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
- (IBAction)openCloseSection:(id)sender;

@property NSInteger sectionIndex;
@property UITableView * containerTable;

@property ConnectionDetailsView * owner;
@property (weak, nonatomic) IBOutlet UIImageView *openCloseOutlet;

@end
