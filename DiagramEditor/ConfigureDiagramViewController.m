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

#import "PaletteFile.h"


#define defaultwidth 50
#define defaultheight 50

#define scale 15

#define xmargin 20

#define getPalettes @"https://diagrameditorserver.herokuapp.com/palettes?json=true"

#define fileExtension @".graphicR"

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
    
    
    //Local files table
    localFilesArray = [[NSMutableArray alloc] init];
    [localFilesTable setDataSource:self];
    [localFilesTable setDelegate:self];
    
    
    //Server files table
    serverFilesArray = [[NSMutableArray alloc] init];
    [serverFilesTable setDataSource:self];
    [serverFilesTable setDelegate:self];
    

    
    
    //Load files from server
    NSThread * thread = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(loadFilesFromServer)
                                                  object:nil];
    [thread start];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                    target:self
                                                  selector:@selector(loadFilesFromServer)
                                                  userInfo:nil
                                                   repeats:YES];
    
    
    //Load local files
    NSThread * locThread = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(loadLocalFiles)
                                                  object:nil];
    [locThread start];
}

#pragma mark Recover files from server and local device

-(void)loadLocalFiles{
    NSFileManager  *manager = [NSFileManager defaultManager];
    // the preferred way to get the apps documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // grab all the files in the documents dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    // filter the array for only sqlite files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.graphicR'"];
    NSArray *graphicRFiles = [allFiles filteredArrayUsingPredicate:fltr];
    
    //Load from bundle
    NSArray * bpaths = [[NSBundle mainBundle] pathsForResourcesOfType:@".graphicR" inDirectory:nil];
    NSString * content = nil;
    for(NSString * path in bpaths){
        content = [NSString stringWithContentsOfFile:path
                                            encoding:NSUTF8StringEncoding
                                               error:nil];
        PaletteFile * pf = [[PaletteFile alloc] init];
        NSArray * components = [path componentsSeparatedByString:@"/"];
        
        pf.name = [components objectAtIndex:components.count -1];
        pf.content = content;
        
        [localFilesArray addObject:pf];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [localFilesTable reloadData];
    });
    
    
}

-(void)loadFilesFromServer{
    NSLog(@"Loading files from server");
    NSURL *url = [NSURL URLWithString:getPalettes];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:NULL];
             
             [serverFilesArray removeAllObjects];
             
             NSString * code = [dic objectForKey:@"code"];
             
             if([code isEqualToString:@"200"]){
                 NSArray * array = [dic objectForKey:@"array"];
                 
                 for(int i = 0; i< [array count]; i++){
                     NSDictionary * ins = [array objectAtIndex:i];
                     PaletteFile * pf = [[PaletteFile alloc] init];
                     pf.name = [ins objectForKey:@"name"];
                     pf.content = [ins objectForKey:@"content"];
                     
                     [serverFilesArray addObject:pf];
                 }
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [serverFilesTable reloadData];
                 });
                 
                 
                
                 
             }else{
                 NSLog(@"error");
             }
             
         }
     }];
}


#pragma mark Read file/palette and proccess

/*  Read file and proccess  */

-(void)extractPalettesForContentsOfFile: (NSString *)text{
    [palette resetPalette];
    
    [palettes removeAllObjects];

    configuration = [NSDictionary dictionaryWithXMLString:text];
    
    NSArray * allGraphicRepresentations = (NSArray *)[configuration objectForKey:@"allGraphicRepresentation"];
    
    
    //Por si el fichero tiene un solo "allGraphicrepresentation
    //En ese caso, la llamada a "dictionaryWithXMLString" devuelve un NSDictionary, que añadimos al array
    if([allGraphicRepresentations isKindOfClass:[NSDictionary class]]){
        allGraphicRepresentations = [[NSArray alloc] initWithObjects:[configuration objectForKey:@"allGraphicRepresentation"], nil];
    }
    
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
    
    [palettesTable reloadData];
    [palette preparePalette];
}

#pragma mark UIGesture recognizer methods

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
    
    CGPoint p = [gesture locationInView:self.view];
    
    NSLog(@"%@",[NSString stringWithFormat:@"(%.2f,%.2f)", p.x, p.y]);
    
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        infoLabel.text = owner.dialog;
        
        [infoView setHidden:NO];
        [infoView setCenter:CGPointMake(100, 100)];
        //[infoView setCenter:CGPointMake(p.x, p.y -50)];
        //[infoView setFrame:CGRectMake(p.x - initialInfoPosition.size.width/2, p.y -50 -initialInfoPosition.size.height/2, initialInfoPosition.size.width, initialInfoPosition.size.height)];
        [infoView setNeedsDisplay];
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        infoLabel.text = @"";
        [infoView setHidden:YES];
        [infoView setFrame:initialInfoPosition];
    }
}


#pragma mark Did receive memory warning
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
    
    if(tableView == palettesTable)
        return [palettes count];
    else if(tableView == serverFilesTable)
        return [serverFilesArray count];
    else if(tableView == localFilesTable)
        return [localFilesArray count];
    else
        return 0;
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
    
    if(tableView == palettesTable){
        
        Palette * temp = [palettes objectAtIndex:indexPath.row];
        cell.textLabel.text = temp.name;
        //cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = dele.blue3;
    }else if(tableView == serverFilesTable){
        PaletteFile * pf = [serverFilesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = pf.name;
        cell.textLabel.textColor = dele.blue3;
    }else if(tableView == localFilesTable){
        PaletteFile * pf = [localFilesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = pf.name;
        cell.textLabel.textColor = dele.blue3;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == palettesTable){
        [palette resetPalette];
        Palette * selected = [palettes objectAtIndex:indexPath.row];
        //[selected setFrame:palette.frame];
        palette.paletteItems = selected.paletteItems;
        
        [palette preparePalette];
        [palette setNeedsDisplay];
        
        [self addRecognizers];
    }else if(tableView == serverFilesTable){
        [palette resetPalette];
        PaletteFile * file = [serverFilesArray objectAtIndex:indexPath.row];
        
        [self extractPalettesForContentsOfFile:file.content];
    }else if (tableView == localFilesTable){
        [palette resetPalette];
        PaletteFile * pf = [localFilesArray objectAtIndex:indexPath.row];
        [self extractPalettesForContentsOfFile:pf.content];
    }
    
}


@end
