//
//  InterfaceController.m
//  SFWatchDemo3 WatchKit Extension
//
//  Created by Mathanan Yogaratnam on 2/23/15.
//  Copyright (c) 2015 Salesforce. All rights reserved.
//

#import "InterfaceController.h"
#import "EventRowController.h"
//#import "SFDateUtil.h"
//#import "SObjectDataManager.h"
//#import "EventSObjectDataSpec.h"
//#import "EventSObjectData.h"

@interface InterfaceController()
@property (strong, nonatomic) NSMutableArray *events;
@property int pollCount;
@property NSTimer *timer;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.pollCount = 0;
    NSLog(@"Poll Count: %i", (int)self.pollCount);
    
    // Invoke Parent app to get latest Events data from the local store
    NSDictionary *request = @{@"request":@"getEventsLocal"}; //set up request dictionary
    
    [InterfaceController openParentApplication:request reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"Sync Gap: %@", [replyInfo valueForKey:@"syncGap"]);
            self.events = [replyInfo valueForKey:@"events"];
            [self.refreshTimeLabel setText:[replyInfo valueForKey:@"syncGap"]];
            [self refreshTableData]; //refresh the table with returned data
            NSLog(@"diff val: %@", [replyInfo valueForKey:@"diff"]);
            //if the last sync time was greater than 60 seconds ago, poll again in 3 secs to check if a newer synced dataset is available
            if ([[replyInfo valueForKey:@"diff"] floatValue]> 60) {
                
                self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(RefreshFromParent) userInfo:nil repeats:YES];
                
            }
        }
        
    }];
    
    
    //issue another call to refresh from host
    //[self RefreshFromParent];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}



-(void)refreshTableData{
    
    //[self presentControllerWithName:@"ErrorPageController" context:self];
    //[self.errorLabel setHeight:0];
    //[self.errorLabel setHidden:YES];
    
    NSLog(@"Events Table size: %lD", (unsigned long)self.events.count);
    [self.eventsTable setNumberOfRows:self.events.count withRowType:@"default"];
    
    for (NSInteger i=0 ; i<self.events.count; i++) {
        EventRowController *row = [self.eventsTable rowControllerAtIndex:i];
        
        NSLog(@"Loading Table Row: %lD", (long)i);
        NSDictionary *obj = [self.events objectAtIndex:i];
        
        NSString *eventLabel = [[NSString alloc] initWithFormat:@"%@ \n%@", [obj valueForKey:@"startTime"], [obj valueForKey:@"subject"]];
        
        [row.eventSubject setText:eventLabel];
        
        
    }
    
}
- (void)RefreshFromParent {
    
    if (self.pollCount < 3){
        
        NSLog(@"RefreshFromParent");
        
        NSDictionary *request = @{@"request":@"getEventsRemote"}; //set up request dictionary
        BOOL parentSuccess =  [InterfaceController openParentApplication:request reply:^(NSDictionary *replyInfo, NSError *error) {
            self.pollCount = self.pollCount+1;
            NSLog(@"Poll Count: %i", self.pollCount);

            if (error) {
                NSLog(@"%@", error);
            } else {
                NSLog(@"Response Received");
                NSLog(@"diff val: %@", [replyInfo valueForKey:@"diff"]);
                self.events = [replyInfo valueForKey:@"events"];
                
                [self.refreshTimeLabel setText:[replyInfo valueForKey:@"syncGap"]];
                [self refreshTableData]; //refresh the table with returned data
                
                //if the last sync time was less than 60 seconds ago, cancel the polling
                if ([[replyInfo valueForKey:@"diff"] floatValue]< 60) {
                    NSLog(@"Cancellig Timer. Poll Count: %i", (int)self.pollCount);
                    if(self.timer)
                    {
                        [self.timer invalidate];
                        self.timer = nil;
                        NSLog(@"Cancelled Timer");
                    }
                }
            }
            
        }];
        
        NSLog(@"Request sent?: %i", parentSuccess);
        
    }else{ //Cancel timer if we've tried to refresh more than three times (likely to be an issue / no network connection)
        if(self.timer)
        {
            [self.timer invalidate];
            self.timer = nil;
            NSLog(@"Cancelled Timer");
        }
    }
}
@end



