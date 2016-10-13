//
//  GeoComponentAnnotationView.h
//  DiagramEditor
//
//  Created by Diego on 4/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Component.h"
#import "GeoComponentPointAnnotation.h"

@interface GeoComponentAnnotationView : MKAnnotationView <MKAnnotation>{
    CLLocationCoordinate2D coordinate;
}


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                             component:(Component *)comp;

@property Component * comp;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property GeoComponentPointAnnotation * point;

@end
