//
//  ViewController.m
//  ORBCalendarActionFlow
//
//  Created by Kevin Lin on 2018/11/21.
//  Copyright © 2018 Orbweb Inc. All rights reserved.
//

#import "ViewController.h"

#import "ORBCalendarActionFlow.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showCalendarActionSheet:(id)sender{
    ORBCalendarActionFlow *flow =
    [[ORBCalendarActionFlow alloc] initWithTargetViewController:self selectDate:[NSDate date]];
    [flow didSelectDate:^(NSDate *selectedDate){
        NSLog(@"selectedDate: %@", selectedDate);
    }];
}

@end
