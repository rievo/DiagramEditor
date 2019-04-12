//
//  NoteView.m
//  DiagramEditor
//
//  Created by Diego on 23/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NoteView.h"
#import "AppDelegate.h"
#import "Alert.h"


@implementation NoteView

@synthesize background, preview, associatedNote;

-(void)awakeFromNib{
    [super awakeFromNib];
    dele =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];
    
    [self bringSubviewToFront:container];
    
    color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardOnScreen:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    
    
    
    [center addObserver:self
               selector:@selector(keyboardOutOfScreen:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}


-(void)prepare{
    //Form ScrollView
    
    float margin = 10;
    
    [scrollView setPagingEnabled:YES];
    
    UIView * viewToIncrust ;
    
    float start = 0;
    
    int mult = 1; //Only text
    
    if(associatedNote.image != nil)
        mult ++;
    
    if(associatedNote.location != nil)
        mult ++;
    
    CGRect fr = CGRectMake(0, 0, scrollView.bounds.size.width * mult, scrollView.bounds.size.height);
    viewToIncrust = [[UIView alloc] initWithFrame:fr];
    
    
    //Add text
    tv = [[UITextView alloc] initWithFrame:CGRectMake(start +margin,
                                                      margin,
                                                      scrollView.bounds.size.width - 2*margin,
                                                      scrollView.bounds.size.height- 2*margin)];
    tv.backgroundColor = dele.blue1;
    tv.textColor = dele.blue4;
    tv.text = associatedNote.text;
    [viewToIncrust addSubview:tv];
    
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    
    
    if(associatedNote.attach != nil){  //Add Image
        start = scrollView.contentSize.width;
        
        UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(scrollView.contentSize.width + margin,
                                                                         margin,
                                                                         scrollView.bounds.size.width -2*margin,
                                                                         scrollView.bounds.size.height -2*margin)];
        
        [iv setImage:associatedNote.image];
        [iv setContentMode:UIViewContentModeScaleAspectFit];
        
        [viewToIncrust addSubview:iv];
        
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + iv.frame.size.width + 2*margin, scrollView.frame.size.height);
        
        [iv setBackgroundColor:dele.blue0];
    }
    
    
    //TODO: Show map here
    
    
    if(associatedNote.location != nil){
        start = scrollView.contentSize.width + 2*margin;
        MKMapView * map;
        map = [[MKMapView alloc] initWithFrame:CGRectMake(start, margin, scrollView.bounds.size.width -3*margin,
                                                          scrollView.bounds.size.height -2 *margin)];
        [viewToIncrust addSubview:map];
        
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + scrollView.bounds.size.width, scrollView.frame.size.height);
        
        [self updateMap:map withLocation:associatedNote.location];
    }
    
    
    [scrollView addSubview:viewToIncrust];
    
    
    
    
    viewToIncrust.backgroundColor = dele.blue3;
    
    scrollView.delegate = self;
    tv.delegate = self;
    //self.pageControl.currentPage = 0
}

-(void)updateMap:(MKMapView *) map
    withLocation:(CLLocation *)location{
    [map setCenterCoordinate:location.coordinate animated:YES];
    
    MKPointAnnotation * pin = [[MKPointAnnotation alloc]init];
    pin.coordinate = location.coordinate;
    [map addAnnotation:pin];
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.002;
    span.longitudeDelta = 0.002;
    
    
    // create region, consisting of span and location
    MKCoordinateRegion region;
    region.span = span;
    region.center = location.coordinate;
    
    // move the map to our location
    [map setRegion:region animated:YES];
}


- (IBAction)deleteThisNote:(id)sender {
    [dele.notesArray removeObject:associatedNote];
    [associatedNote removeFromSuperview];
    
    [self removeFromSuperview];
    
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:nil];
    
    //Send delete to peers
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    
    [dic setObject:associatedNote forKey:@"note"];
    [dic setObject:kDeleteNote forKey:@"msg"];
    [dic setObject:dele.myPeerInfo.peerID forKey:@"who"];
    
    NSError * error = nil;
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
    
}

- (IBAction)closeThisView:(id)sender {
    associatedNote.text = tv.text;
    
    [self removeFromSuperview];
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

#pragma mark Keyboard issues
-(void)keyboardOutOfScreen:(NSNotification *)not{
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [container setFrame:oldFrame];
                         [self setNeedsDisplay];
                     }
                     completion:^(BOOL finished) {
                         [self setNeedsDisplay];
                     }];
    
}


-(void)keyboardOnScreen:(NSNotification *)not{
    
    oldFrame = container.frame;
    
    NSDictionary * dicNot = not.userInfo;
    
    NSValue *val = dicNot[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame = [val CGRectValue];
    CGRect keyboardFrame = [self convertRect:rawFrame fromView:nil];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [container setFrame:CGRectMake(container.frame.origin.x,
                                                        keyboardFrame.origin.y - container.frame.size.height,
                                                        container.frame.size.width,
                                                        container.frame.size.height)];
                         [self setNeedsDisplay];
                     }
                     completion:^(BOOL finished) {
                         [self setNeedsDisplay];
                     }];
}

@end
