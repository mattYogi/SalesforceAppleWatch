//
//  InterfaceController.h
//  SFWatchDemo3 WatchKit Extension
//
//  Created by Mathanan Yogaratnam on 2/23/15.
//  Copyright (c) 2015 Salesforce. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *messageLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *eventsTable;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *errorIcon;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *refreshTimeLabel;
@end
