//
//  SessionUserCell.h
//  DiagramEditor
//
//  Created by Diego on 23/6/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionUserCell : UITableViewCell{
    

}
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
@property (weak, nonatomic) IBOutlet UILabel *masterLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
