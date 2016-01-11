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
#import "ColorPalette.h"


#define defaultwidth 50
#define defaultheight 50

#define scale 15

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
    
    
    palettes = [[NSMutableArray alloc] init];
    [palettesTable setDataSource:self];
    [palettesTable setDelegate:self];
    
    
    
    
    //Read file and proccess
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"design" ofType:@"graphicR"];
    configuration = [NSDictionary dictionaryWithXMLFile:filePath];
    
    NSArray * allGraphicRepresentations = [configuration objectForKey:@"allGraphicRepresentation"];
    
    for(int gr = 0; gr < allGraphicRepresentations.count; gr++){
        
        
        //Create a temp palette
        Palette * tempPalete = [[Palette alloc] init];
        [tempPalete preparePalette];
        
        NSDictionary * allGraphicRepresentation = [allGraphicRepresentations objectAtIndex:gr];
        
        NSString * paletteName = [allGraphicRepresentation objectForKey:@"_extension"];
        tempPalete.name = paletteName;
        
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
                NSString * color = [nodeShapeDic objectForKey:@"_color"];
                
                NSString * sizeStr = [nodeShapeDic objectForKey:@"_size"];
                
                NSNumber * w = [f numberFromString:wstr];
                NSNumber * h = [f numberFromString:hstr];
                
                
                if(sizeStr != nil){
                    //There is size value, but with and height
                    NSNumber * s = [f numberFromString:sizeStr];
                    float scaledS = s.floatValue * scale;
                    item.width = [NSNumber numberWithFloat:scaledS];
                    item.height = [NSNumber numberWithFloat:scaledS];
                }else{
                    float scaledW = w.floatValue * scale;
                    float scaledH = h.floatValue * scale;
                    item.width = [NSNumber numberWithFloat:scaledW];
                    item.height = [NSNumber numberWithFloat:scaledH];
                    
                }
                
                
                
                item.shapeType = shapeType;
                
                if(color == nil){
                    item.fillColor = [ColorPalette white];
                }else{
                    item.fillColor = [ColorPalette colorForString:color];
                }
                
                if(w.floatValue <= 0.0){
                    item.width = [NSNumber numberWithFloat:defaultwidth];
                }
                
                if(h.floatValue <= 0.0){
                    item.height = [NSNumber numberWithFloat:defaultheight];
                }
            }
            
            
            //Set frame
            if(item.width != nil && item.height != nil){
                item.frame = CGRectMake(0, 0, item.width.floatValue , item.height.floatValue);
            }else{
                //Default values
                item.frame = CGRectMake(0, 0, defaultwidth, defaultheight);
            }
            
            
            
            //[dele.paletteItems addObject:item];
            [tempPalete.paletteItems addObject:item];
            

        }
        
        [palettes addObject:tempPalete];
    }
    
    
    [palette preparePalette];
    
    

}

-(void)addRecognizers{
    //Add longPressGestureRecognizer in order to show palette dialog
    for(int i = 0; i<palette.paletteItems.count; i++){
        PaletteItem * item = [palette.paletteItems objectAtIndex:i];
        UILongPressGestureRecognizer * gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        gr.delegate = self;
        gr.minimumPressDuration = 0.0;
        [item addGestureRecognizer:gr];
    }
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture{
    PaletteItem * owner = (PaletteItem *)gesture.view;
    
    CGPoint p = [gesture locationInView:gesture.view];
    
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        infoLabel.text = owner.dialog;
        
        [infoView setHidden:NO];
        [infoView setCenter:CGPointMake(p.x, p.y -50)];
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


#pragma mark Show editor
- (IBAction)showEditor:(id)sender {
    
    if(palette.paletteItems.count != 0){
        dele.paletteItems = [[NSMutableArray alloc] initWithArray:palette.paletteItems];
        [self performSegueWithIdentifier:@"showEditor" sender:self];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Any palette must be selected in order to perform this action."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
}



#pragma mark UItableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [palettes count];    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier] ;
    }

    Palette * temp = [palettes objectAtIndex:indexPath.row];
    cell.textLabel.text = temp.name;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = dele.blue4;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    Palette * selected = [palettes objectAtIndex:indexPath.row];
    //[selected setFrame:palette.frame];
    palette.paletteItems = selected.paletteItems;
    [palette preparePalette];
    [palette setNeedsDisplay];
    
    [self addRecognizers];
    
}

@end
