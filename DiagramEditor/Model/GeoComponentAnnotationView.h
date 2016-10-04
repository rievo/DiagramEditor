//
//  GeoComponentAnnotationView.h
//  DiagramEditor
//
//  Created by Diego on 4/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Component.h"

@interface GeoComponentAnnotationView : MKAnnotationView


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                             component:(Component *)comp;

@property Component * comp;


@end
