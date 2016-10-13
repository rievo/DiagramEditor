//
//  GeoComponentAnnotationView.m
//  DiagramEditor
//
//  Created by Diego on 4/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "GeoComponentAnnotationView.h"

@implementation GeoComponentAnnotationView

@synthesize coordinate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation component:(Component *)compo{
    self = [super initWithAnnotation:annotation reuseIdentifier:nil];
    
    CGRect frame = [compo frame];
    frame.origin.x = 0;
    frame.origin.y = 0;
    [compo setFrame:frame];
    _comp = compo;
    [self setBounds:compo.bounds];
    
    [self addSubview:_comp];
    
    
    self.draggable = NO; //Can I drag this?
    
  
    return  self;
}



/*
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}*/
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    [self willChangeValueForKey:@"coordinate"];
    coordinate = newCoordinate;
    [self didChangeValueForKey:@"coordinate"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch{
    return YES;
}
@end
