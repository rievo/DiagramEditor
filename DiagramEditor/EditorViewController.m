//
//  EditorViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "EditorViewController.h"
#import "ComponentDetailsView.h"

#import "Connection.h"
#import "Palette.h"
#import "PaletteItem.h"
#import "XMLWriter.h"
#import "XMLDictionary.h"
#import "ClassAttribute.h"

#import "NoDraggableComponentView.h"

@import Foundation;

@interface EditorViewController ()

@end

@implementation EditorViewController

@synthesize scrollView, loadedContent;

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
    
    
    compDetView = [[[NSBundle mainBundle] loadNibNamed:@"ComponentDetailsView"
                                                 owner:self
                                               options:nil] objectAtIndex:0];
    
    
    [compDetView setDelegate:self];
    
    
    
    [self.view addSubview:compDetView];
    [compDetView setFrame:self.view.frame];
    [compDetView setHidden:YES];
    
    
    
    UITapGestureRecognizer * zoomTapGr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(doZoom:)];
    
    [zoomTapGr setNumberOfTapsRequired:2];
    [scrollView setUserInteractionEnabled:YES];
    [scrollView setCanCancelContentTouches:YES];
    [scrollView addGestureRecognizer:zoomTapGr];
    zoomTapGr.delegate = self;
    zoomLevel = 0; //No zoom
    
    
    
    //Si estoy cargando un fichero
    if(dele.components.count != 0){
        
        for(Component * comp in dele.components){
            [canvas addSubview:comp];
            [comp updateNameLabel];
        }
        //repaint canvas
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }else{
    }
    
    palette.paletteItems = [[NSMutableArray alloc] initWithArray:dele.paletteItems];
    [palette preparePalette];
    palette.name = dele.subPalette;
    palette.sliderToChange = slider;
    
    dele.evc = self;
    
    
    //Set slider
    //if(palette.contentSize.width > palette.frame.size.width){
        slider.maximumValue = palette.frame.size.width -palette.contentSize.width ;
    //}else{
        //[slider setHidden:YES];
    //}
    
    //NSLog(@"pags = %.2f", ceil(palette.frame.size.width / palette.contentSize.width ));
}



#pragma mark Show/Hide detailsView
-(void)showDetailsView{
    [compDetView prepare];
    [compDetView setHidden:NO];
}
-(void)hideDetailsView{
    [compDetView setHidden:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    palette.paletteItems = [[NSMutableArray alloc] initWithArray:dele.paletteItems];
    [palette preparePalette];
    palette.name = dele.subPalette;
    
    //Añadimos a los items de la paleta el gestor de gestos para poder arrastrarlos
    for(int i  =0; i< palette.paletteItems.count; i++){
        PaletteItem * item = [palette.paletteItems objectAtIndex:i];
        
        if([item.type isEqualToString:@"graphicR:Edge"]){
            
        }else{
            if(item.isDragable == TRUE){
                UIPanGestureRecognizer * panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
                [item addGestureRecognizer:panGr];
                
            }else{ //Tapgesture para añadir un elemento no dragables
                UITapGestureRecognizer * tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                [item addGestureRecognizer:tapGr];
                
                
                //Creo un array para esta clave en dele
                NSMutableArray * compArray = [[NSMutableArray alloc] init];
                [dele.elementsDictionary setObject:compArray forKey:item.className];
            }
        }
        
    }
}

-(void)showComponentDetails:(NSNotification *)not{
    NSLog(@"Showing component's details");
    Component * temp = not.object;
    
    //[self performSegueWithIdentifier:@"showComponentDetails" sender:temp];
    
    //Load component details view
    compDetView.comp = temp;
    //[compDetView prepare];
    [self showDetailsView];
    
}

#pragma mark UIPanGestureRecognizer


-(void)handlePan:(UIPanGestureRecognizer *)recog{
    PaletteItem * sender = (PaletteItem *)recog.view;
    
    CGPoint p = [recog locationInView:self.view];
    
    if(recog.state == UIGestureRecognizerStateBegan && ![sender.type isEqualToString:@"graphicR:Edge"]){
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
    }else if(recog.state == UIGestureRecognizerStateChanged&& ![sender.type isEqualToString:@"graphicR:Edge"]){
        //Movemos el icono temporal
        tempIcon.center = p;
    }else if(recog.state == UIGestureRecognizerStateEnded&& ![sender.type isEqualToString:@"graphicR:Edge"]){
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
                
    
                
                Component * comp = [sender getComponentForThisPaletteItem];
                comp.canvas = self.view;
                [comp setFrame:CGRectMake(0, 0, sender.width.floatValue, sender.height.floatValue)];
                [comp setCenter:pointInSV];
                [comp fitNameLabel];
                
                
                [dele.components addObject:comp];
                [comp updateNameLabel];
                [canvas addSubview:comp];
                
            }else if([sender.type isEqualToString:@"graphicR:Edge"]){
                //It is an edge
                
                //Comprobamos si hay alguna relación cerca
                //En caso de que la haya, esa relación pasará a ser del tipo arrastrado
                
                //sender.attributes tiene los atributos
                //
                
                Connection * con;
                for(int  i = 0; i< dele.connections.count; i++){
                    con = [dele.connections objectAtIndex:i];
                    BOOL res = [canvas isPoint:pointInSV
                                withinDistance:10.0
                                        ofPath:con.arrowPath.CGPath];
                    
                    if(res == true){
                        //Set that connection to sender
                        //con.reference = sender;
                        NSLog(@"Change reference type");
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                                        message:@"Changing connection type"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        
                        con.attributes = sender.attributes;
                        
                    }else{
                        //Nothing to do
                    }
                }
            }
        }else{
            NSLog(@"There is no canvas on this point.");
        }
        
        
    }
}


-(void)handleTap:(UITapGestureRecognizer *)recog{
    PaletteItem * sender = (PaletteItem *)recog.view;
    
    NoDraggableComponentView * nod = [[[NSBundle mainBundle] loadNibNamed:@"NoDraggableComponentView"
                                                                    owner:self
                                                                  options:nil] objectAtIndex:0];
    
    nod.elementName = sender.className;
    nod.paletteItem = sender;
    
    [nod updateNameLabel];
    [nod setFrame:self.view.frame];
    [self.view addSubview:nod];
    
}


#pragma mark Toolbar


-(void)showConnectionDetails:(NSNotification *)not{
    Connection * temp = not.object;
    
    ConnectionDetailsView * cdv = [[[NSBundle mainBundle] loadNibNamed:@"ConnectionDetailsView"
                                                                 owner:self
                                                               options:nil] objectAtIndex:0];
    
    //cdv.center = self.view.center;
    cdv.connection = temp;
    [cdv setFrame:self.view.frame];
    [cdv prepare];
    cdv.delegate = self;
    [self.view addSubview:cdv];
    [cdv setNeedsDisplay];
}

- (IBAction)showComponentList:(id)sender {
    [self performSegueWithIdentifier:@"showComponentsView" sender:self];
}

- (IBAction)showActionsList:(id)sender {
    
}

- (IBAction)createNewDiagram:(id)sender {
    
    sureView = [[[NSBundle mainBundle] loadNibNamed:@"SureView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
    [self.view addSubview:sureView];
    [sureView setFrame:self.view.frame];
    sureView.delegate = self;
}

-(void)resetAll{
    dele.components = [[NSMutableArray alloc] init];
    dele.connections = [[NSMutableArray alloc] init];
    [canvas prepareCanvas];
}

#pragma mark Save diagram
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
                                                              [self saveDiagramOnDevice];
                                                          }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    
    UIAlertAction * saveOnServer = [UIAlertAction actionWithTitle:@"Save on server"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              //[self saveDiagramOnServer];
                                                              UIAlertController *alertController = [UIAlertController
                                                                                                    alertControllerWithTitle:@"title"
                                                                                                    message:@""
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                                              
                                                              [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
                                                               {
                                                                   textField.placeholder = @"name";
                                                               }];
                                                              
                                                              
                                                              UIAlertAction * confirmName = [UIAlertAction
                                                                                         actionWithTitle:@"Ok"
                                                                                         style:UIAlertActionStyleDefault
                                                                                         handler:^(UIAlertAction *action)
                                                                                         {
                                                                                             UITextField * nameTF = alertController.textFields.firstObject;
                                                                                             
                                                                                             if (nameTF.text.length != 0) {
                                                                                                 [self saveDiagramOnServerWithName:nameTF.text];
                                                                                             }else{
                                                                                                 
                                                                                             }
                                                                                             
                                                                                         }];
                                                              
                                                              UIAlertAction * cancelName = [UIAlertAction actionWithTitle:@"Cancel"
                                                                                                                    style:UIAlertActionStyleDestructive
                                                                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                                                                      
                                                                                                                  }];
                                                              [alertController addAction:confirmName];
                                                              [alertController addAction:cancelName];
                                                              
                                                              [self presentViewController:alertController animated:YES completion:^{
                                                                  
                                                              }];
                                                              
                                                          }];
    
    [ac addAction:sendemail];
    [ac addAction:saveondevice];
    [ac addAction:cancel];
    [ac addAction:saveOnServer];
    
    
    UIPopoverPresentationController * popover = ac.popoverPresentationController;
    if(popover){
        popover.sourceView = saveButton;
        //popover.sourceRect = sender.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}

-(void)saveDiagramOnServerWithName: (NSString *)name{
    
    [self.view endEditing:YES];
    NSString * toSave = [self generateXML];
    NSDate * date = [NSDate date];
    
    
    UIImage * resultedImage = [self getImageDataFromCanvas];
    
    //float newW = resultedImage.size.width * 100 / resultedImage.size.height;
    float newH = resultedImage.size.height *100 / resultedImage.size.width;
    
    UIImage * resized = [EditorViewController imageWithImage:resultedImage scaledToSize:CGSizeMake(100, newH)];

    NSData * imageData = UIImagePNGRepresentation(resized);
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[date description] forKey:@"dateString"];
    [dic setObject:toSave forKey:@"content"];
    [dic setObject:name forKey:@"name"];
    
    NSString *base64Encoded = [imageData base64EncodedStringWithOptions:0];
    [dic setObject:base64Encoded forKey:@"imageData"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
    
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if(!error){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://diagrameditorserver.herokuapp.com/diagrams?json=true"]];
        //NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2.0];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setTimeoutInterval:5.0];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: data];
        //[request setHTTPBody:[toSave dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data, NSError *connectionError)
         {
             NSError * error;
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:&error];
             
             //[serverFilesArray removeAllObjects];
             
             NSString * code = [dic objectForKey:@"code"];
             
             if([code isEqualToString:@"200"]){ //Good :)
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                                 message:@"Diagram saved properly on server"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
             }else{ //Error
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:[NSString stringWithFormat:@"Info: %@", connectionError]
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
             }
             
         }];
        //NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        /*if(!error){
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
         message:@"Diagram saved properly on server"
         delegate:self
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil];
         [alert show];
         }else{
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
         message:@"Diagram was not saved on server"
         delegate:self
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil];
         [alert show];
         }*/
    }else{
        NSLog(@"Error generating diagram json");
    }
}

-(void) saveDiagramOnDevice{
    textToSave = [self generateXML];
    
    [snv removeFromSuperview];
    
    [saveBackgroundBlackView removeFromSuperview];
    saveBackgroundBlackView = [[UIView alloc] initWithFrame:self.view.frame];
    [saveBackgroundBlackView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    
    snv = [[[NSBundle mainBundle] loadNibNamed:@"SaveNameView"
                                         owner:self
                                       options:nil] objectAtIndex:0];
    
    if(oldFileName.length  > 0)
        snv.textField.text = oldFileName;
    //snv.center = saveBackgroundBlackView.center;
    //[saveBackgroundBlackView addSubview:snv];
    [snv setFrame:self.view.frame];
    snv.delegate = self;
    
    [self.view addSubview:snv];
}

-(BOOL)writeFile: (NSString *)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"/diagrams"];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:folderPath])
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    if(error){
        NSLog(@"%@",[error description]);
    }
    
    error = nil;
    NSString *filePath = [folderPath stringByAppendingPathComponent:name];
    filePath = [filePath stringByAppendingString:@".xml"];
    [textToSave writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    if(error){
        NSLog(@"%@",[error description]);
        return NO;
    }else{
        return YES;
    }
    
    //Quitar la vista de
}

-(NSString *)generateXML{
    //Generate XML
    XMLWriter * writer = [[XMLWriter alloc] init];
    [writer writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    [writer writeStartElement:@"Diagram"];
    
    [writer writeStartElement:@"palette_name"];
    [writer writeAttribute:@"name" value: dele.currentPaletteFileName];
    [writer writeEndElement];
    
    [writer writeStartElement:@"subpalette"];
    [writer writeAttribute:@"name" value: dele.subPalette];
    [writer writeEndElement];
    
    
    [writer writeStartElement:@"Nodes"];
    Component * temp = nil;
    for(int i = 0; i< dele.components.count; i++){
        temp = [dele.components objectAtIndex:i];
        [writer writeStartElement:@"node"];
        //[writer writeAttribute:@"name" value:temp.name];
        [writer writeAttribute:@"shape_type" value:temp.shapeType];
        [writer writeAttribute:@"x" value: [[NSNumber numberWithFloat:temp.center.x]description]];
        [writer writeAttribute:@"y" value: [[NSNumber numberWithFloat:temp.center.y]description]];
        [writer writeAttribute:@"id" value: [[NSNumber numberWithInt:(int)temp ]description]];
        [writer writeAttribute:@"color" value:temp.colorString];
        [writer writeAttribute:@"type" value:temp.type];
        [writer writeAttribute:@"width" value: [[NSNumber numberWithFloat:temp.frame.size.width]description]];
        [writer writeAttribute:@"height" value: [[NSNumber numberWithFloat:temp.frame.size.height]description]];
        [writer writeAttribute:@"className" value:temp.className];
        
        //For each component, fill his attributes
        for(ClassAttribute * ca in temp.attributes){
            [writer writeStartElement:@"attribute"];
            [writer writeAttribute:@"name" value:ca.name];
            [writer writeAttribute:@"default_value" value:ca.defaultValue];
            if(ca.currentValue != nil)
                [writer writeAttribute:@"current_value" value:ca.currentValue];
            else
                [writer writeAttribute:@"current_value" value:@""];
            //TODO: Por aquí hay un error
            [writer writeAttribute:@"max" value:[ca.max description]];
            [writer writeAttribute:@"min" value:[ca.min description]];
            [writer writeAttribute:@"type" value:ca.type];
            [writer writeEndElement];
        }
        [writer writeEndElement];
        
    }
    [writer writeEndElement];//Close nodes
    
    
    [writer writeStartElement:@"Edges"];
    Connection * c = nil;
    for(int i = 0; i<dele.connections.count; i++){
        c = [dele.connections objectAtIndex:i];
        [writer writeStartElement:@"edge"];
        //[writer writeAttribute:@"name" value:c.name];
        [writer writeAttribute:@"source" value:[[NSNumber numberWithInt:(int)c.source]description]];
        [writer writeAttribute:@"target" value:[[NSNumber numberWithInt:(int)c.target]description]];
        [writer writeAttribute:@"className" value:c.className];
        [writer writeEndElement];
    }
    [writer writeEndElement];
    
    [writer writeEndElement];//Close diagram
    [writer writeEndDocument];
    
    NSString * xml = [writer toString];
    return xml;
}


- (IBAction)willChangePalette:(id)sender {
    
    dele.currentPaletteFileName = nil;
    [dele.components removeAllObjects];
    [dele.connections removeAllObjects];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(UIImage *)getImageDataFromCanvas{
    //Get min bound
    Component * minx = nil;
    Component * miny = nil;
    Component * maxx = nil;
    Component * maxy = nil;
    
    float minxW, minyW, maxxW, maxyW;
    
    for(Component * comp in dele.components){
        //First round
        if(minx == nil){
            minx = comp;
        }
        if(miny == nil){
            miny = comp;
        }
        if(maxx == nil){
            maxx = comp;
        }
        if(maxy == nil){
            maxy = comp;
        }
        
        //Let's update this
        if(comp.center.x < minx.center.x){
            minx = comp;
        }
        if(comp.center.x > maxx.center.x){
            maxx = comp;
        }
        if(comp.center.y < miny.center.y){
            miny = comp;
        }
        if(comp.center.y >maxy.center.y){
            maxy = comp;
        }
    }
    
    minxW = minx.frame.size.width / 2;
    minyW = miny.frame.size.height / 2;
    maxxW = maxx.frame.size.width / 2;
    maxyW = maxy.frame.size.height / 2;
    
    float textHeigh = 20;
    float margin = 15;
    
    float scale = [UIScreen mainScreen].scale;
    
    //*2 due to retina display
    CGRect cutRect = CGRectMake(roundf(minx.center.x -minxW-textHeigh- 2*margin)*scale,
                                roundf(miny.center.y - minyW - textHeigh- 2*margin)*scale,
                                roundf(maxx.center.x-minx.center.x + minxW + maxxW +textHeigh+ 2*margin*2)*scale,
                                roundf(maxy.center.y-miny.center.y + minyW + maxyW +textHeigh+ 2*margin*2)*scale);
    
    UIGraphicsBeginImageContextWithOptions(canvas.frame.size,
                                           canvas.opaque,
                                           0.0);
    [canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* image = nil;
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    CGImageRef imgref = image.CGImage;
    
    
    CGImageRef subimage = CGImageCreateWithImageInRect(imgref, cutRect);
    UIImage * finalImage = [UIImage imageWithCGImage:subimage];
    
    //NSData * data = UIImagePNGRepresentation(finalImage);
    
    return finalImage;
}


- (IBAction)exportCanvasToImage:(id)sender {
    
    
    
    UIImage * finalImage = [self getImageDataFromCanvas];
    NSData * data = UIImagePNGRepresentation(finalImage);
    
    UIAlertController * ac  = [UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * sendemail = [UIAlertAction actionWithTitle:@"Send email"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           
                                                           controller = [[MFMailComposeViewController alloc] init];
                                                           controller.mailComposeDelegate = self;
                                                           [controller setSubject:@"Digram image text"];
                                                           [controller addAttachmentData:data mimeType:@"image/png" fileName:@"photo"];
                                                           [self presentViewController:controller animated:YES completion:nil];
                                                       }];
    
    UIAlertAction * saveondevice = [UIAlertAction actionWithTitle:@"Save on camera roll"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self saveImageOnCameraRoll:finalImage];
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
        popover.sourceView = cameraOutlet;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}

-(void)saveImageOnCameraRoll: (UIImage *) image{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:@"Image saved properly"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



#pragma mark Storyboard
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
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
    float current = val * maxz ;
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


- (void)zoomToPoint:(CGPoint)zoomPoint withScale:(CGFloat)scale animated:(BOOL)animated
{
    
    
    
    CGPoint translatedZoomPoint = CGPointZero;
    translatedZoomPoint.x = zoomPoint.x + scrollView.contentOffset.x;
    translatedZoomPoint.y = zoomPoint.y + scrollView.contentOffset.y;
    
    
    CGFloat zoomFactor = 1.0f / scrollView.zoomScale;
    
    
    translatedZoomPoint.x *= zoomFactor;
    translatedZoomPoint.y *= zoomFactor;
    
    
    CGRect destinationRect = CGRectZero;
    destinationRect.size.width = CGRectGetWidth(scrollView.frame) / scale;
    destinationRect.size.height = CGRectGetHeight(scrollView.frame) / scale;
    destinationRect.origin.x = translatedZoomPoint.x - (CGRectGetWidth(destinationRect) * 0.5f);
    destinationRect.origin.y = translatedZoomPoint.y - (CGRectGetHeight(destinationRect) * 0.5f);
    
    
    [UIView animateWithDuration:0.55f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.6f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [scrollView zoomToRect:destinationRect animated:NO];
    } completion:^(BOOL completed) {
        if ([scrollView.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
            [scrollView.delegate scrollViewDidEndZooming:scrollView withView:[scrollView.delegate viewForZoomingInScrollView:scrollView] atScale:scale];
        }
    }];
}


-(void)doZoom: (UITapGestureRecognizer * )tapRecognizer{
    if(zoomLevel == 0){
        zoomLevel = 1;
    }else if(zoomLevel == 1){
        zoomLevel = 0;
    }else{
        zoomLevel = 0;
    }
    
    CGPoint p = [tapRecognizer locationInView: self.view];
    CGPoint pointInSV = [self.view convertPoint:p toView:canvas];
    
    float newScale = [self getZoomScaleForIntValue:zoomLevel];
    
    [self zoomToPoint:pointInSV withScale:newScale animated:YES];
}

#pragma mark ComponentDetailsView delegate

-(void)closeDetailsViewAndUpdateThings{
    [compDetView setHidden:YES];
}



#pragma mark UIGestureRecognizer
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return  YES;
}


#pragma mark SaveNameDelegate
-(void)saveName: (NSString *)name{
    BOOL result = [self writeFile:name];
    [self.view endEditing:YES];
    
    
    
    [snv setHidden:YES];
    
    if(result == NO){ //Error
        oldFileName = nil;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Error saving diagram"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        oldFileName = name;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"Diagram was saved properly"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
    
}
-(void)cancelSaving{
    [saveBackgroundBlackView setHidden:YES];
}



#pragma mark SureViewDelegate methods

-(void)closeSureViewWithResult:(BOOL)res{
    if (res == YES){
        [self resetAll];
    }else{
        
    }
}


-(BOOL) isiPad {
    return UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad;
}


#pragma mark UISlider
- (IBAction) valueChanged:(id)sender event:(UIControlEvents)event {
    [palette setContentOffset:CGPointMake(slider.value,0) animated:NO];
}



#pragma mark UIImage method
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
