//
//  EventsJSONParser.m
//  GW2MacOverlay
//
//  Created by Bastien on 8/19/13.
//  Copyright (c) 2013 Bastien. All rights reserved.
//

#import "EventsJSONParser.h"
#import "Event.h"
#import "EventGroup.h"

@implementation EventsJSONParser

- (void)updateByWorld:(NSInteger)worldId andEventGroups:(NSArray *)eventGroups{
    NSString *url = [NSString stringWithFormat:@"https://api.guildwars2.com/v1/events.json?world_id=%ld", worldId];
    
    NSLog(@"%@",url);
    
    NSURL *eventsURL = [NSURL URLWithString:url];
    NSData *eventsData = [[NSData alloc] initWithContentsOfURL:eventsURL];
    if (eventsData) {
        NSError *error = nil;
        NSDictionary *eventsJSON = [NSJSONSerialization JSONObjectWithData:eventsData options:0 error:&error];
        
        if (error) {
            NSLog(@"Error parsing JSON: %@", error);
        } else {
            for(NSDictionary *item in [eventsJSON objectForKey:@"events"]) {
                for(EventGroup *eg in eventGroups){
                    for(Event *ev in [eg _listOfEvents]){
                        if([[item objectForKey:@"event_id"] isEqualToString:ev._id]){
                            [ev set_status:[item objectForKey:@"state"]];
                        }
                    }
                }
            }
            
            for(EventGroup *eg in eventGroups){
                [eg updateActive];
            }
            
        }
    } else {
        NSLog(@"Error connecting to events API");
    }
}

- (NSMutableArray*)updateByEvent:(NSString*)eventId{
    NSMutableArray *listOfActiveWorld = [[NSMutableArray alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"https://api.guildwars2.com/v1/events.json?event_id=%@", eventId];
    
    NSLog(@"%@",url);
    
    NSURL *eventsURL = [NSURL URLWithString:url];
    NSData *eventsData = [[NSData alloc] initWithContentsOfURL:eventsURL];
    if (eventsData) {
        NSError *error = nil;
        NSDictionary *eventsJSON = [NSJSONSerialization JSONObjectWithData:eventsData options:0 error:&error];
        
        if (error) {
            NSLog(@"Error parsing JSON: %@", error);
        } else {
            for(NSDictionary *item in [eventsJSON objectForKey:@"events"]) {
                if([[item objectForKey:@"state"] isEqualToString:@"Active"]){
                    [listOfActiveWorld addObject:[item objectForKey:@"world_id"]];
                }
            }            
        }
    } else {
        NSLog(@"Error connecting to events API");
    }

    return listOfActiveWorld;
}

@end
