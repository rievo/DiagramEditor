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

#import "Constants.h"
#import "DrawingAlert.h"
#import "ChatView.h"
#import "Alert.h"
#import "Message.h"
#import "NoteView.h"
#import "CreateNoteView.h"
#import "ColorPalette.h"

#import "DrawnAlert.h"
#import "PathPiece.h"

#define fileExtension @"demiso"
#import <Social/Social.h>

@import Foundation;

@interface EditorViewController ()

@end

@implementation EditorViewController

@synthesize scrollView, loadedContent;


-(void)viewDidAppear:(BOOL)animated{
    if(dele.shouldShowEditorTutorial == YES){
        doingTutorial = YES;
        [self startEditorTutorial];
    }else{
        doingTutorial = NO;
    }
}


- (BOOL)isIpadPro
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat width = mainScreen.nativeBounds.size.width / mainScreen.nativeScale;
    CGFloat height = mainScreen.nativeBounds.size.height / mainScreen.nativeScale;
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    BOOL hasIPadProWidth = fabs(width - 1024.f) < DBL_EPSILON;
    BOOL hasIPadProHeight = fabs(height - 1366.f) < DBL_EPSILON;
    return isIpad && hasIPadProHeight && hasIPadProWidth;
}


-(void)viewDidLayoutSubviews{
    [chatButton setFrame:CGRectMake(scrollView.frame.size.width+ (scrollView.frame.origin.x * 2) - chatButton.frame.size.width,
                                    scrollView.frame.origin.y + askForMasterButton.frame.size.height + askForMasterButton.frame.origin.y,
                                    chatButton.frame.size.width,
                                    chatButton.frame.size.height)];
}
- (void)viewDidLoad {
    
    useImageAsIcon = true;
    
    [askForMasterButton setHidden:YES];
    [chatButton setHidden:YES];
    
    //Make chatButton float
    UIPanGestureRecognizer * chatGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleChatButtonPan:)];
    [chatButton addGestureRecognizer:chatGR];

    
    [super viewDidLoad];
    
    
    if([self isIpadPro]){
        canvasW = 2500;
    }else{
        canvasW = 1500;
    }
    
    
    sharingDiagram = NO;
    
    dele = [[UIApplication sharedApplication]delegate];
    
    dele.manager.browser.delegate = self;
    
    if(dele.notesArray == nil)
        dele.notesArray = [[NSMutableArray alloc] init];
    
    if(dele.drawnsArray == nil)
        dele.drawnsArray = [[NSMutableArray alloc] init];
    
    
    //Show-hide palette
    isPaletteCollapsed = YES;
    paletteCenter = palette.center;
    paletteRect = palette.frame;
    [self collapsePalette];
    //[self fitPaletteToScreen];
    
    
    canvas = [[Canvas alloc] initWithFrame:CGRectMake(0, 0, canvasW, canvasW)];
    
    [canvas prepareCanvas];
    dele.can = canvas;
    dele.originalCanvasRect = canvas.frame;
    //canvas.backgroundColor = [dele blue0];
    canvas.backgroundColor = [UIColor colorWithRed:218/255.0 green:224/255.0 blue:235/255.0 alpha:0.6];
    [canvas setNeedsDisplay];
    
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
    //[scrollView addGestureRecognizer:zoomTapGr];
    zoomTapGr.delegate = self;
    zoomLevel = 0; //No zoom
    
    
    
    //Si estoy cargando un fichero
    if(dele.loadingADiagram){
        
        for(Component * comp in dele.components){
            [canvas addSubview:comp];
            [comp updateNameLabel];
        }
        
        

        //Load notes
        for(Alert * al in dele.notesArray){
            if(useImageAsIcon == YES){
                if(al.attach != nil)
                    al.image = al.attach;
                else{
                    al.image = noteAlert.image;
                }
            }else{
                al.image = noteAlert.image;
            }
            [canvas addSubview:al];
            [al setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNoteContent:)];
            [al addGestureRecognizer:tapgr];
            
            UIPanGestureRecognizer * pang = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleNotePan:)];
            [al addGestureRecognizer:pang];
        }
        
        //repaint canvas
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }else{
    }
    
    palette.paletteItems = [[NSMutableArray alloc] initWithArray:dele.paletteItems];
    [palette preparePalette];
    palette.name = dele.subPalette;
    //palette.sliderToChange = slider;
    
    dele.evc = self;
    
    //[sessionListContainer setHidden:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveNewAppDeleInfo)
                                                 name:@"receivedNewAppdelegate"
                                               object:nil];
    
    
    //kIWantToBeMaster
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNewMasterPetition:)
                                                 name:kIWantToBeMaster
                                               object:nil];
    //kYouAreTheNewMaster
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleIAmTheNewMaster:)
                                                 name:kYouAreTheNewMaster
                                               object:nil];
    
    //kMasterPetitionDenied
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePetitionDenied:)
                                                 name:kMasterPetitionDenied
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdateMasterButton:)
                                                 name:kUpdateMasterButton
                                               object:nil];
    
    //kNewAlert
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNewAlert:)
                                                 name:kNewAlert
                                               object:nil];
    
    
    //kUsersTableExpelPeer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleExpelPeer:)
                                                 name:kUsersTableExpelPeer
                                               object:nil];
    //kUsersTablePromotePeer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePromotePeer:)
                                                 name:kUsersTablePromotePeer
                                               object:nil];
    
    //kGoOut
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGoOut:)
                                                 name:kGoOut
                                               object:nil];
    
    [showUsersPeersViewButton setHidden:YES];
    
    //arrowFrame = arrowAlert.frame;
    interrogationFrame = interrogationAlert.frame;
    exclamationFrame = exclamationAlert.frame;
    noteFrame = noteAlert.frame;
    drawFrame = drawAlert.frame;
    
    //arrowCenter = arrowAlert.center;
    interrogationCenter = interrogationAlert.center;
    exclamationCenter = exclamationAlert.center;
    alertsCenter = alerts.center;
    drawCenter = drawAlert.center;
    noteCenter = noteAlert.center;
    
    [interrogationAlert setUserInteractionEnabled:YES];
    [exclamationAlert setUserInteractionEnabled:YES];
    [noteAlert setUserInteractionEnabled:YES];
    [drawAlert setUserInteractionEnabled:YES];
    //[arrowAlert setUserInteractionEnabled:YES];
    
    showingPossibleAlerts = NO;
    [interrogationAlert setHidden:YES];
    [exclamationAlert setHidden:YES];
    [noteAlert setHidden:YES];
    [drawAlert setHidden:YES];
    //[arrowAlert setHidden:YES];
    
    UIPanGestureRecognizer *panalertInt = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(handleAlertPan:)];
    UIPanGestureRecognizer *panalertEx = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleAlertPan:)];
    
    
    UIPanGestureRecognizer *panalertNote = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(handleAlertPan:)];
    [interrogationAlert addGestureRecognizer:panalertInt];
    [noteAlert addGestureRecognizer:panalertNote];
    [exclamationAlert addGestureRecognizer:panalertEx];
    
    
    UITapGestureRecognizer * tapDrawGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleDrawTouch:)];
    [drawAlert addGestureRecognizer:tapDrawGR];
}


-(void)handleChatButtonPan:(UIPanGestureRecognizer *)recog{
    CGPoint p = [recog locationInView:self.view];
    
    if(recog.state == UIGestureRecognizerStateBegan){
        [chatButton setCenter:p];
        [chatButton setEnabled:NO];
    }else if(recog.state == UIGestureRecognizerStateEnded){
        float xorigin = 0.0;
        float yorigin = 0.0;
        
        if(p.x > self.view.frame.size.width / 2){ // Go to right
            xorigin = self.view.frame.size.width - chatButton.frame.size.width;
        }else{ //Go to left
            xorigin = 0.0;
        }
        
       
        yorigin = p.y;
        if(yorigin > self.view.frame.size.height - chatButton.frame.size.height)
            yorigin = self.view.frame.size.height - chatButton.frame.size.height;
        
        if(yorigin < scrollView.frame.origin.y)
            yorigin = scrollView.frame.origin.y + chatButton.frame.size.height/2;
        
        [chatButton setEnabled:NO];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                         } completion:^(BOOL finished) {
                             [chatButton setFrame:CGRectMake(xorigin,
                                                             yorigin - chatButton.frame.size.height/2,
                                                             chatButton.frame.size.width,
                                                             chatButton.frame.size.height)];
                             [chatButton setEnabled:YES];
                         }];
        

        
        
    }else if(recog.state == UIGestureRecognizerStateChanged){
        float x;
        float y;
        if(p.x > self.view.frame.size.width / 2){ // Go to right
           x = self.view.frame.size.width - chatButton.frame.size.width/2;
        }else{ //Go to left
            x = 0.0 + chatButton.frame.size.width/2;
        }
        
        if(p.y > scrollView.frame.size.height + scrollView.frame.origin.y - chatButton.frame.size.height)
            y = self.view.frame.size.height - chatButton.frame.size.height/2;
        
        else if(p.y < scrollView.frame.origin.y + chatButton.frame.size.height/2)
            y = scrollView.frame.origin.y + chatButton.frame.size.height/2;
        else
            y = p.y;
        
        CGPoint point = CGPointMake(x, y);
        [chatButton setCenter:point];
        
    }
}

#pragma mark Notificationhandlers

-(void)handleDrawTouch:(UITapGestureRecognizer *)recog{
    DrawingView * dv = [[[NSBundle mainBundle] loadNibNamed:@"DrawingView"
                                   owner:self
                                 options:nil] objectAtIndex:0];
    
    dv.owner = self;
    [dv setFrame:self.view.frame];
    [dv prepare];
    
    dv.delegate = self;
    
    [self.view addSubview:dv];
}

-(void) handleUpdateMasterButton:(NSNotification *)not{
    
    
    [chatButton setHidden:NO];
    if([dele amITheMaster] == YES){
        [askForMasterButton setHidden:YES];
    }else{
        [askForMasterButton setHidden:NO];
        
        //If I am not the server, invalidate timer
        if(![dele amITheServer]){
            [resendTimer invalidate];
            resendTimer = nil;
        }
    }
    
    
    //Disable create connection
    if([dele amITheServer] == TRUE){
        [collaborationButton setEnabled:YES];
        [collaborationButton setAlpha:1.0];
    }else{
        [collaborationButton setEnabled:NO];
        [collaborationButton setAlpha:0.5];
    }
}

-(void)handleGoOut:(NSNotification*)not{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:@"You have been disconnected from session"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)handlePetitionDenied:(NSNotification *)not{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:@"You cannot be the new master"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



-(void)handleIAmTheNewMaster:(NSNotification *)not{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:@"You are the new master now"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    //Ignoro las actualizaciones del servidor
    
    //Hide ask for master
    [askForMasterButton setHidden:YES];
    [chatButton setHidden:NO];
    
    //Send my things
    NSLog(@"Start sending");
    resendTimer = [NSTimer scheduledTimerWithTimeInterval:resendTime
                                                   target:self
                                                 selector:@selector(sendMasterInfo)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:resendTimer forMode:NSRunLoopCommonModes];
}


-(void)handleNewMasterPetition:(NSNotification *)not{
    
    NSDictionary * dic = not.userInfo;
    
    MCPeerID * whoAsk = [dic objectForKey:@"peerID"];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"New petition"
                                  message:[NSString stringWithFormat:@"Peer \"%@\" wants to be master. Allow him?", whoAsk.displayName]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Allow him"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [self makeNewMasterToPeer:whoAsk];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             NSLog(@"Se lo he concedido");
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Deny petition"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 [self sendDenyMasterToPeer:whoAsk];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 NSLog(@"No se lo he concedido");
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)didReceiveNewAppDeleInfo{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
}



-(void) handlePromotePeer:(NSNotification *)not{
    NSDictionary * dic = [not userInfo];
    MCPeerID * who = [dic objectForKey:@"who"];
    [self makeNewMasterToPeer:who];
}
-(void) handleExpelPeer:(NSNotification *)not{
    
    NSDictionary * dd = [not userInfo];
    MCPeerID * peer = [dd objectForKey:@"who"];
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:peer forKey:@"peerID"];
    [dic setObject:kDisconnectYourself forKey:@"msg"];
    
    NSLog(@"Sending disconnect yourself");
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    NSError * error = nil;
    
    [dele.manager.session sendData:data
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
    
    if(!error){
        NSLog(@"Disconnect sended");
    }else{
        NSLog(@"Error %@", [error description]);
    }
}



-(void)makeNewMasterToPeer:(MCPeerID *)peer{
    
    dele.currentMasterId.peerID = peer;
    //TODO: update peer UUID
    
    //Send back you are new master
    
    
    //NO!!! Because I need to send my things
    //Invalidate my timer
    //[resendTimer invalidate];
    //resendTimer = nil;
    
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:peer forKey:@"peerID"];
    [dic setObject:kYouAreTheNewMaster forKey:@"msg"];
    
    NSLog(@"Sending you are new master");
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    NSError * error = nil;
    
    [dele.manager.session sendData:data
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
    
    if(!error){
        NSLog(@"Mandado al nuevo master");
    }else{
        NSLog(@"Error %@", [error description]);
    }
    
    
    
    
    
}

-(void)sendDenyMasterToPeer:(MCPeerID *)peer{
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:peer forKey:@"peerID"];
    [dic setObject:kMasterPetitionDenied forKey:@"msg"];
    NSLog(@"You shall not pass");
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    NSError * error = nil;
    
    
    [dele.manager.session sendData:data
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
    
    if(!error){
        NSLog(@"Denied sended");
    }else{
        NSLog(@"Error %@", [error description]);
    }
    
}

#pragma mark Show/Hide detailsView
-(void)showDetailsView{
    [compDetView prepare];
    [self.view bringSubviewToFront:compDetView];
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
    
    if([dele amITheMaster] || dele.manager.session.connectedPeers.count == 0){
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
                    [comp setFrame:CGRectMake(0, 0, sender.width.floatValue * scaleFactor, sender.height.floatValue * scaleFactor)];
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

- (IBAction)shareDiagram:(id)sender {
    
    
    NSString * xml = [self generateXML];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"dd:MM:yyyy::HH:mm:ss"];
    NSDate *now = [[NSDate alloc] init];
    
    
    NSString *fileName = [timeFormat stringFromDate:now];
    
    
    [self writeTextFileWithName:fileName andContent:xml];
    
    NSURL * fileUrl = [self fileToURL:fileName];
    
    UIActivityViewController * cont = [[UIActivityViewController alloc] initWithActivityItems:@[fileUrl]
                                                                        applicationActivities:nil];
    
    //Exclude all activities except airdrop
    NSArray * excludedActivities = @[UIActivityTypeAddToReadingList,UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypePostToTencentWeibo
                                     ];
    
    cont.excludedActivityTypes = excludedActivities;
    cont.popoverPresentationController.sourceView = shareButtonOutlet;
    [self presentViewController:cont animated:YES completion:^{
        
        /*
         //Remove created file
         NSFileManager *fileManager = [NSFileManager defaultManager];
         
         NSArray *paths = NSSearchPathForDirectoriesInDomains
         (NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         
         NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@",
         documentsDirectory, fileName, fileExtension];
         NSError * error;
         
         BOOL success = [fileManager removeItemAtPath:filePath error:&error];
         if (success) {
         UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
         [removeSuccessFulAlert show];
         }
         else
         {
         NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
         }*/
        
    }];
}

-(NSURL *)fileToURL:(NSString *)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@",
                          documentsDirectory, name, fileExtension];
    
    return [NSURL fileURLWithPath:filePath];
}


-(void)writeTextFileWithName:(NSString *)name
                  andContent:(NSString *)content{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@",
                          documentsDirectory, name, fileExtension];
    
    //save content to the documents directory
    [content writeToFile:filePath
              atomically:YES
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
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
    dele.notesArray = [[NSMutableArray alloc] init];
    dele.drawnsArray = [[NSMutableArray alloc] init];
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
                                                           
                                                           if ([MFMailComposeViewController canSendMail]) {
                                                               if(dele.components.count > 0){
                                                                   controller = [[MFMailComposeViewController alloc] init];
                                                                   controller.mailComposeDelegate = self;
                                                                   [controller setSubject:@"Diagram test"];
                                                                   //[controller setMessageBody:@"Hello there." isHTML:NO];
                                                                   [controller setMessageBody:txt isHTML:NO];
                                                                   [self presentViewController:controller animated:YES completion:nil];
                                                               }else{
                                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                                   message:@"There are no components"
                                                                                                                  delegate:self
                                                                                                         cancelButtonTitle:@"OK"
                                                                                                         otherButtonTitles:nil];
                                                                   [alert show];
                                                               }
                                                               
                                                           }else{
                                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                               message:@"Email cannot be sent. Remenber to configure your mail account on device configuration"
                                                                                                              delegate:self
                                                                                                     cancelButtonTitle:@"OK"
                                                                                                     otherButtonTitles:nil];
                                                               [alert show];
                                                           }
                                                           
                                                           
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
        popover.sourceView = saveDiagram;
        popover.sourceRect = saveDiagram.frame;
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
    
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&jsonError];
    
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
    
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if(jsonError == nil){
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
             
             
             
             //NSDictionary * errorDic = [dic objectForKey:@"error"];
             NSString * code = [dic objectForKey:@"code"];
             
             
             if([code isEqualToString:@"200"]){ //Good :)
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                                 message:@"Diagram saved on server"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
             }else if([code isEqualToString:@"300"]){
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"There is a diagram with that name on server. Please retry with another name"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }else{//Default error
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
    filePath = [filePath stringByAppendingString:@".demiso"];
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
    
    //Remove <xml line from graphicR
    NSArray * graphicRParts = [dele.graphicRContent componentsSeparatedByString:@"\n"];
    NSString * grRToWrite = @"";
    for(int i = 1; i< graphicRParts.count; i++){
        NSString * str = graphicRParts[i];
        grRToWrite = [grRToWrite stringByAppendingString:str];
    }
    
    //Remove <xml line from ecore
    NSString * ecoreToWrite = @"";
    NSArray * ecoreParts = [dele.ecoreContent componentsSeparatedByString:@"\n"];
    for(int i = 1; i< ecoreParts.count; i++){
        NSString * str = ecoreParts[i];
        ecoreToWrite = [ecoreToWrite stringByAppendingString:str];
    }
    
    
    
    //Generate XML
    XMLWriter * writer = [[XMLWriter alloc] init];
    //[writer writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    
    /*  DIAGRAM   */
    [writer writeStartElement:@"diagram"];
    
    [writer writeStartElement:@"palette_name"];
    [writer writeAttribute:@"name" value: dele.currentPaletteFileName];
    [writer writeEndElement];
    
    [writer writeStartElement:@"subpalette"];
    [writer writeAttribute:@"name" value: dele.subPalette];
    [writer writeEndElement];
    
    
    [writer writeStartElement:@"nodes"];
    Component * temp = nil;
    for(int i = 0; i< dele.components.count; i++){
        temp = [dele.components objectAtIndex:i];
        [writer writeStartElement:@"node"];
        
        //[writer writeAttribute:@"shape_type" value:temp.shapeType];
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
            //[writer writeAttribute:@"default_value" value:ca.defaultValue];
            if(ca.currentValue != nil)
                [writer writeAttribute:@"current_value" value:ca.currentValue];
            else
                [writer writeAttribute:@"current_value" value:@""];
            
            //[writer writeAttribute:@"max" value:[ca.max description]];
            //[writer writeAttribute:@"min" value:[ca.min description]];
            //[writer writeAttribute:@"type" value:ca.type];
            [writer writeEndElement];
        }
        [writer writeEndElement];
        
    }
    [writer writeEndElement];//Close nodes
    
    

    
    [writer writeStartElement:@"edges"];
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
    
    //Write chat inside the diagram
    if (dele.messagesArray != nil && dele.messagesArray.count > 0){
        [writer writeStartElement:@"chat"];
        
        for(Message * msg in dele.messagesArray){
            [writer writeStartElement:@"msg"];
            [writer writeAttribute:@"who" value:msg.who.displayName];
            [writer writeAttribute:@"date" value:[msg.date description]];
            [writer writeAttribute:@"content" value:msg.content];
            [writer writeEndElement];
        }
        //Close chat
        [writer writeEndElement];
    }
    
    
    //Save notes
    if (dele.notesArray != nil && dele.notesArray.count > 0){
        [writer writeStartElement:@"notes"];
        
        for(Alert * al in dele.notesArray){

            [writer writeStartElement:@"note"];
            [writer writeAttribute:@"who" value:al.who.displayName];
            [writer writeAttribute:@"date" value:[al.date description]];
            
            if(al.text != nil)
                [writer writeAttribute:@"content" value:al.text];
            
            [writer writeAttribute:@"x" value:[[NSNumber numberWithInt:(int)al.center.x]description]];
            [writer writeAttribute:@"y" value:[[NSNumber numberWithInt:(int)al.center.y]description]];
            [writer writeAttribute:@"associated_node_id" value:[[NSNumber numberWithInt:(int)al.associatedComponent]description]];
            if(al.attach != nil)
                [writer writeAttribute:@"attach" value:[AppDelegate getBase64StringFromImage:al.attach]];
            [writer writeEndElement];
        }
        //Close chat
        [writer writeEndElement];
    }
    
    //Save drawns
    if(dele.drawnsArray != nil && dele.drawnsArray.count > 0){
        [writer writeStartElement:@"drawns"];
        for(DrawnAlert * da in dele.drawnsArray){
            
            [writer writeStartElement:@"drawn"];
            [writer writeAttribute:@"who" value:da.who.displayName];
            [writer writeAttribute:@"date" value:[da.date description]];
            [writer writeAttribute:@"color" value:[ColorPalette hexStringForColor:da.color]];
            [writer writeAttribute:@"id" value:[NSString stringWithFormat:@"%d", da.identifier]];
        
            
            [writer writeStartElement:@"path"];
            NSArray * parts = [self getPointsArrayFromUIBezierPath:da.path];
            
            for(int k = 0; k< parts.count; k++){
                PathPiece * pp = parts[k];
                //NSValue * val = points[k];
                NSString * type = pp.type;
                CGPoint p = pp.point;
                
                [writer writeStartElement:@"p"];
                [writer writeAttribute:@"x" value:[NSString stringWithFormat:@"%.3f", p.x]];
                 [writer writeAttribute:@"y" value:[NSString stringWithFormat:@"%.4f", p.y]];
                [writer writeAttribute:@"type" value:type];
                [writer writeEndElement];
            }
            [writer writeEndElement];//Close path points
            
            [writer writeEndElement];
        }
        [writer writeEndElement];
    }

    
    [writer writeEndElement];//Close diagram
    


    
    NSString * diagramString = [writer toString];

    
    NSString * result = @""; //result = [result stringByAppendingString:@""];
    result = [result stringByAppendingString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    result = [result stringByAppendingString:@"<diagrameditor>"];
    
    //GraphicR
    result = [result stringByAppendingString:@"<graphicr>"];
    result = [result stringByAppendingString:grRToWrite];
    result = [result stringByAppendingString:@"</graphicr>"];
    
    //Diagram
    result = [result stringByAppendingString:@"\n"];
    result = [result stringByAppendingString:diagramString];
    result = [result stringByAppendingString:@"\n"];
    
    //Ecore
    result = [result stringByAppendingString:@"<metamodel>"];
    result = [result stringByAppendingString:ecoreToWrite];
    result = [result stringByAppendingString:@"</metamodel>"];
    
    result = [result stringByAppendingString:@"</diagrameditor>"];
    
    return result;
}


- (IBAction)willChangePalette:(id)sender {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Attention"
                                  message:@"You are about to change te palette. \nUnsaved changes will be lost. \nAre you sure?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    dele.currentPaletteFileName = nil;
                                    [dele.components removeAllObjects];
                                    [dele.connections removeAllObjects];
                                    
                                    for(Alert * al in dele.notesArray){
                                        [al removeFromSuperview];
                                    }
                                    [dele.notesArray removeAllObjects];
                                    [dele.drawnsArray removeAllObjects];
                                    
                                    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
                                    
                                    [dele.manager.session disconnect];
                                    
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                    
                                    [[NSNotificationCenter defaultCenter]postNotificationName:@"closeSubPalette" object:nil];
                                    
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    
    [self presentViewController:alert animated:YES completion:nil];

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
                                                           
                                                           if(dele.components.count >  0){
                                                               
                                                               if ([MFMailComposeViewController canSendMail]) {
                                                                   if(controller == nil)
                                                                       controller = [[MFMailComposeViewController alloc] init];
                                                                   controller.mailComposeDelegate = self;
                                                                   [controller setSubject:@"Digram image text"];
                                                                   [controller addAttachmentData:data mimeType:@"image/png" fileName:@"photo"];
                                                                   [self presentViewController:controller animated:YES completion:nil];
                                                               }else{
                                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                                   message:@"Email cannot be sent. Remenber to configure your mail account on device configuration"
                                                                                                                  delegate:self
                                                                                                         cancelButtonTitle:@"OK"
                                                                                                         otherButtonTitles:nil];
                                                                   [alert show];
                                                               }
                                                               
                                                               
                                                           }else{
                                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                                                                               message:@"Email cannot be sent due to there are no components."
                                                                                                              delegate:self
                                                                                                     cancelButtonTitle:@"OK"
                                                                                                     otherButtonTitles:nil];
                                                               [alert show];
                                                           }
                                                           
                                                           
                                                       }];
    
    UIAlertAction * saveondevice = [UIAlertAction actionWithTitle:@"Save on camera roll"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self saveImageOnCameraRoll:finalImage];
                                                          }];
    UIAlertAction * postTwitter = [UIAlertAction actionWithTitle:@"Post on Twitter"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self postTweet:finalImage];
                                                          }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    
    [ac addAction:sendemail];
    [ac addAction:saveondevice];
    [ac addAction:postTwitter];
    [ac addAction:cancel];
    
    
    UIPopoverPresentationController * popover = ac.popoverPresentationController;
    if(popover){
        popover.sourceView = cameraOutlet;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}

-(void)postTweet:(UIImage *)image{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweet setInitialText:@"I just edited a new model"];
        [tweet addImage:image];
        [tweet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             if (result == SLComposeViewControllerResultCancelled)
             {
                 NSLog(@"The user cancelled.");
             }
             else if (result == SLComposeViewControllerResultDone)
             {
                 NSLog(@"The user sent the tweet");
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                                 message:@"Tweet sent"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         }];
        [self presentViewController:tweet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                        message:@"Twitter integration is not available.  A Twitter account must be set up on your device."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
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
    //[palette setContentOffset:CGPointMake(slider.value,0) animated:NO];
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



#pragma mark ShareThisDiagram
- (IBAction)openSessionThisDiagram:(id)sender {
    
    [self presentViewController:dele.manager.browser animated:YES completion:nil];
    
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [dele.manager.session disconnect];
    [dele.manager.browser dismissViewControllerAnimated:YES completion:nil];
    sharingDiagram = NO;
    
    [resendTimer invalidate];
    resendTimer = nil;
    
    [showUsersPeersViewButton setHidden:YES];
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    
    [chatButton setFrame:CGRectMake(scrollView.frame.size.width+scrollView.frame.origin.x - chatButton.frame.size.width,
                                    scrollView.frame.origin.y,
                                    chatButton.frame.size.width,
                                    chatButton.frame.size.height)];
    [askForMasterButton setHidden:YES]; //I will be the first master
    [chatButton setHidden:NO];
    
    [dele.manager.browser dismissViewControllerAnimated:YES completion:nil];
    [usersListView removeFromSuperview];
    
    [showUsersPeersViewButton setHidden:NO];
    
    usersListView = [[[NSBundle mainBundle]loadNibNamed:@"SessionUsersView"
                                                  owner:self
                                                options:nil]objectAtIndex:0];
    
    /*[usersListView setFrame:CGRectMake(0,
     0,
     sessionListContainer.frame.size.width,
     sessionListContainer.frame.size.height)];*/
    
    
    [usersListView prepare];
    
    
    //[sessionListContainer addSubview:usersListView];
    
    sharingDiagram = YES;
    
    resendTimer = [NSTimer scheduledTimerWithTimeInterval:resendTime
                                                   target:self
                                                 selector:@selector(resendInfo)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:resendTimer forMode:NSRunLoopCommonModes];
    
    
    pingTimer = [NSTimer scheduledTimerWithTimeInterval:pingTime
                                                 target:self
                                               selector:@selector(sendPing)
                                               userInfo:nil
                                                repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:pingTimer forMode:NSRunLoopCommonModes];
    
    
    //Set that I'm the server
    dele.serverId = [[PeerInfo alloc] init];
    dele.serverId.peerUUID = dele.myPeerInfo.peerUUID;
    dele.serverId.peerID =  dele.myPeerInfo.peerID ;
    
    //Set that I'm the first master
    dele.currentMasterId = [[PeerInfo alloc] init];
    dele.currentMasterId.peerUUID = dele.myPeerInfo.peerUUID;
    dele.currentMasterId.peerID = dele.myPeerInfo.peerID ;
    
    
    //Send initial info
    
    NSMutableDictionary * dicToSend = [[NSMutableDictionary alloc] init];
    
    
    
    NSData * deleData  =[dele packAppDelegate];
    
    [dicToSend setObject:deleData forKey:@"data"];
    [dicToSend setObject:kInitialInfoFromServer forKey:@"msg"];
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dicToSend];
    
    
    NSError * error = nil;
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
    
    
    
    //Prepare chat
    if(dele.chat == nil){
        dele.chat = [[[NSBundle mainBundle] loadNibNamed:@"ChatView"
                                                   owner:self
                                                 options:nil] objectAtIndex:0];
        
        [dele.chat prepare];
        dele.chat.parent = self;
    }
    
    /*NSData * appDeleData = [dele packImportantInfo];
     
     [dele.output write:appDeleData.bytes maxLength:appDeleData.length];*/
    
    
    
    //Assign colors. Remove this to all black
    [self assignColors];
}

-(void)sendPing{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:kPing forKey:@"msg"];
    NSError * error = nil;
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
}

-(void)assignColors{
    NSMutableArray * array = [ColorPalette colorArray];
    dele.myColor = array[0];
    
    for(int i = 0; i< dele.manager.session.connectedPeers.count; i++){
        UIColor * colorToSend = array[i+1];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:kNewColor forKey:@"msg"];
        [dic setObject:colorToSend forKey:@"color"];
        [dic setObject:dele.manager.session.connectedPeers[i] forKey:@"who"];
        
        
        NSError * error = nil;
        
        NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [dele.manager.session sendData:allData
                               toPeers:dele.manager.session.connectedPeers
                              withMode:MCSessionSendDataReliable
                                 error:&error];
    }
}

-(void)sendMasterInfo{
    
    NSData * appDeleData = [dele packElementsInfo];
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:appDeleData forKey:@"data"];
    [dic setObject:kNewMasterData forKey:@"msg"];
    //Only servr should receive this
    
    NSError * error = nil;
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
}


-(void)resendInfo{
    //NSLog(@"resend");
    NSData * appDeleData = [dele packElementsInfo];
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:appDeleData forKey:@"data"];
    [dic setObject:kUpdateData forKey:@"msg"];
    
    NSError * error = nil;
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
}


#pragma mark Expand-Collapse palette methods
- (IBAction)expandOrCollapsePalette:(id)sender {
    if(isPaletteCollapsed){ //Palette is hidden, expand it
        [self expandPalette];
        isPaletteCollapsed = NO;
        UIImage *image = [UIImage imageNamed:@"hidePaletteEditor.png"];
        [showHidePaletteOutlet setImage:image forState:UIControlStateNormal];
    }else{ //Palette is shown, collapse it
        [self collapsePalette];
        isPaletteCollapsed = YES;
        UIImage *image = [UIImage imageNamed:@"showPaletteEditor.png"];
        [showHidePaletteOutlet setImage:image forState:UIControlStateNormal];
    }
}

- (IBAction)iWantToBeTheNewMaster:(id)sender {
    
    if([dele amITheServer]){
        //Make myself the master
        dele.currentMasterId.peerID = dele.myPeerInfo.peerID;
        
        //Preparar los componentes
        
        for(Component * c in dele.components){
            [c prepare];
        }
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"You are the master now"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [askForMasterButton setHidden:YES];
        [chatButton setHidden:NO];
    }else{
        NSError * error = nil;
        // NSArray * peers = [[NSArray alloc] initWithObjects:dele.manager, nil];
        
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:dele.myPeerInfo.peerID forKey:@"peerID"];
        [dic setObject:kIWantToBeMaster forKey:@"msg"];
        
        NSLog(@"I will ask to be the new master");
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
        
        [dele.manager.session sendData:data
                               toPeers:dele.manager.session.connectedPeers
                              withMode:MCSessionSendDataReliable error:&error];
        
        if(error != nil){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }else{
            
        }
    }
    
    
}

- (IBAction)showUsersList:(id)sender {
    [usersListView setFrame:self.view.frame];
    [self.view addSubview:usersListView];
}

#pragma mark Alert buttons

- (IBAction)showPossibleAlerts:(id)sender {
    if(showingPossibleAlerts == YES){ //Hide them
        [self hideAlerts];
    }else{ //They are hidden, show them
        [self showAlerts];
    }
}

- (IBAction)showChat:(id)sender {
    /*if(dele.chat == nil){
     dele.chat = [[[NSBundle mainBundle] loadNibNamed:@"ChatView"
     owner:self
     options:nil] objectAtIndex:0];
     
     [dele.chat prepare];
     }*/
    
    //Show
    [dele.chat setFrame:self.view.frame];
    [self.view addSubview:dele.chat];
}

#pragma mark Alerts and notes
-(void)showAlerts{
    //Do animations
    
    [exclamationAlert setCenter:alertsCenter];
    [interrogationAlert setCenter:alertsCenter];
    [drawAlert setCenter:alertsCenter];
    [noteAlert setCenter:alertsCenter];
    //[arrowAlert setCenter:alertsCenter];
    
    [UIView animateWithDuration:alertsAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [exclamationAlert setHidden:NO];
                         [exclamationAlert setCenter:exclamationCenter];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:alertsAnimationDuration
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              [interrogationAlert setHidden:NO];
                                              [interrogationAlert setCenter:interrogationCenter];
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:alertsAnimationDuration
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   [noteAlert setHidden:NO];
                                                                   [noteAlert setCenter:noteCenter];
                                                                   
                                                               } completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:alertsAnimationDuration
                                                                                         delay:0.0
                                                                                       options:UIViewAnimationOptionCurveEaseOut
                                                                                    animations:^{
                                                                                        [drawAlert setHidden:NO];
                                                                                        [drawAlert setCenter:drawCenter];
                                                                                        
                                                                                    } completion:^(BOOL finished) {
                                                                                        showingPossibleAlerts = YES;
                                                                                        
                                                                                        [self showAnotations];
                                                                                    }];
                                                               }];
                                          }];
                     }];
    
    
    
    
    
    
}

-(void)hideAlerts{
    //Do animations
    [UIView animateWithDuration:alertsAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [drawAlert setCenter:alertsCenter];
                         //[arrowAlert setCenter:alertsCenter];
                     } completion:^(BOOL finished) {
                         [drawAlert setHidden:YES];
                         
                         [UIView animateWithDuration:alertsAnimationDuration
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              [noteAlert setCenter:alertsCenter];
                                              
                                          } completion:^(BOOL finished) {
                                              [noteAlert setHidden:YES];
                                              
                                              [UIView animateWithDuration:alertsAnimationDuration
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   
                                                                   [interrogationAlert setCenter:alertsCenter];
                                                               } completion:^(BOOL finished) {
                                                                   [interrogationAlert setHidden:YES];
                                                                   [UIView animateWithDuration:alertsAnimationDuration
                                                                                         delay:0.0
                                                                                       options:UIViewAnimationOptionCurveEaseOut
                                                                                    animations:^{
                                                                                        
                                                                                        [exclamationAlert setCenter:alertsCenter];
                                                                                    } completion:^(BOOL finished) {
                                                                                        [exclamationAlert setHidden: YES];
                                                                                        showingPossibleAlerts = NO;
                                                                                        
                                                                                        [self hideAnotations];
                                                                                    }];
                                                               }];
                                          }];
                         
                     }];
    
}

-(void)handleAlertPan:(UIPanGestureRecognizer *)recog{
    UIImageView * view = (UIImageView* )recog.view;
    
    CGPoint point = [recog locationInView:self.view];
    
    
    if(recog.state == UIGestureRecognizerStateBegan){
        UIImage * image = [view.image copy];
        temporalAlertIcon = [[UIImageView alloc] initWithFrame:view.frame ];
        temporalAlertIcon.image = image;
        temporalAlertIcon.center = point;
        [self.view addSubview:temporalAlertIcon];
    }else if(recog.state == UIGestureRecognizerStateChanged){
        [temporalAlertIcon setCenter:point];
    }else if(recog.state == UIGestureRecognizerStateEnded){
        
        [temporalAlertIcon removeFromSuperview];
        CGPoint pointInSV = [self.view convertPoint:point toView:canvas];
        temporalAlertIcon = nil;
        
        if(recog.view == noteAlert){
            CreateNoteView * cnv =  [[[NSBundle mainBundle] loadNibNamed:@"CreateNoteView"
                                                                                      owner:self
                                                                                    options:nil] objectAtIndex:0];
            [cnv setFrame: self.view.frame];
            cnv.parentVC = self;
            cnv.delegate = self;
            cnv.noteCenter = pointInSV;
            [self.view addSubview:cnv];
            
        }else{
            [self sendAlert:view onPoint:pointInSV];
        }
        
    }
    
}

-(void)sendNote:(Alert *)alert
        onPoint:(CGPoint)point{
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:kNewAlert forKey:@"msg"];
    
    [dic setObject:dele.myPeerInfo.peerID forKey:@"who"];
    NSValue * val = [NSValue valueWithCGPoint:point];
    [dic setObject:val forKey:@"where"];
    
    
    [dic setObject:alert forKey:@"note"];
    [dic setObject:kNoteType forKey:@"alertType"];
    
    
    UITapGestureRecognizer * showNotecontent = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(showNoteContent:)];
    [alert addGestureRecognizer:showNotecontent];
    [alert setUserInteractionEnabled:YES];
    
    
    UIPanGestureRecognizer * notePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleNotePan:)];
    [alert addGestureRecognizer:notePanGesture];
    
    if(useImageAsIcon == YES){
        if(alert.attach != nil)
            alert.image = alert.attach;
        else{
            alert.image = noteAlert.image;
        }
    }else{
        alert.image = noteAlert.image;
    }
    
    CGRect  new = alerts.frame;
    new.size.width = new.size.width * 1.5;
    new.size.height = new.size.height * 1.5;
    [alert setBounds:new];
    
    //Add note to myself
    [canvas addSubview:alert];
    [dele.notesArray addObject:alert];
    
    
    NSError * error = nil;
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
    
    if(error != nil){
        NSLog(@"ERROR SENDING ALERT");
    }
}

-(void)handleNotePan:(UIPanGestureRecognizer *)recog{
    
    UIView * sender = recog.view;
    
    CGPoint point = [recog locationInView:self.view];
    CGPoint pointInSV = [self.view convertPoint:point toView:canvas];
    
    if(recog.state == UIGestureRecognizerStateBegan){
        
    }else if(recog.state == UIGestureRecognizerStateChanged){
        [sender setCenter:pointInSV];
    }else if(recog.state == UIGestureRecognizerStateEnded){
        
    }
    
    [canvas setNeedsDisplay];
}


-(void)sendAlert:(UIImageView *)view
         onPoint:(CGPoint)point{
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:kNewAlert forKey:@"msg"];
    
    [dic setObject:dele.myPeerInfo.peerID forKey:@"who"];
    [dic setObject:kNoteType forKey:@"alertType"];
    
    
    
    
    if(view == exclamationAlert){
        [dic setObject:kExclamation forKey:@"alertType"];
    }else if(view == interrogationAlert){
        [dic setObject:kInterrogation forKey:@"alertType"];
    }else if(view == noteAlert){
        [dic setObject:kNoteType forKey:@"alertType"];
        [dic setObject:tempNoteContent forKey:@"noteText"];
        
    }
    NSValue * val = [NSValue valueWithCGPoint:point];
    [dic setObject:val forKey:@"where"];
    

    
    Alert * alert = [[Alert alloc] init];
    alert.frame = alerts.frame;
    alert.center  = point;
    alert.text = tempNoteContent;
    alert.date = [NSDate date];
    alert.who = dele.myPeerInfo.peerID;
    alert.identifier = (int)alert;
    //alert.image = noteAlert.image;
    
    if(view == exclamationAlert){
        alert.image = exclamationAlert.image;
    }else if(view == interrogationAlert){
        alert.image = interrogationAlert.image;
    }else if(view == noteAlert){
        alert.image = noteAlert.image;
    }
    
    UITapGestureRecognizer * showNotecontent = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(showNoteContent:)];
    [alert addGestureRecognizer:showNotecontent];
    [alert setUserInteractionEnabled:YES];
    
    [canvas addSubview:alert];
    [dele.notesArray addObject:alert];
    
    //Add self destruct
    NSMutableDictionary * whatView = [[NSMutableDictionary alloc] init];
    [whatView setObject:alert forKey:@"view"];
    
    NSTimer * removeTimer;
    
    if(view != noteAlert){
        
        removeTimer = [NSTimer scheduledTimerWithTimeInterval:stayAlertTime
                                                       target:self
                       
                                                     selector:@selector(removeAlert:)
                                                     userInfo:whatView
                                                      repeats:NO];
        
        [[NSRunLoop mainRunLoop]addTimer:removeTimer forMode:NSRunLoopCommonModes];
    }
    tempNoteContent = nil;
    
    NSError * error = nil;
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
    
    if(error != nil){
        NSLog(@"ERROR SENDING ALERT");
    }
}

-(void)handleNewAlert:(NSNotification *)not{
    NSDictionary * dic = [not userInfo];
    
    NSValue * whereVal = [dic objectForKey:@"where"];
    CGPoint where = [whereVal CGPointValue];
    
    MCPeerID * who = [dic objectForKey:@"who"];
    whoSendTheNote = who;
    
    
    NSString * type = [dic objectForKey:@"alertType"];
    
    Alert * alert = nil;
    
    alert = [dic objectForKey:@"note"];
    
    CGRect  new = alerts.frame;
    new.size.width = new.size.width * 1.5;
    new.size.height = new.size.height * 1.5;

    
    if(alert == nil){
        alert = [[Alert alloc] init];
        
    }
    [alert setFrame:new];
    [alert setCenter:where];

    
    if([type isEqualToString:kNoteType]){
        
        
        if(useImageAsIcon == YES){
            if(alert.attach != nil)
                alert.image = alert.attach;
            else{
                alert.image = noteAlert.image;
            }
        }else{
            alert.image = noteAlert.image;
        }
        
        [alert setUserInteractionEnabled:YES];
        UITapGestureRecognizer * showNotecontent = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(showNoteContent:)];
        [alert addGestureRecognizer:showNotecontent];
        //alert.text = [dic objectForKey:@"noteText"];
        
        
    }else if([type isEqualToString:kInterrogation]){
        //imageView.image = interrogationAlert.image;
        alert.image = interrogationAlert.image;
    }else if([type isEqualToString:kExclamation]){
        //imageView.image = exclamationAlert.image;
        alert.image = exclamationAlert.image;
    }
    
    
    //[canvas addSubview:imageView];
    [canvas addSubview:alert];
    
    [dele.notesArray addObject:alert];
    
    
    NSMutableDictionary * whatView = [[NSMutableDictionary alloc] init];
    [whatView setObject:alert forKey:@"view"];
    
    NSTimer * removeTimer;
    
    if(![type isEqualToString:kNoteType]){
        removeTimer = [NSTimer scheduledTimerWithTimeInterval:stayAlertTime
                                                       target:self
                       
                                                     selector:@selector(removeAlert:)
                                                     userInfo:whatView
                                                      repeats:NO];
        
        [[NSRunLoop mainRunLoop]addTimer:removeTimer forMode:NSRunLoopCommonModes];
    }
    
    
}

-(void)showNoteContent:(UITapGestureRecognizer *)recog{
    
    
    Alert * sender = (Alert *)recog.view;
    
    NoteView * nv = [[[NSBundle mainBundle] loadNibNamed:@"NoteView"
                                                   owner:self
                                                 options:nil] objectAtIndex:0];
    [nv setFrame:self.view.frame];
    
    nv.content = sender.text;
    nv.whoLabel.text = sender.who.displayName;
    nv.preview = sender.attach;
    nv.associatedNote = sender;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    
    
    NSDate * dateToParse = sender.date;

    nv.dateLabel.text = [dateFormat stringFromDate:dateToParse];
    
    [nv prepare];

    [self.view addSubview:nv];
    [dele.notesArray addObject:sender];
}

-(void)removeAlert: (NSTimer * )sender{
    NSDictionary * dic = sender.userInfo;
    
    UIImageView * view = [dic objectForKey:@"view"];
    
    [view removeFromSuperview];
    
    [sender invalidate];
    sender = nil;
}

#pragma mark Collapse or showing palette
-(void)collapsePalette{
    
    
    [palette setHidden:YES];
}

-(void)expandPalette{
    
    //[palette setAlpha:1.0];
    [showHidePaletteOutlet setEnabled:NO];
    [palette setFrame:CGRectMake(paletteRect.origin.x,
                                 paletteRect.origin.y,
                                 0,
                                 paletteRect.size.height)];
    
    [palette setHidden:NO];
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         CGRect newRect = CGRectMake(paletteRect.origin.x,
                                                     paletteRect.origin.y,
                                                     paletteRect.size.width,
                                                     paletteRect.size.height);
                         [palette setFrame:newRect];
                         
                         paletteRect = newRect;
                     }
                     completion:^(BOOL finished) {
                         [showHidePaletteOutlet setEnabled:YES];
                     }];
    
}

-(void)fitPaletteToScreen{
    float m = 5;
    float bm = 10;
    
    float pw = canvas.frame.size.width - 2 * m - showHidePaletteOutlet.frame.size.width -bm;
    float px = canvas.frame.origin.x;
    float py = canvas.frame.size.height - palette.frame.size.height + canvas.frame.origin.y;
    float ph = palette.frame.size.height;
    
    [palette setFrame:CGRectMake(px, py, pw, ph)];
}

#pragma mark CreateNoteView delegate methods
-(void)createNoteViewDidCancel{
    
}

-(void)createNoteViewConfirmWithText:(NSString *)text
                            andImage:(UIImage *)image
                             onPoint:(CGPoint)point{
    
    Alert * alert = [[Alert alloc] init];
    //alert.frame = alerts.frame;
    //alert.center  = point;
    [alert setFrame:CGRectMake(point.x -alert.bounds.size.width/2,
                               point.y -alert.bounds.size.height/2,
                               alert.bounds.size.width,
                               alert.bounds.size.height)];
    alert.text = text;
    alert.date = [NSDate date];
    alert.who = dele.myPeerInfo.peerID;
    alert.attach = image;
    alert.identifier = (int)alert;
    
    //Check if there is a component on this position
    for(Component * comp in dele.components){
        if(CGRectContainsPoint(comp.frame, point)){
            //Make that connection
            alert.associatedComponent = comp;
        }
    }
    
    
    [self sendNote:alert onPoint:point];
}

#pragma mark DrawingViewDelegate methods
-(void)drawingViewDidCancel{
    
}
-(void)drawingViewDidCloseWithPath:(UIBezierPath *)path{

    DrawnAlert * da = [[DrawnAlert alloc] init];
    da.who = dele.myPeerInfo.peerID;
    da.date = [NSDate date];
    da.path = path;
    da.color = dele.myColor;
    da.identifier = (int)da;
    
    [dele.drawnsArray addObject:da];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:nil];
    
    
    //Send drawn to users
    
   
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:da forKey:@"drawn"];
    [dic setObject:kNewDrawn forKey:@"msg"];
    [dic setObject:dele.myPeerInfo.peerID forKey:@"who"];
    
    
    NSError * error = nil;
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
}

#pragma mark Show or hide annotations and drawings
-(void)hideAnotations{
    
    for(Alert * al in dele.notesArray){
        [al setHidden:YES];
    }
    dele.showingAnnotations = NO;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:nil];
}

-(void)showAnotations{
    dele.showingAnnotations = YES;
    for(Alert * al in dele.notesArray){
        [al setHidden:NO];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:nil];
}

#pragma mark Get point array from UIBezierPath
-(NSMutableArray *)getPointsArrayFromUIBezierPath:(UIBezierPath *)path{
    NSMutableArray * pieces = [[NSMutableArray alloc] init];

    CGPathRef thecg = path.CGPath;
    CGPathApply(thecg, (__bridge void * _Nullable)(pieces), MyCGPathApplierFunc);
    
    return pieces;
}

void MyCGPathApplierFunc (void *info, const CGPathElement *element) {
    
    
    
    NSMutableArray *pieces = (__bridge NSMutableArray *)info;
    
    CGPoint *points = element->points;
    PathPiece * pp = [[PathPiece alloc] init];
    pp.point = points[0];
    
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            pp.type = CGPathElementMoveToPoint;
            break;
        case kCGPathElementAddLineToPoint:
            pp.type = CGPathElementAddLineToPoint;
            break;
            
        case kCGPathElementCloseSubpath:
            pp.type = CGPathElementCloseSubpath;
            break;
            
        default:
            break;
    }
    [pieces addObject:pp];
    //[pieces addObject:[NSValue valueWithCGPoint:points[0]]];
    
}


#pragma mark Editor tutorial methods
-(void)startEditorTutorial{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:blurEffectView];
    
    
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Great!"
                                  message:@"Now you are on the editor view. Let's take and eye here."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Let's go"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    //[self showAndDisablePaletteFileGroup];
                                    [self focusCanvas];
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)focusCanvas{
    [self.view bringSubviewToFront:scrollView];
    dele.tutSheet = [[[NSBundle mainBundle]loadNibNamed:@"TutorialSheet"
                                                  owner:self
                                                options:nil]objectAtIndex:0];
    
    originalSheetWidth = dele.tutSheet.frame.size.width;
    originalSheetHeight = dele.tutSheet.frame.size.height;
    [dele.tutSheet.textView setText:@"This is the main canvas. Instances will be created here but now it's empty (Try this by doing scroll)\nTap here to continue..."];
    CGFloat fixedWidth = dele.tutSheet.textView.frame.size.width -40;
    CGSize newSize = [dele.tutSheet.textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    [dele.tutSheet setFrame:CGRectMake(self.view.center.x - dele.tutSheet.frame.size.width/2,
                                       0,
                                       dele.tutSheet.frame.size.width,
                                       newSize.height +10)];
    [self.view addSubview:dele.tutSheet];
    
    
    UITapGestureRecognizer * focusCollapseButton = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(bringCollapseButtonToFront:)];
    [dele.tutSheet addGestureRecognizer:focusCollapseButton];
}

-(void)bringCollapseButtonToFront:(UITapGestureRecognizer *)recog{
    [dele.tutSheet removeGestureRecognizer:recog];
    
    [self.view bringSubviewToFront:showHidePaletteOutlet];
    [self.view bringSubviewToFront:palette];
    
    
    
    [dele.tutSheet.textView setText:@"The \"+\" button at the down left corner will show or hide the selected palette.\nGive it a try and tap here to continue..."];
    CGFloat fixedWidth = dele.tutSheet.textView.frame.size.width ;
    CGSize newSize = [dele.tutSheet.textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    [dele.tutSheet setFrame:CGRectMake(self.view.center.x - dele.tutSheet.frame.size.width/2,
                                       0,
                                       dele.tutSheet.frame.size.width,
                                       newSize.height +10)];
    
    UITapGestureRecognizer * showItemsInfoGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(showPaletteItemsInfo:)];
    [dele.tutSheet addGestureRecognizer:showItemsInfoGR];
}

-(void)showPaletteItemsInfo:(UITapGestureRecognizer *)recog{
    NSString * text = @"Each palette can contains two main types of objects, Nodes and Edges.\n"
    "At the same time, a node can be draggable \u270B and no draggable \u261D\n"
    "A draggable node will be instanciated by drag & drop from the palette.\n"
    "A No draggable node has to be instanciated by tapping his icon.\n"
    "Give it a try and tap here to continue...";
    [dele.tutSheet.textView setText:text];
    CGFloat fixedWidth = dele.tutSheet.textView.frame.size.width;
    CGSize newSize = [dele.tutSheet.textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    [dele.tutSheet setFrame:CGRectMake(self.view.center.x - dele.tutSheet.frame.size.width/2,
                                       0,
                                       dele.tutSheet.frame.size.width,
                                       newSize.height +10)];
    
    UITapGestureRecognizer * showAlertsGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(focusAlerts:)];
    [dele.tutSheet addGestureRecognizer:showAlertsGR];
}


-(void) focusAlerts:(UITapGestureRecognizer *)recog{
    [dele.tutSheet removeGestureRecognizer:recog];
    
    for(UIGestureRecognizer * gr in dele.tutSheet.gestureRecognizers){
        [dele.tutSheet removeGestureRecognizer:gr];
    }
    
    
    [self.view bringSubviewToFront:alerts];
    [self.view bringSubviewToFront:interrogationAlert];
    [self.view bringSubviewToFront:exclamationAlert];
    [self.view bringSubviewToFront:noteAlert];
    [self.view bringSubviewToFront:drawAlert];
    
    [self showAlerts];
    
    NSString * text = @"This has just appeared is the alert tool.\n"
    "\"?\" and \"!\" can be dragged from this tool to canvas. This will create an alert at this point that will dissapear after 5 seconds.\n"
    "Third icon is a note. Try to drag one from the tool to the canvas. Notes can hold text and images.\n"
    "By tapping the last icon (the pencil) will show you the drawing tool. Use this to make handmade forms.\n"
    "Tap here to continue...";
    [dele.tutSheet.textView setText:text];
    CGFloat fixedWidth = dele.tutSheet.textView.frame.size.width;
    CGSize newSize = [dele.tutSheet.textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    [dele.tutSheet setFrame:CGRectMake(alerts.frame.size.width + alerts.frame.origin.x + 10,
                                       alerts.frame.origin.y,
                                       dele.tutSheet.frame.size.width - 120,
                                       newSize.height +60)];
    
    UITapGestureRecognizer * showMakeConnectionGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(showHowToMakeConnectionsBetweenNodes:)];
    [dele.tutSheet addGestureRecognizer:showMakeConnectionGR];
}

-(void)showHowToMakeConnectionsBetweenNodes:(UITapGestureRecognizer *)recog{
    
    [self hideAlerts];
    
    [self.view sendSubviewToBack:alerts];
    [self.view sendSubviewToBack:interrogationAlert];
    [self.view sendSubviewToBack:exclamationAlert];
    [self.view sendSubviewToBack:noteAlert];
    [self.view sendSubviewToBack:drawAlert];
    
    NSString * text = @"";
    
    [dele.tutSheet.textView setText:text];
    CGFloat fixedWidth = dele.tutSheet.textView.frame.size.width;
    CGSize newSize = [dele.tutSheet.textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    [dele.tutSheet setFrame:CGRectMake(alerts.frame.size.width + alerts.frame.origin.x + 10,
                                       alerts.frame.origin.y,
                                       dele.tutSheet.frame.size.width - 120,
                                       newSize.height +60)];
}


@end
