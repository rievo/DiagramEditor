//
//  ChatTableViewCell.h
//  ChatTest
//
//  Created by Diego on 10/5/16.
//  Copyright © 2016 Diego. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *whoLabel;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fromMeTriangle;
@property (weak, nonatomic) IBOutlet UIImageView *fromThemTriangle;

@end
