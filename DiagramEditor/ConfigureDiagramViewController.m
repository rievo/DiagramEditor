//
//  ConfigureDiagramViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "ConfigureDiagramViewController.h"
#import "XMLDictionary.h"
#import "PaletteItem.h"
#import "AppDelegate.h"
#import "Palette.h"


#define defaultwidth 50
#define defaultheight 50

#define scale 10

#define xmargin 10

@interface ConfigureDiagramViewController ()

@end

@implementation ConfigureDiagramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    initialInfoPosition = infoView.frame;
    [infoView setHidden:YES];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = infoView.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [infoView addSubview:blurEffectView];
    
    [infoView sendSubviewToBack:blurEffectView];
    
    
    dele = [UIApplication sharedApplication].delegate;
    // Do any additional setup after loading the view.
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"design" ofType:@"graphicR"];
    configuration = [NSDictionary dictionaryWithXMLFile:filePath];
    
    NSDictionary * allGraphicRepresentation = [configuration objectForKey:@"allGraphicRepresentation"];
    
    NSDictionary * layers = [allGraphicRepresentation objectForKey:@"layers"];
    NSArray * elements = [layers objectForKey:@"elements"];
    
    
    for(int i  = 0; i< elements.count; i++){
        
        PaletteItem * item = [[PaletteItem alloc] init];
        
        NSDictionary * dic = [elements objectAtIndex:i];
        NSString * type = [dic objectForKey:@"_xsi:type"];
        
        item.type = type;
        
        NSDictionary * diagPalette = [dic objectForKey:@"diag_palette"];
        NSString * paleteName = [diagPalette objectForKey:@"_palette_name"];
        NSLog(@"\n\ntype: %@     	\n name: %@", type, paleteName);
        item.dialog = paleteName;
        
        NSDictionary * nodeShapeDic = [dic objectForKey:@"node_shape"];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        if(nodeShapeDic != nil){
            NSString * wstr = [nodeShapeDic objectForKey:@"_horizontalDiameter"];
            NSString * hstr = [nodeShapeDic objectForKey:@"_verticalDiameter"];
            NSString * shapeType = [nodeShapeDic objectForKey:@"_xsi:type"];
            
            NSNumber * w = [f numberFromString:wstr];
            NSNumber * h = [f numberFromString:hstr];
            
            float scaledW = w.floatValue * scale;
            float scaledH = h.floatValue * scale;
            
            
            item.width = [NSNumber numberWithFloat:scaledW];
            item.height = [NSNumber numberWithFloat:scaledH];
            item.shapeType = shapeType;
            
            
        }
        
        
        //Set frame
        if(item.width != nil && item.height != nil){
            item.frame = CGRectMake(0, 0, item.width.floatValue , item.height.floatValue);
        }else{
            //Default values
            item.frame = CGRectMake(0, 0, defaultwidth, defaultheight);
        }
        
        //Set frame just for here. On the canvas they will have their dimensions
        //item.frame = CGRectMake(0, 0, scrollView.bounds.size.height, scrollView.bounds.size.height);
        
        
        [dele.paletteItems addObject:item];
        
        /*
        //GestureRecognizer
        UILongPressGestureRecognizer * gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        gr.delegate = self;
        gr.minimumPressDuration = 0.0;
        [item addGestureRecognizer:gr];*/
    }
    
    
    [palette preparePalette];
    
    
    //Add longPressGestureRecognizer in order to show palette dialog
    for(int i = 0; i<dele.paletteItems.count; i++){
        PaletteItem * item = [dele.paletteItems objectAtIndex:i];
        UILongPressGestureRecognizer * gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        gr.delegate = self;
        gr.minimumPressDuration = 0.0;
        [item addGestureRecognizer:gr];
    }
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture{
    PaletteItem * owner = (PaletteItem *)gesture.view;
    
    CGPoint p = [gesture locationInView:self.view];
    
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        infoLabel.text = owner.dialog;
        
        ///p.y = p.y - 2 * infoView.bounds.size.height;
        
        //infoView.center = p;
        CGRect newRect = CGRectMake(p.x , p.y - 50, infoView.frame.size.width, infoView.frame.size.height);
        NSLog(@"x: %f  y:%f", newRect.origin.x, newRect.origin.y);
        [infoView setFrame:newRect];

        [infoView setHidden:NO];
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        infoLabel.text = @"";
        [infoView setHidden:YES];
        [infoView setFrame:initialInfoPosition];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showEditor:(id)sender {
    [self performSegueWithIdentifier:@"showEditor" sender:self];
}

@end
