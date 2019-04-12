//
//  AlertAnnotationView.h
//  DiagramEditor
//
//  Created by Diego on 10/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Alert.h"
#import "AlertAnnotation.h"

@interface AlertAnnotationView : MKAnnotationView{
    CLLocationCoordinate2D coordinate;
}


-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation alert:(Alert *)a;

@property Alert * alert;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property AlertAnnotation * point;
@end
