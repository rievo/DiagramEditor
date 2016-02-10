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
#import "PasteView.h"

#import "ClassAttribute.h"
#import "Reference.h"

#import "ExploreFilesView.h"
#import "EditorViewController.h"

#import "Connection.h"

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
    
    //initialInfoPosition = infoView.frame;
    [infoView setHidden:YES];
    
    
    loadingADiagram = NO;
    content = nil;
    /* UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
     UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
     blurEffectView.frame = infoView.bounds;
     blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     
     [infoView addSubview:blurEffectView];
     
     [infoView sendSubviewToBack:blurEffectView]; */
    
    tempPaletteFile = nil;
    
    
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

-(void)viewWillAppear:(BOOL)animated{
    loadingADiagram = NO;
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
    //NSArray *graphicRFiles = [allFiles filteredArrayUsingPredicate:fltr];
    
    //Load from bundle
    NSArray * bpaths = [[NSBundle mainBundle] pathsForResourcesOfType:@".graphicR" inDirectory:nil];
    NSString * contentstr = nil;
    for(NSString * path in bpaths){
        contentstr = [NSString stringWithContentsOfFile:path
                                            encoding:NSUTF8StringEncoding
                                               error:nil];
        PaletteFile * pf = [[PaletteFile alloc] init];
        NSArray * components = [path componentsSeparatedByString:@"/"];
        
        pf.name = [components objectAtIndex:components.count -1];
        pf.content = contentstr;
        
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

-(Palette *)extractSubPalette: (NSString *)name{
    for(int i = 0; i< palettes.count; i++){
        Palette * pal = [palettes objectAtIndex:i];
        
        if ([pal.name isEqualToString:dele.subPalette]) {
            return pal;
        }
    }
    
    return nil;
}

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
            
            NSDictionary * className = [dic objectForKey:@"anEClass"];
            NSString * classStr = [className objectForKey:@"_href"];
            NSArray * arraystr = [classStr componentsSeparatedByString:@"/"];
            NSString * parsedClass = [arraystr objectAtIndex: arraystr.count -1];
            item.className = parsedClass;
            
            NSDictionary * diagPalette = [dic objectForKey:@"diag_palette"];
            NSString * paleteName = [diagPalette objectForKey:@"_palette_name"];
            NSLog(@"\n\ntype: %@     	\n name: %@", type, paleteName);
            
            NSDictionary * containerDic = [dic objectForKey:@"containerReference"];
            NSString * containerReference = [containerDic objectForKey:@"_href"];
            item.containerReference = containerReference;
            
            
            item.dialog = parsedClass;
            
            NSDictionary * nodeShapeDic = [dic objectForKey:@"node_shape"];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            
            if(nodeShapeDic != nil){
                NSString * wstr = [nodeShapeDic objectForKey:@"_horizontalDiameter"];
                NSString * hstr = [nodeShapeDic objectForKey:@"_verticalDiameter"];
                NSString * shapeType = [nodeShapeDic objectForKey:@"_xsi:type"];
                NSDictionary * colorDic = [nodeShapeDic objectForKey:@"color"];
                NSString * color = [colorDic objectForKey:@"_name"];
                
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
                    item.colorString = @"white";
                }else{
                    item.fillColor = [ColorPalette colorForString:color];
                    item.colorString = color;
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
            
            
            if([item.type isEqualToString:@"graphicR:Edge"]){
                //Extract directions
                
                NSDictionary * edgeStyleDic = [dic objectForKey:@"edge_style"];
                NSString * edgeStyle = [edgeStyleDic objectForKey:@"_color"];
                NSDictionary * directions = [dic objectForKey:@"directions"];
                
                NSDictionary * sourceDic = [directions objectForKey:@"sourceLink"];
                NSDictionary * targetDic = [directions objectForKey:@"targetLink"];
                
                NSString * sourceDecoName = [sourceDic objectForKey:@"_decoratorName"];
                NSString * targetDecoName = [targetDic objectForKey:@"_decoratorName"];
                
                NSDictionary * sourRefeDic = [sourceDic objectForKey:@"anEReference"];
                NSDictionary * targRefeDic = [targetDic objectForKey:@"anEReference"];
                
                NSString * sourceReference = [sourRefeDic objectForKey:@"_href"];
                NSString * targetReference = [targRefeDic objectForKey:@"_href"];
                //Split by / ang
                NSArray * sourceRefArray = [sourceReference componentsSeparatedByString:@"/"];
                NSString * sClass = [sourceRefArray objectAtIndex:sourceRefArray.count-2];
                NSString *sPart = [sourceRefArray objectAtIndex:sourceRefArray.count-1];
                
                NSArray * targetRefArray = [targetReference componentsSeparatedByString:@"/"];
                NSString * tClass = [targetRefArray objectAtIndex:targetRefArray.count-2];
                NSString * tPart = [targetRefArray objectAtIndex:targetRefArray.count-1];
                
                
                item.edgeStyle = edgeStyle;
                item.sourceDecoratorName = sourceDecoName;
                item.targetDecoratorName = targetDecoName;
                item.sourceName = sClass;
                item.targetName = tClass;
                item.sourcePart = sPart;
                item.targetPart = tPart;
                
                
                int r = 2;
            }
            
            
            
            //[dele.paletteItems addObject:item];
            [tempPalete.paletteItems addObject:item];
            
            
        }
        
        [palettes addObject:tempPalete];
    }
    

    [palettesTable reloadData];
    [palette preparePalette];
    
    
    if(palettes.count == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"This palette doesn't have items"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
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
    
    //NSLog(@"%@",[NSString stringWithFormat:@"(%.2f,%.2f)", p.x, p.y]);
    
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        [infoView setCenter:CGPointMake(p.x, p.y -70)];
        infoLabel.text = owner.dialog;
        
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        infoLabel.text = @"";
        [infoView setHidden:YES];
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        [infoView setHidden:NO];
        [infoView setCenter:CGPointMake(p.x, p.y-70)];
        
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
        [refreshTimer invalidate];
        
        [self completePaletteForJSONAttributes];
        
        dele.currentPaletteFileName = tempPaletteFile;
        
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
    }else if(tableView == serverFilesTable){
        PaletteFile * pf = [serverFilesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = pf.name;

    }else if(tableView == localFilesTable){
        PaletteFile * pf = [localFilesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = pf.name;
        
    }
    cell.textLabel.textColor = dele.blue4;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    [cell.textLabel setMinimumScaleFactor:7.0/[UIFont labelFontSize]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == palettesTable){
        [palette resetPalette];
        Palette * selected = [palettes objectAtIndex:indexPath.row];
        //[selected setFrame:palette.frame];
        palette.paletteItems = selected.paletteItems;
        
        dele.subPalette = selected.name;
        
        [palette preparePalette];
        [palette setNeedsDisplay];
        
        [self addRecognizers];
        
        
        
        
    }else if(tableView == serverFilesTable){
        [palette resetPalette];
        PaletteFile * file = [serverFilesArray objectAtIndex:indexPath.row];
        tempPaletteFile = file.name;
        
        [self extractPalettesForContentsOfFile:file.content];
    }else if (tableView == localFilesTable){
        [palette resetPalette];
        PaletteFile * pf = [localFilesArray objectAtIndex:indexPath.row];
        tempPaletteFile = pf.name;
        [self extractPalettesForContentsOfFile:pf.content];
    }
    
}


-(void)showOptionsPopup{
    
    UIAlertController * ac  = [UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    UIAlertAction * loadFromServer = [UIAlertAction actionWithTitle:@"Load from server"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                
                                                            }];
    
    UIAlertAction * pasteFromText = [UIAlertAction actionWithTitle:@"Paste from text"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               
                                                               
                                                               rootView = [[[NSBundle mainBundle] loadNibNamed:@"PasteView"
                                                                                                                 owner:self
                                                                                                               options:nil] objectAtIndex:0];
                                                               
                                                               [rootView setFrame:self.view.frame];
                                                               
                                                               [rootView.background setFrame:self.view.frame];
                                                               
                                                               [rootView setDelegate:self];
                                                               [rootView.background setCenter:self.view.center];
                                                               [self.view addSubview:rootView];

                                                           }];
    UIAlertAction * loadFromLocal = [UIAlertAction actionWithTitle:@"Load a local file"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               ExploreFilesView * efv = [[[NSBundle mainBundle] loadNibNamed:@"ExploreFilesView"
                                                                                                                       owner:self
                                                                                                                     options:nil] objectAtIndex:0];
                                                               [efv setFrame:self.view.frame];
                                                               [efv.background setFrame:self.view.frame];
                                                               efv.delegate = self;
                                                               
                                                               [self.view addSubview:efv];
                                                               
                                                           }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    
    [ac addAction:loadFromServer];
    [ac addAction:loadFromLocal];
    [ac addAction:pasteFromText];
    [ac addAction:cancel];
    
    
    UIPopoverPresentationController * popover = ac.popoverPresentationController;
    if(popover){
        popover.sourceView = folder;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}


- (IBAction)openOldDiagram:(id)sender {
    [self showOptionsPopup];
}


#pragma mark PasteViewDelegate

-(void)saveTextFromPasteView: (PasteView *) pasteView{
    NSString * text = [pasteView.textview text];
    
    //Open diagram with that text
    
    //We need palette name
    
}


#pragma mark Parse exported json / ecore
-(void)completePaletteForJSONAttributes{
    //dele.paletteIttems
    //Para cada item de la paleta, tendré que rellenar el array de atributos
    PaletteItem * pi = nil;
    
    //Pasamos el json a un nsdictionary
    //TODO: Quitar el fichero harcodeado
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"testNuevo" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSError *jsonError;
    
    //JsonDic es el fichero JSON (ecore)
    NSMutableDictionary *jsonDict = [NSJSONSerialization
                                     JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&jsonError];
    
    NSArray * classes = [jsonDict objectForKey:@"classes"];
    

    //Para cada item de la paleta, vamos a obtener sus atributos y sus referencias
    for(int i = 0; i< dele.paletteItems.count; i++){
        pi = [dele.paletteItems objectAtIndex:i];
        //pi.className tendrá el nombre de la clase
        
        pi.attributes = [[NSMutableArray alloc] init];
        pi.references = [[NSMutableArray alloc] init];
        pi.parentsClassArray = [[NSMutableArray alloc] init];
        
        
        [self getAttributesForClass:pi.className
                       onClassArray:classes
         storeOnAttributesArray:pi.attributes
                 andReferencesArray:pi.references];
        
        
        //Tengo los atributos y las referencias para cada clase.
        
        //Extraemos las clases padre
        [self getParentsForClass:pi.className
                    onClassArray:classes
         storeOnParentClassArray:pi.parentsClassArray];
        
        //Para cada clase padre añadimos las referencias correspondientes
        
        /*for(NSString * str in pi.parentsClassArray){
            //str tendrá el nombre de la clase padre
            [self getAttributesForClass:str
                           onClassArray:classes
                 storeOnAttributesArray:pi.attributes
                     andReferencesArray:pi.references];
        }*/
        
        
        
        
    }

}

-(void)getParentsForClass: (NSString *) key
             onClassArray: (NSArray * ) classArray
  storeOnParentClassArray: (NSMutableArray *) parents{
    
    NSDictionary * dic = nil;
    NSString * name;
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    for(int i = 0; i< classArray.count; i++){
        name = nil;
        dic = [classArray objectAtIndex:i];
        name = [dic objectForKey:@"name"];
        
        if([name isEqualToString:key]){
            NSArray * pars = [dic objectForKey:@"parents"];
            
            if(pars.count != 0){
                
                for(NSString * str in pars){
                    [parents addObject:str];
                }
            }
        }
    }
}

-(void)getAttributesForClass: (NSString *) key
                          onClassArray: (NSArray *)classArray
                       storeOnAttributesArray:(NSMutableArray *)attrsArray
                           andReferencesArray:(NSMutableArray *)refsArray{
    ClassAttribute * temp;
    
    NSDictionary * dic = nil;
    NSString * name;
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    //NSMutableArray * attributes = [[NSMutableArray alloc] init];
    
    
    for(int i = 0; i< classArray.count; i++){
        name = nil;
        dic = [classArray objectAtIndex:i];
        name = [dic objectForKey:@"name"];
        
        if([name isEqualToString:key]){
            
            
            //Sacamos los atributos
            NSArray * attrs = [dic objectForKey:@"attributes"];
            for(int a = 0; a < attrs.count; a++){
                NSDictionary * atrDic = [attrs objectAtIndex:a];
                temp = [[ClassAttribute alloc]init];
                 temp.name = [atrDic objectForKey:@"name"];
                 temp.type = [atrDic objectForKey:@"type"];
                 temp.min = [f numberFromString:[atrDic objectForKey:@"min"]];
                 temp.max = [f numberFromString:[atrDic objectForKey:@"max"]];
                 temp.defaultValue = [atrDic objectForKey:@"default"];
                if([temp.defaultValue isEqualToString:@"null"]){
                    temp.defaultValue = @"";
                }
                
                [attrsArray addObject:temp];
            }
            
            
            
            //Sacamos las references
            NSArray * refs = [dic objectForKey:@"references"];
            for(int a = 0; a < refs.count; a++){
                NSDictionary * rdic = [refs objectAtIndex:a];
                Reference * ref = [[Reference alloc]init];
                ref.name = [rdic objectForKey:@"name"];
                NSString * maxstr = [rdic objectForKey:@"max"];
                if([maxstr isEqualToString:@"-1"]){
                    ref.max = [NSNumber numberWithInt:-1];
                }else{
                    ref.max = [f numberFromString:maxstr];
                }
                
                if([[rdic objectForKey:@"min"] isEqualToString:@""]){
                    ref.min = [NSNumber numberWithInt:-1];
                }else{
                    ref.min = [f numberFromString:[rdic objectForKey:@"min"]];
                }
                
                ref.containment = [rdic objectForKey:@"containment"];
                ref.target = [rdic objectForKey:@"target"];
                ref.opposite = [rdic objectForKey:@"opposite"];
                
                [refsArray addObject: ref];
            }
            
            
        }
    }
    
}

-(void)parseXMLDiagram: (NSString *)text{
    
}

-(void)parseJSONDiagram: (NSString *)text{
    
}

#pragma mark ExploreFilesView delegate
-(void)reactToFile:(NSString *)path{
    
    //Tenemos el fichero del diagrama

    //NSLog(path);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString * finalPath = [documentsDirectory stringByAppendingString:@"/diagrams/"];
    finalPath = [finalPath stringByAppendingString:path];
    
    NSError * error = nil;
    content = [NSString stringWithContentsOfFile:finalPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];

    loadingADiagram = YES;
    // [self performSegueWithIdentifier:@"showEditor" sender:self];
    
    [self parseXMLDiagram];
}


#pragma mark UIViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showEditor"])
    {
        // Get reference to the destination view controller
        EditorViewController *vc = [segue destinationViewController];
        
    }
}


#pragma mark Load old diagram
-(void)parseContent{
    [self parseXMLDiagram];
}

-(void)parseXMLDiagram{
    NSDictionary * dic = [NSDictionary dictionaryWithXMLString:content];
    
    NSDictionary * nodeDic = [dic objectForKey:@"Nodes"];
    NSArray * nodes = [nodeDic objectForKey:@"node"];
    
    if([nodes isKindOfClass:[NSDictionary class]]){
        nodes = [[NSArray alloc]initWithObjects:nodes, nil];
    }
    
    NSDictionary * edgesDic = [dic objectForKey:@"Edges"];
    NSArray * edges = [edgesDic objectForKey:@"edge"];
    
    if([edges isKindOfClass:[NSDictionary class]]){
        edges = [[NSArray alloc]initWithObjects:edges, nil];
    }
    NSDictionary * palDic = [dic objectForKey:@"palette_name"];
    NSString * paletteName = [palDic objectForKey:@"_name"];
    
    NSDictionary * subpaldic = [dic objectForKey:@"subpalette"];
    NSString * subpalette= [subpaldic objectForKey:@"_name"];
    dele.subPalette = subpalette;
    
    
    
    NSMutableArray * loadedComponents = [[NSMutableArray alloc] init];
    for(NSDictionary * dic in nodes){
        Component * comp = [self componentFromDictionary:dic];
        [loadedComponents addObject:comp];
    }
    
    NSMutableArray * loadedConnections = [[NSMutableArray alloc] init];
    for(NSDictionary * dic in edges){
        Connection * conn = [self connectionFromDictionary:dic andComponentsArray:loadedComponents];
        [loadedConnections addObject:conn];
    }
    
    dele.components = loadedComponents;
    dele.connections = loadedConnections;
    

    //Try loading palette with that name
    NSString * paletteContent = [self loadPaletteNamed:paletteName];
    
    
    [self extractPalettesForContentsOfFile:paletteContent];
    
    Palette * paletteForUse = [self extractSubPalette:dele.subPalette];
    
    palette = paletteForUse;
    [palette preparePalette];
    
    dele.paletteItems = [[NSMutableArray alloc] initWithArray:palette.paletteItems];
    [refreshTimer invalidate];
    
    [self completePaletteForJSONAttributes];
    
    dele.currentPaletteFileName = tempPaletteFile;

    
    [self performSegueWithIdentifier:@"showEditor" sender:self];
}

-(NSString *)loadPaletteNamed: (NSString *)name{
    
    //Search on local palettes
    
    NSString * con = [self searchOnLocalPalettes:name];
    
    return con;
}

-(NSString *)searchOnLocalPalettes: (NSString *)name{
    NSString * temp = nil;
    
    NSArray * bpaths = [[NSBundle mainBundle] pathsForResourcesOfType:@".graphicR" inDirectory:nil];
    for(NSString * path in bpaths){
        NSArray * components = [path componentsSeparatedByString:@"/"];
        
       NSString * n = [components objectAtIndex:components.count -1];
        if([n isEqualToString:name]){
            temp = [NSString stringWithContentsOfFile:path
                                        encoding:NSUTF8StringEncoding
                                        error:nil];
            return temp;
        }
    }

    
    return temp;
}


-(Component *)componentFromDictionary: (NSDictionary *)dic{
    Component * temp = [[Component alloc] init];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;

    NSString * name = [dic objectForKey:@"_name"];
    NSString * compId = [dic objectForKey:@"_id"];
    float x = [[dic objectForKey:@"_x"]floatValue];
    float y = [[dic objectForKey:@"_x"]floatValue];
    NSString * shape = [dic objectForKey:@"_shape_type"];
    
    NSString * colorString = [dic objectForKey:@"_color"];
    NSString * type = [dic objectForKey:@"_type"];
    
    float width = [[dic objectForKey:@"_width"]floatValue];
    float height = [[dic objectForKey:@"_height"]floatValue];
    
    [temp setFrame:CGRectMake(0, 0, width, height)];
    temp.center = CGPointMake(x, y);
    temp.shapeType = shape;
    temp.componentId = compId;
    temp.colorString = colorString;
    temp.fillColor = [ColorPalette colorForString:colorString];
    temp.type = type;
    
    return temp;
}

-(Connection *)connectionFromDictionary: (NSDictionary *)dic
                     andComponentsArray: (NSMutableArray *)components{
    Connection * conn = [[Connection alloc]init];
    
    NSString * name = [dic objectForKey:@"_name"];
    NSString * sourceId = [dic objectForKey:@"_source"];
    NSString * targetId = [dic objectForKey:@"_target"];
    
    Component * source = nil;
    Component * target = nil;
    
    //Get source
    for(Component * c in components){
        if([c.componentId isEqualToString:sourceId]){
            source = c;
        }
        
        if([c.componentId isEqualToString:targetId]){
            target = c;
        }
    }
    
    conn.name = name;
    conn.source = source;
    conn.target = target;
    
    
    return conn;
}
@end
