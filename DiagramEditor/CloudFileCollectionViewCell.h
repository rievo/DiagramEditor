//
//  CloudFileCollectionViewCell.h
//  DiagramEditor
//
//  Created by Diego on 2/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudFileCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *preview;

@end
