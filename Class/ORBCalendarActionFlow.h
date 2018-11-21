//
//  ORBCalendarViewController.h
//  USmartCam
//
//  Created by Kevin Lin on 05/03/2018.
//  Copyright © 2018 Orbweb.meOrbweb Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ORBCalendarVieWControllerDelegate;
@interface ORBCalendarActionFlow : NSObject

- (instancetype) initWithTargetViewController:(id)target selectDate:(NSDate*)date;
- (void)didSelectDate:(void(^)(NSDate *))completion;
@end
