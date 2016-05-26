//
//  CreateNoteView.m
//  DiagramEditor
//
//  Created by Diego on 23/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "AppDelegate.h"
#import "CreateNoteView.h"

@implementation CreateNoteView

@synthesize parentVC, delegate, textView;


-(void)drawRect:(CGRect)rect{
    UIBezierPath * backRect = [UIBezierPath bezierPathWithRect:rect];
    [color setFill];
    [backRect fill];
    
    
    UIBezierPath * path = [[UIBezierPath alloc] init];
    CGPoint startp = CGPointMake(container.frame.origin.x +20, container.frame.origin.y);
    
    [path moveToPoint:startp];
    [path addLineToPoint:CGPointMake(container.frame.origin.x + container.frame.size.width, container.frame.origin.y)];
    [path addLineToPoint:CGPointMake(container.frame.origin.x + container.frame.size.width, container.frame.origin.y+container.frame.size.height)];
    [path addLineToPoint:CGPointMake(container.frame.origin.x , container.frame.origin.y+container.frame.size.height)];
    [path addLineToPoint:CGPointMake(container.frame.origin.x , container.frame.origin.y+20)];
    
    [path closePath];
    
    [dele.blue0 setFill];
    [dele.blue3 setStroke];
    
    [path fill];
    [path stroke];
    
    UIBezierPath * corner = [[UIBezierPath alloc] init];
    [corner moveToPoint:startp];
    [corner addLineToPoint:CGPointMake(startp.x, startp.y+20)];
    [corner addLineToPoint:CGPointMake(startp.x-20, startp.y+20)];
    [corner closePath];
    [dele.blue2 setFill];
    [corner fill];
    [corner stroke];
    
}

-(void)awakeFromNib{
    color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self bringSubviewToFront:container];
    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];
    
    dele = [[UIApplication sharedApplication]delegate];
}

- (IBAction)attachImage:(id)sender {

    
    UIAlertController * ac  = [UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"Take a Photo"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                [self showCamera];
                                                            }];

    UIAlertAction * chooseFromGallery = [UIAlertAction actionWithTitle:@"Choose from gallery"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self showGallery];
                                                       }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    
    [ac addAction:takePhoto];
    [ac addAction:chooseFromGallery];
    [ac addAction:cancel];
    
    UIPopoverPresentationController * pop = ac.popoverPresentationController;
    if(pop){
        pop.sourceView = cameraButton;
        //pop.sourceRect = cameraButton.frame;
        //pop.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    

    [parentVC presentViewController:ac animated:YES completion:nil];
    
}

-(void)showCamera{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [parentVC presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Camera Available." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
}

-(void)showGallery{
    picker= [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [parentVC presentViewController:picker animated:YES completion:nil];
    else
    {
        popover =[[UIPopoverController alloc]initWithContentViewController:picker];
        [popover presentPopoverFromRect:cameraButton.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    }
}

- (IBAction)cancelCreatingAlert:(id)sender {
    [self removeFromSuperview];
    [delegate createNoteViewDidCancel];

}

- (IBAction)confirmCreatingAlert:(id)sender {
    [self removeFromSuperview];
    [delegate createNoteViewConfirmWithText:textView.text andImage:preview.image onPoint:_noteCenter];
}


-(void)handleTap: (UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark - ImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)pick didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [pick dismissViewControllerAnimated:YES completion:nil];
    
    if(popover != nil)
        [popover dismissPopoverAnimated:YES];
    

    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

    
    float wIwant = 100;
    float resulth = image.size.height * wIwant /image.size.width;
    
    UIImage * resized = [self imageWithImage:image convertToSize:CGSizeMake(wIwant, resulth)];
    

    
    [preview setBounds:CGRectMake(0, 0, resized.size.width/2, resized.size.height/2)];
    [preview setImage:resized];

}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)pick
{
    [pick dismissViewControllerAnimated:YES completion:nil];
}

@end
