//
//  MapOptionsViewController.m
//  DiagramEditor
//
//  Created by Diego on 6/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "MapOptionsViewController.h"
#import <MapKit/MapKit.h>
@interface MapOptionsViewController ()

@end

@implementation MapOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    // Do any additional setup after loading the view.
    
    mapTypePicker.delegate = self;
    mapTypePicker.dataSource = self;
    
    
    directionSearchBar.delegate = self;
    
    [self fillMapTypes];
    [self setActualType];
}

-(void)setActualType{
    if(dele.map.mapType == MKMapTypeStandard){
        [mapTypePicker selectRow:0
                     inComponent:0
                        animated:YES];
    }else if(dele.map.mapType == MKMapTypeSatellite){
        [mapTypePicker selectRow:1
                     inComponent:0
                        animated:YES];
    }else if(dele.map.mapType == MKMapTypeHybrid){
        [mapTypePicker selectRow:2
                     inComponent:0
                        animated:YES];
    }else if(dele.map.mapType == MKMapTypeSatelliteFlyover){
        [mapTypePicker selectRow:3
                     inComponent:0
                        animated:YES];
    }else if(dele.map.mapType == MKMapTypeHybridFlyover){
        [mapTypePicker selectRow:4
                     inComponent:0
                        animated:YES];
    }
}

-(void)fillMapTypes{
    mapTypes = [[NSMutableArray alloc] init];
    
    [mapTypes addObject:@"Standard"];
    [mapTypes addObject:@"Satellite"];
    [mapTypes addObject:@"Hybrid"];
    [mapTypes addObject:@"Satellite flyover"];
    [mapTypes addObject:@"Hybrid flyover"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return mapTypes.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [mapTypes objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    NSString * selected = [mapTypes objectAtIndex:row];
    
    if([selected isEqualToString:@"Standard"]){
        [dele.map setMapType:MKMapTypeStandard];
    } else if([selected isEqualToString:@"Satellite"]){
        [dele.map setMapType:MKMapTypeSatellite];
    } else if([selected isEqualToString:@"Hybrid"]){
        [dele.map setMapType:MKMapTypeHybrid];
    } else if([selected isEqualToString:@"Satellite flyover"]){
        [dele.map setMapType:MKMapTypeSatelliteFlyover];
    } else if([selected isEqualToString:@"Hybrid flyover"]){
        [dele.map setMapType:MKMapTypeHybridFlyover];
    }
}


- (IBAction)closeMapOptions:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)testFlyover:(id)sender {
    
    //We need a flyover map
    if(dele.map.mapType != MKMapTypeSatelliteFlyover && dele.map.mapType != MKMapTypeHybridFlyover){
        dele.map.mapType = MKMapTypeSatelliteFlyover;
    }
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"startFlyover" object:nil];
    }];
    
    
}


-(void)centerMapOnMapItem:(MKMapItem *)item{
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    MKPlacemark * mark = item.placemark;
    
    CLLocationCoordinate2D coordinates= mark.coordinate;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    
    region.span = span;
    region.center = coordinates;
    [dele.map setRegion:region animated:YES];
}

#pragma mark UISearchBar delegate methods

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{ //Search
    
    
    // Create a search request with a string
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    [searchRequest setNaturalLanguageQuery:searchBar.text];
    
    // Create the local search to perform the search
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (!error) {
            
            MKMapItem * first = [[response mapItems]objectAtIndex:0];
            [self centerMapOnMapItem:first];
            
            
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"Search Request Error: %@", [error localizedDescription]);
        }
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [directionSearchBar endEditing:YES];
}
@end
