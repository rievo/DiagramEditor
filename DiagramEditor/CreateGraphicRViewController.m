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
    
    [self formGraphicR];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)formGraphicR{
    text = @"";
    
    //text = [text stringByAppendingString:@""];
    text = [text stringByAppendingString:@"<?xml version=\"1.0\" encoding=\"ASCII\"?>\n"];
    text = [text stringByAppendingString:@"<graphicR:GraphicRepresentation xmi:version=\"2.0\"\n"];
    text = [text stringByAppendingString:@"xmlns:xmi=\"http://www.omg.org/XMI\" "];
    text = [text stringByAppendingString:@"xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "];
    text = [text stringByAppendingString:@"xmlns:graphicR=\"http://mondo.org/graphic_representation/1.0.3\">"];
    
    NSString * extension = @"wt";
    NSString * fileName =[NSString stringWithFormat:@"%@.ecore", _selectedJson.name];
    NSString * name = @"test";
    
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
                
                text = [text stringByAppendingString:
                        [NSString stringWithFormat:@"<color xsi:type=\"graphicR:SiriusSystemColors\" name=\"%@\"  />\n", @"red"]];
                
                text = [text stringByAppendingString:@"</linkPalette>"];
            }
            
            text = [text stringByAppendingString:@"</node_elements>"];
            
            
            text = [text stringByAppendingString:[NSString stringWithFormat:@"<node_shape xsi:type=\"graphicR:%@\">", associated.shapeType]];

            
            text = [text stringByAppendingString:[NSString stringWithFormat:@"<color xsi:type=\"graphicR:SiriusSystemColors\" name=\"%@\"  />\n", associated.colorString]]; //Fill color
            
            text = [text stringByAppendingString:[NSString stringWithFormat:@"<borderColor xsi:type=\"graphicR:SiriusSystemColors\" name=\"%@\"  />\n", associated.borderColorString]]; //Fill color
            
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
    
    int r  = 2;
}

@end
