//
//  EditorViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "EditorViewController.h"
#import "ComponentDetailsView.h"
#import "ConnectionDetailsViewController.h"
#import "Connection.h"
#import "Palette.h"
#import "PaletteItem.h"
#import "XMLWriter.h"


@import Foundation;

@interface EditorViewController ()

@end

@implementation EditorViewController

@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    canvasW = 1500;
    
    dele = [[UIApplication sharedApplication]delegate];
    
    canvas = [[Canvas alloc] initWithFrame:CGRectMake(0, 0, canvasW, canvasW)];
    canvas.backgroundColor = [dele blue4];
    [canvas prepareCanvas];
    dele.can = canvas;
    dele.originalCanvasRect = canvas.frame;
    
    //Add canvas to scrollView contents
    [scrollView addSubview:canvas];
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(canvas.frame.size.width, canvas.frame.size.height)];
    [scrollView setBounces:NO];
    scrollView.contentSize = CGSizeMake(canvas.frame.size.width, canvas.frame.size.height);
    scrollView.minimumZoomScale = 0.7;
    scrollView.maximumZoomScale = 4.0;
    scrollView.delegate = self;
    
    //[self setZoomForIntValue:0]; //No zoom
    float nullZoom = [self getZoomScaleForIntValue:0];
    [scrollView setZoomScale:nullZoom animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showComponentDetails:)
                                                 name:@"showCompNot"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showConnectionDetails:)
                                                 name:@"showConnNot"
                                               object:nil];
    
    
    containerView = [[UIView alloc]initWithFrame:self.view.frame];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [containerView addSubview:blurEffectView];
    [containerView sendSubviewToBack:blurEffectView];
    
    backSure = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:backSure];
    backSure.backgroundColor = [UIColor blackColor];
    backSure.alpha = 0.6;
    [backSure setHidden:YES];
    [sureCloseView setHidden:YES];
    [self.view bringSubviewToFront:sureCloseView];
    
    
    compDetView = [[[NSBundle mainBundle] loadNibNamed:@"ComponentDetailsView"
                                                 owner:self
                                               options:nil] objectAtIndex:0];
    
    [compDetView setDelegate:self];
    
    [containerView addSubview:compDetView];
    [compDetView setCenter:containerView.center];
    [containerView bringSubviewToFront:compDetView];
    
    [containerView setHidden:YES];
    
    
    //Add a UITapGR to containerview for closing
    /*UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDetailsView)];
    [containerView addGestureRecognizer:tgr];*/
    
    [self.view addSubview:containerView];
    
    
    
    UITapGestureRecognizer * zoomTapGr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(doZoom:)];
    
    [zoomTapGr setNumberOfTapsRequired:2];
    [scrollView setUserInteractionEnabled:YES];
    [scrollView setCanCancelContentTouches:YES];
    [scrollView addGestureRecognizer:zoomTapGr];
    zoomTapGr.delegate = self;
    zoomLevel = 0; //No zoom
    
}

#pragma mark Show/Hide detailsView
-(void)showDetailsView{
    [compDetView prepare];
    [containerView setHidden:NO];
}
-(void)hideDetailsView{
    [containerView setHidden:YES];
}




-(void)viewWillAppear:(BOOL)animated{
    palette.paletteItems = [[NSMutableArray alloc] initWithArray:dele.paletteItems];
    [palette preparePalette];
    
    //Añadimos a los items de la paleta el gestor de gestos para poder arrastrarlos
    for(int i  =0; i< palette.paletteItems.count; i++){
        PaletteItem * item = [palette.paletteItems objectAtIndex:i];
        
        UIPanGestureRecognizer * panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [item addGestureRecognizer:panGr];
    }
}

-(void)showComponentDetails:(NSNotification *)not{
    NSLog(@"Showing component's details");
    Component * temp = not.object;
    
    //[self performSegueWithIdentifier:@"showComponentDetails" sender:temp];
    
    //Load component details view
    compDetView.comp = temp;
    [compDetView prepare];
    [self showDetailsView];
    
}

#pragma mark UIPanGestureRecognizer


-(void)handlePan:(UILongPressGestureRecognizer *)recog{
    PaletteItem * sender = (PaletteItem *)recog.view;
    
    CGPoint p = [recog locationInView:self.view];
    
    if(recog.state == UIGestureRecognizerStateBegan){
        //Creamos el icono temporal
        tempIcon = [[PaletteItem alloc] init];
        tempIcon.type = sender.type;
        tempIcon.dialog = sender.dialog;
        tempIcon.width = sender.width;
        tempIcon.height = sender.height;
        tempIcon.shapeType = sender.shapeType;
        [tempIcon setFrame:sender.frame];
        [tempIcon setAlpha:0.2];
        tempIcon.center = p;
        tempIcon.backgroundColor = [UIColor blackColor];
        [self.view addSubview:tempIcon];
    }else if(recog.state == UIGestureRecognizerStateChanged){
        //Movemos el icono temporal
        tempIcon.center = p;
    }else if(recog.state == UIGestureRecognizerStateEnded){
        //Retiramos el icono temporal
        [tempIcon removeFromSuperview];
        tempIcon = nil;
        
        //Check if point is inside canvas.
        
        CGPoint pointInSV = [self.view convertPoint:p toView:canvas];
        
        if(CGRectContainsPoint(scrollView.frame, p)){
            //Añadimos un Component al lienzo
            if([sender.type isEqualToString:@"graphicR:Node"]){
                //It is a node
                NSLog(@"Creating a node");
                
                Component * comp = [[Component alloc] initWithFrame:CGRectMake(0, 0, sender.width.floatValue, sender.height.floatValue)];
                comp.center = pointInSV;
                comp.name = sender.dialog;
                comp.type = sender.type;
                comp.shapeType = sender.shapeType;
                comp.fillColor = sender.fillColor;
                comp.attributes = sender.attributes;
                
                if(sender.isImage){
                    comp.isImage = YES;
                    comp.image = sender.image;
                }else{
                    comp.isImage = NO;
                }
                
                [dele.components addObject:comp];
                [comp updateNameLabel];
                [canvas addSubview:comp];
                
            }else{
                //It is an edge
                NSLog(@"Creating a relation");
            }
        }else{
            NSLog(@"There is no canvas on this point.");
        }
        
        
    }
}


#pragma mark Are you sure? view

- (IBAction)sureCreateNew:(id)sender {
    [self resetAll];
    [backSure setHidden:YES];
    [sureCloseView setHidden:YES];
}

- (IBAction)notSureCreateNew:(id)sender {
    [backSure setHidden:YES];
    [sureCloseView setHidden:YES];
}



#pragma mark Toolbar


-(void)showConnectionDetails:(NSNotification *)not{
    Connection * temp = not.object;
    [self performSegueWithIdentifier:@"showConnectionDetails" sender:temp];
}

- (IBAction)showComponentList:(id)sender {
    [self performSegueWithIdentifier:@"showComponentsView" sender:self];
}

- (IBAction)showActionsList:(id)sender {
    
}

- (IBAction)createNewDiagram:(id)sender {
    [backSure setHidden:NO];
    [sureCloseView setHidden:NO];
    
}

-(void)resetAll{
    dele.components = [[NSMutableArray alloc] init];
    dele.connections = [[NSMutableArray alloc] init];
    [canvas prepareCanvas];
}

- (IBAction)saveCurrentDiagram:(id)sender {
    
    
    UIAlertController * ac  = [UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * sendemail = [UIAlertAction actionWithTitle:@"Send email"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           
                                                           NSString * txt = [self generateXML];
                                                           
                                                           controller = [[MFMailComposeViewController alloc] init];
                                                           controller.mailComposeDelegate = self;
                                                           [controller setSubject:@"Diagram test"];
                                                           //[controller setMessageBody:@"Hello there." isHTML:NO];
                                                           [controller setMessageBody:txt isHTML:NO];
                                                           [self presentViewController:controller animated:YES completion:nil];
                                                       }];
    
    UIAlertAction * saveondevice = [UIAlertAction actionWithTitle:@"Local save"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                          }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    
    [ac addAction:sendemail];
    [ac addAction:saveondevice];
    [ac addAction:cancel];
    
    
    UIPopoverPresentationController * popover = ac.popoverPresentationController;
    if(popover){
        popover.sourceView = saveButton;
        //popover.sourceRect = sender.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}

-(NSString *)generateXML{
    //Generate XML
    XMLWriter * writer = [[XMLWriter alloc] init];
    [writer writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    [writer writeStartElement:@"Diagram"];
    
    [writer writeStartElement:@"Nodes"];
    Component * temp = nil;
    for(int i = 0; i< dele.components.count; i++){
        temp = [dele.components objectAtIndex:i];
        [writer writeStartElement:@"node"];
        [writer writeAttribute:@"name" value:temp.name];
        [writer writeAttribute:@"shape_type" value:temp.shapeType];
        //[writer writeAttribute:@"fill_color" value:temp.fillCo]
        [writer writeAttribute:@"x" value: [[NSNumber numberWithFloat:temp.center.x]description]];
        [writer writeAttribute:@"y" value: [[NSNumber numberWithFloat:temp.center.y]description]];
        [writer writeAttribute:@"id" value: [[NSNumber numberWithInt:(int)temp ]description]];
        [writer writeEndElement];
    }
    [writer writeEndElement];//Close nodes
    
    
    [writer writeStartElement:@"Edges"];
    Connection * c = nil;
    for(int i = 0; i<dele.connections.count; i++){
        c = [dele.connections objectAtIndex:i];
        [writer writeStartElement:@"edge"];
        [writer writeAttribute:@"name" value:c.name];
        [writer writeAttribute:@"source" value:[[NSNumber numberWithInt:(int)c.source]description]];
        [writer writeAttribute:@"target" value:[[NSNumber numberWithInt:(int)c.target]description]];
        [writer writeEndElement];
    }
    [writer writeEndElement];
    
    [writer writeEndElement];//Close diagram
    [writer writeEndDocument];
    
    NSString * xml = [writer toString];
    return xml;
}


- (IBAction)willChangePalette:(id)sender {
    
}




- (IBAction)exportCanvasToImage:(id)sender {
    UIGraphicsBeginImageContext(canvas.frame.size);
    [canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* image = nil;
    
    UIGraphicsBeginImageContext(scrollView.contentSize);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    NSData * data = UIImagePNGRepresentation(image);
    
    controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Digram image text"];
    [controller addAttachmentData:data mimeType:@"image/png" fileName:@"photo"];
    [self presentViewController:controller animated:YES completion:nil];

}



#pragma mark Storyboard
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"showConnectionDetails"]){
        ConnectionDetailsViewController * vc = [segue destinationViewController];
        vc.conn = sender;
    }
}




#pragma mark MFMailComposeViewController delegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark UIScrollViewDelegate

-(float)getZoomScaleForIntValue:(int) val{
    float minz = scrollView.minimumZoomScale;
    float maxz = scrollView.maximumZoomScale;
    
    //float current = val * minz / maxz;
    float current = val * maxz / 2;
    if(current <minz){
        current = minz;
    }
    return current;
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return canvas;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)sv withView:(UIView *)view atScale:(CGFloat)scale{
    [sv setContentSize:CGSizeMake(dele.originalCanvasRect.size.width * scale, dele.originalCanvasRect.size.height * scale)];
}


/*
- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated
{
    //Normalize current content size back to content scale of 1.0f
    CGSize contentSize;
    contentSize.width = (scrollView.contentSize.width / scrollView.zoomScale);
    contentSize.height = (scrollView.contentSize.height / scrollView.zoomScale);
    
    //translate the zoom point to relative to the content rect
    zoomPoint.x = (zoomPoint.x / scrollView.bounds.size.width) * contentSize.width;
    zoomPoint.y = (zoomPoint.y / scrollView.bounds.size.height) * contentSize.height;
    
    //derive the size of the region to zoom to
    CGSize zoomSize;
    zoomSize.width = scrollView.bounds.size.width / scale;
    zoomSize.height = scrollView.bounds.size.height / scale;
    
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    CGRect zoomRect;
    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
    zoomRect.size.width = zoomSize.width;
    zoomRect.size.height = zoomSize.height;
    
    //apply the resize
    [scrollView zoomToRect: zoomRect animated: animated];
}*/
- (void)zoomToPoint:(CGPoint)zoomPoint withScale:(CGFloat)scale animated:(BOOL)animated
{

    
    //`zoomToRect` works on the assumption that the input frame is in relation
    //to the content view when zoomScale is 1.0
    
    //Work out in the current zoomScale, where on the contentView we are zooming
    CGPoint translatedZoomPoint = CGPointZero;
    translatedZoomPoint.x = zoomPoint.x + scrollView.contentOffset.x;
    translatedZoomPoint.y = zoomPoint.y + scrollView.contentOffset.y;
    
    //Figure out what zoom scale we need to get back to default 1.0f
    CGFloat zoomFactor = 1.0f / scrollView.zoomScale;
    
    //By multiplying by the zoom factor, we get where we're zooming to, at scale 1.0f;
    translatedZoomPoint.x *= zoomFactor;
    translatedZoomPoint.y *= zoomFactor;
    
    //work out the size of the rect to zoom to, and place it with the zoom point in the middle
    CGRect destinationRect = CGRectZero;
    destinationRect.size.width = CGRectGetWidth(scrollView.frame) / scale;
    destinationRect.size.height = CGRectGetHeight(scrollView.frame) / scale;
    destinationRect.origin.x = translatedZoomPoint.x - (CGRectGetWidth(destinationRect) * 0.5f);
    destinationRect.origin.y = translatedZoomPoint.y - (CGRectGetHeight(destinationRect) * 0.5f);
    
  //  if (animated) {
        [UIView animateWithDuration:0.55f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.6f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [scrollView zoomToRect:destinationRect animated:NO];
        } completion:^(BOOL completed) {
            if ([scrollView.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
                [scrollView.delegate scrollViewDidEndZooming:scrollView withView:[scrollView.delegate viewForZoomingInScrollView:scrollView] atScale:scale];
            }
        }];
   // }
   /* else {
        [self zoomToRect:destinationRect animated:NO];
    }*/
}


-(void)doZoom: (UITapGestureRecognizer * )tapRecognizer{
    if(zoomLevel == 0){
        zoomLevel = 1;
    }else if(zoomLevel == 1){
        zoomLevel = 2;
    }else if(zoomLevel == 2){ //Full zoom to no zoom
        zoomLevel = 0;
    }
    
    CGPoint p = [tapRecognizer locationInView: self.view];
    CGPoint pointInSV = [self.view convertPoint:p toView:canvas];
    
    float newScale = [self getZoomScaleForIntValue:zoomLevel];
    
    
    [self zoomToPoint:pointInSV withScale:newScale animated:YES];
}

#pragma mark ComponentDetailsView delegate

-(void)closeDetailsViewAndUpdateThings{
    [containerView setHidden:YES];
}



#pragma mark UIGestureRecognizer
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return  YES;
}
@end
