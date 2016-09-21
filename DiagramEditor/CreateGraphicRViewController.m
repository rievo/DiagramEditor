//
//  CreateGraphicRViewController.m
//  DiagramEditor
//
//  Created by Diego on 12/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "CreateGraphicRViewController.h"
#import "RemovableReference.h"

@interface CreateGraphicRViewController ()

@end

@implementation CreateGraphicRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [createButton setEnabled:NO];
    [textview setEditable:NO];
    
    //[self formGraphicR];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)formGraphicRWithName:(NSString *)name{
    text = @"";
    
    //text = [text stringByAppendingString:@""];
    text = [text stringByAppendingString:@"<?xml version=\"1.0\" encoding=\"ASCII\"?>\n"];
    text = [text stringByAppendingString:@"<graphicR:GraphicRepresentation xmi:version=\"2.0\"\n"];
    text = [text stringByAppendingString:@" xmlns:xmi=\"http://www.omg.org/XMI\" "];
    text = [text stringByAppendingString:@" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "];
    text = [text stringByAppendingString:@" xmlns:graphicR=\"http://mondo.org/graphic_representation/1.0.3\">"];
    
    extension = [_selectedJson.name lowercaseString];
    NSString * fileName =[NSString stringWithFormat:@"%@.ecore", _selectedJson.name];

    
    text = [text stringByAppendingString:[NSString stringWithFormat:@"<allGraphicRepresentation extension=\"%@\">",extension]];
    
    text = [text stringByAppendingString:@"<listRepresentations xsi:type=\"graphicR:RepresentationDD\">"];
    
    text = [text stringByAppendingString:@"<root>"];
    text = [text stringByAppendingString:[NSString stringWithFormat:@"<anEClass href=\"%@#//%@\"/>", fileName, _root.name]];
    text = [text stringByAppendingString:@"</root>"];
    
    text = [text stringByAppendingString:@"<layers xsi:type=\"graphicR:DefaultLayer\" name=\"DefaultLayer\">"];
    
    
    //For each component
    for(int i = 0; i < _visibles.count; i++){
        JsonClass * c = [_visibles objectAtIndex:i];
        
        
        //It is a node or an edge
        if([_nodes containsObject:c]){
            text = [text stringByAppendingString:@"<elements xsi:type=\"graphicR:Node\">"];
        }else{
            text = [text stringByAppendingString:@"<elements xsi:type=\"graphicR:Edge\">"];
        }
        
        
        //Which class?
        text = [text stringByAppendingString:[NSString stringWithFormat:@"<anEClass href=\"%@#//%@\"/>", fileName, c.name]];
        
        //Text on palette
        text = [text stringByAppendingString:[NSString stringWithFormat:@"<diag_palette palette_name=\"Create %@\"/>", c.name]];
        
        //Container reference
        text = [text stringByAppendingString:[NSString stringWithFormat:@"<containerReference href=\"%@#//%@\"/>", fileName, c.containmentReference]];
        
        
        
        
        
        if([_nodes containsObject:c]){ //Node
            Component * associated = (Component *) c.associatedComponent;
            
            
            //Node elements (LabelanEAttribute & LinkPalettes
            text = [text stringByAppendingString:@"<node_elements>"];
            
            //Get label attribute
            for(ClassAttribute * ca in c.attributes){
                if(ca.isLabel == YES){
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"<LabelanEAttribute labelPosition=\"%@\">", @"border"]];
                    
                    text = [text stringByAppendingString:
                            [NSString stringWithFormat:@"<color xsi:type=\"graphicR:SiriusSystemColors\" name=\"%@\"  />\n", @"black"]];
                    
                    text = [text stringByAppendingString:
                            [NSString stringWithFormat:@"<anEAttribute href=\"%@#//%@/%@\" />", fileName, c.name,ca.name]];
                    
                    text = [text stringByAppendingString:@"</LabelanEAttribute>"];
                }
            }
            
            //Now references
            for(RemovableReference * ref in c.references){
                text = [text stringByAppendingString:
                        [NSString stringWithFormat:@"<linkPalette palette_name=\"Create link %@\">", ref.name]];
                
                text = [text stringByAppendingString:[NSString stringWithFormat:@"<anEReference href=\"%@#//%@/%@\"/>",
                                                      fileName,
                                                      c.name, ref.name]];
                
                //TODO: Meter el color de la referencia aquí
                
                text = [text stringByAppendingString:
                        [NSString stringWithFormat:@"<color xsi:type=\"graphicR:SiriusSystemColors\" name=\"%@\"  />\n", ref.color]];
                
                text = [text stringByAppendingString:@"</linkPalette>"];
            }
            
            text = [text stringByAppendingString:@"</node_elements>"];
            
            
            if(associated.shapeType == nil){
                text = [text stringByAppendingString:[NSString stringWithFormat:@"<node_shape xsi:type=\"graphicR:%@\">", @"Ellipse"]];
            }else{
                text = [text stringByAppendingString:[NSString stringWithFormat:@"<node_shape xsi:type=\"graphicR:%@\">", associated.shapeType]];
            }
            
            
            
            text = [text stringByAppendingString:[NSString stringWithFormat:@"<color xsi:type=\"graphicR:SiriusSystemColors\" name=\"%@\"  />\n", associated.colorString]]; //Fill color
            
            text = [text stringByAppendingString:[NSString stringWithFormat:@"<borderColor xsi:type=\"graphicR:SiriusSystemColors\" name=\"%@\"  />\n", associated.borderColorString]]; //Border color
            
            text = [text stringByAppendingString:@"</node_shape>"];
            
        }else{ //Edge
            text = [text stringByAppendingString:@"<edge_style>"];
            text = [text stringByAppendingString:@"</edge_style>"];
        }
        
        
        
        //Close elements
        text = [text stringByAppendingString:@"</elements>"];
    }
    
    text = [text stringByAppendingString:@"</layers>"];
    text = [text stringByAppendingString:@"</listRepresentations>"];
    text = [text stringByAppendingString:@"</allGraphicRepresentation>"];
    text = [text stringByAppendingString:@"</graphicR:GraphicRepresentation>"];
    
    
    [textview setText:text];
    
}


-(void)sendPaletteToServer:(NSString * )content{
    
    
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:content forKey:@"content"];
    [dic setObject:nameTextField.text forKey:@"name"];
    [dic setObject:_selectedJson.uri forKey:@"ecoreURI"];
    [dic setObject:extension forKey:@"extension"];
    [dic setObject:@"2" forKey:@"version"];
    
    
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:&jsonError];
    
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
    
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if(jsonError == nil){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://diagrameditorserver.herokuapp.com/palettes?json=true"]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setTimeoutInterval:5.0];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: data];
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data, NSError *connectionError)
         {
             NSError * error;
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:&error];
             
             
             
             
             NSString * code = [dic objectForKey:@"code"];
             
             
             if([code isEqualToString:@"200"]){ //Good :)
                 goodAlert  = [[UIAlertView alloc] initWithTitle:@"Info"
                                                                 message:@"Palette saved on server"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [goodAlert show];
                 
             }else{//Default error
                 badAlert  = [[UIAlertView alloc] initWithTitle:@"Error uploading palette"
                                                                 message:[NSString stringWithFormat:@"Info: %@", connectionError]
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [badAlert show];
                 
             }
        
            
             
         }];
    }else{
        NSLog(@"Error generating palette json");
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == badAlert){
        
    }else if(alertView == goodAlert){
        [self dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)createAndUploadToServer:(id)sender {
    [self sendPaletteToServer:text];
}

- (IBAction)updateName:(id)sender {
    if(nameTextField.text.length == 0){ //Error
       UIAlertView * alert =  [[UIAlertView alloc] initWithTitle:@"Name cannot be empty"
                                   message:nil
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
    }else{
        [self formGraphicRWithName:nameTextField.text];
        [createButton setEnabled:YES];
    }
}
@end
