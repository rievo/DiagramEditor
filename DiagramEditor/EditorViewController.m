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
@end
