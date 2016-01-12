//
//  PaletteItemCreatorViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 12/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "PaletteItemCreatorViewController.h"
#import "PaletteItem.h"
#import "AppDelegate.h"

@interface PaletteItemCreatorViewController ()

@end

@implementation PaletteItemCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dele = [UIApplication sharedApplication].delegate;
    // Do any additional setup after loading the view.
    
    [canvas prepareEditor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closePItemCreator:(id)sender {
    
    PaletteItem * pi = [[PaletteItem alloc] init];
    pi.isImage = YES;
    
    
    pi.image = [self imageWithImage:canvas.incrementalImage scaledToSize:CGSizeMake(70, 70)];
    
    pi.width = [NSNumber numberWithInt:70];
    pi.height = [NSNumber numberWithInt:70];
    pi.type = @"graphicR:Node";
    
    [dele.paletteItems addObject:pi];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
