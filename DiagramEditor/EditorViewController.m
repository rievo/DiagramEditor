//
//  EditorViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "EditorViewController.h"
#import "ComponentDetailsViewController.h"
#import "ConnectionDetailsViewController.h"
#import "Connection.h"
#import "Palette.h"
#import "PaletteItem.h"
#import "XMLWriter.h"



@import Foundation;

@interface EditorViewController ()

@end

@implementation EditorViewController

@synthesize canvas;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dele = [[UIApplication sharedApplication]delegate];
    [canvas prepareCanvas];
    dele.can = canvas;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showComponentDetails:)
                                                 name:@"showCompNot"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showConnectionDetails:)
                                                 name:@"showConnNot"
                                               object:nil];
    
    
    //Load palette
    palette.paletteItems = [[NSMutableArray alloc] initWithArray:dele.paletteItems];
    [palette preparePalette];
    
    //Añadimos a los items de la paleta el gestor de gestos para poder arrastrarlos
    for(int i  =0; i< dele.paletteItems.count; i++){
        PaletteItem * item = [dele.paletteItems objectAtIndex:i];
        
        UIPanGestureRecognizer * panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [item addGestureRecognizer:panGr];
    }
    
    backSure = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:backSure];
    backSure.backgroundColor = [UIColor blackColor];
    backSure.alpha = 0.6;
    [backSure setHidden:YES];
    [sureCloseView setHidden:YES];
    [self.view bringSubviewToFront:sureCloseView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showComponentDetails:(NSNotification *)not{
    NSLog(@"Showing component's details");
    Component * temp = not.object;
    
    [self performSegueWithIdentifier:@"showComponentDetails" sender:temp];
}


-(void)showConnectionDetails:(NSNotification *)not{
    Connection * temp = not.object;
    [self performSegueWithIdentifier:@"showConnectionDetails" sender:temp];
}

-(void)handlePan:(UILongPressGestureRecognizer *)recog{
    PaletteItem * sender = (PaletteItem *)recog.view;
    
    CGPoint p = [recog locationInView:self.view];
    
    if(recog.state == UIGestureRecognizerStateBegan){
        //Creamos el icono temporal
        tempIcon = [[PaletteItem alloc] init];
        tempIcon.type = sender.type;
        tempIcon.dialog = sender.dialog;
        tempIcon.width = sender.width;
        tempIcon.height = sender.height;
        tempIcon.shapeType = sender.shapeType;
        [tempIcon setFrame:sender.frame];
        [tempIcon setAlpha:0.4];
        tempIcon.center = p;
        tempIcon.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tempIcon];
    }else if(recog.state == UIGestureRecognizerStateChanged){
        //Movemos el icono temporal
        tempIcon.center = p;
    }else if(recog.state == UIGestureRecognizerStateEnded){
        //Retiramos el icono temporal
        [tempIcon removeFromSuperview];
        tempIcon = nil;
        
        //Check if point is inside canvas.
        
        if(CGRectContainsPoint(canvas.frame, p)){
            //Añadimos un Component al lienzo
            if([sender.type isEqualToString:@"graphicR:Node"]){
                //It is a node
                NSLog(@"Creating a node");
                
                Component * comp = [[Component alloc] initWithFrame:CGRectMake(0, 0, sender.width.floatValue, sender.height.floatValue)];
                comp.center = p;
                comp.name = sender.dialog;
                comp.type = sender.type;
                comp.shapeType = sender.shapeType;
                comp.fillColor = sender.fillColor;
                [dele.components addObject:comp];
                [comp updateNameLabel];
                [canvas addSubview:comp];
                
            }else{
                //It is an edge
                NSLog(@"Creating a relation");
            }
        }else{
            NSLog(@"Nanai, soltado fuera");
        }
        
        
    }
}

//Just for test purposing
- (IBAction)addElement:(id)sender {
    Component * temp = [[Component alloc] initWithFrame:CGRectMake(50, 50, 40, 40)];
    [dele.components addObject:temp];
    [canvas addSubview:temp];
}

- (IBAction)showComponentList:(id)sender {
    [self performSegueWithIdentifier:@"showComponentsView" sender:self];
}

- (IBAction)showActionsList:(id)sender {
}

- (IBAction)createNewDiagram:(id)sender {
    [backSure setHidden:NO];
    [sureCloseView setHidden:NO];

}

- (IBAction)sureCreateNew:(id)sender {
    [self resetAll];
    [backSure setHidden:YES];
    [sureCloseView setHidden:YES];
}

- (IBAction)notSureCreateNew:(id)sender {
    [backSure setHidden:YES];
    [sureCloseView setHidden:YES];
}

-(void)resetAll{
     dele.components = [[NSMutableArray alloc] init];
     dele.connections = [[NSMutableArray alloc] init];
     [canvas prepareCanvas];
}

- (IBAction)saveCurrentDiagram:(id)sender {
    //Generate XML
    XMLWriter * writer = [[XMLWriter alloc] init];
    [writer writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    [writer writeStartElement:@"Diagram"];
    
    [writer writeStartElement:@"Nodes"];
    Component * temp = nil;
    for(int i = 0; i< dele.components.count; i++){
        temp = [dele.components objectAtIndex:i];
        [writer writeStartElement:@"node"];
        [writer writeAttribute:@"name" value:temp.name];
        [writer writeAttribute:@"shape_type" value:temp.shapeType];
        //[writer writeAttribute:@"fill_color" value:temp.fillCo]
        [writer writeAttribute:@"x" value: [[NSNumber numberWithFloat:temp.center.x]description]];
        [writer writeAttribute:@"y" value: [[NSNumber numberWithFloat:temp.center.y]description]];
        [writer writeAttribute:@"id" value: [[NSNumber numberWithInt:(int)temp ]description]];
        [writer writeEndElement];
    }
    [writer writeEndElement];//Close nodes
    
    
    [writer writeStartElement:@"Edges"];
    Connection * c = nil;
    for(int i = 0; i<dele.connections.count; i++){
        c = [dele.connections objectAtIndex:i];
        [writer writeStartElement:@"edge"];
        [writer writeAttribute:@"name" value:c.name];
        [writer writeAttribute:@"source" value:[[NSNumber numberWithInt:(int)c.source]description]];
        [writer writeAttribute:@"target" value:[[NSNumber numberWithInt:(int)c.target]description]];
        [writer writeEndElement];
    }
    [writer writeEndElement];
    
    [writer writeEndElement];//Close diagram
    [writer writeEndDocument];
    
    NSString * xml = [writer toString];

    
    controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Diagram test"];
    //[controller setMessageBody:@"Hello there." isHTML:NO];
    [controller setMessageBody:xml isHTML:NO];
    [self presentViewController:controller animated:YES completion:nil];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showComponentDetails"])
    {
        // Get reference to the destination view controller
        ComponentDetailsViewController *vc = [segue destinationViewController];
        vc.comp = sender;
        // Pass any objects to the view controller here, like...
        //[vc setMyObjectHere:object];
    }else if([[segue identifier] isEqualToString:@"showConnectionDetails"]){
        ConnectionDetailsViewController * vc = [segue destinationViewController];
        vc.conn = sender;
    }
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
@end
