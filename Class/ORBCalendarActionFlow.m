//
//  ORBCalendarViewController.m
//  USmartCam
//
//  Created by Kevin Lin on 05/03/2018.
//  Copyright © 2018 Orbweb.meOrbweb Inc. All rights reserved.
//

#import "ORBCalendarActionFlow.h"
#import "FSCalendar.h"
#import <objc/runtime.h>

#define IS_PAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

static CGFloat const ORBCalendarViewHeight = 310.0;

@interface UIAlertController (Calendar) <FSCalendarDelegate, FSCalendarDataSource>
@property (nonatomic, strong) FSCalendar *calendar;
@property (nonatomic, strong) UIView *parentView;
- (void)addCalendarAction:(void(^)(FSCalendar *, NSDate *))action onView:(UIView*)view;
@end

@implementation UIAlertController (Calendar)

- (void)setParentView:(UIView *)parentView {
    objc_setAssociatedObject(self, @selector(parentView), parentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)parentView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCalendar:(FSCalendar *)calendar {
    objc_setAssociatedObject(self, @selector(calendar), calendar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FSCalendar*)calendar {
    FSCalendar * calendar = objc_getAssociatedObject(self, _cmd);
    if (calendar) {
        calendar.delegate = self;
        calendar.dataSource = self;
        return calendar;
    }
    if (IS_PAD) {
        CGRect parentFrame = self.parentView.frame;
       calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(parentFrame) - 20, 290)];
    }else{
        CGRect bounds = [UIScreen mainScreen].bounds;
        calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 40, bounds.size.width - 20, 290)];
    }
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.appearance.headerMinimumDissolvedAlpha = 0;
    calendar.appearance.borderRadius = 1;
    calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    calendar.appearance.headerTitleFont = [UIFont boldSystemFontOfSize:17.0];
    calendar.appearance.weekdayFont = [UIFont boldSystemFontOfSize:14.0];
    calendar.appearance.titleFont = [UIFont systemFontOfSize:14];
    calendar.appearance.headerDateFormat = @"MMM yyyy";
    calendar.appearance.headerTitleColor = [UIColor blackColor];
    calendar.appearance.weekdayTextColor = [UIColor blackColor];
    calendar.appearance.borderSelectionColor = [UIColor clearColor];
    calendar.appearance.todayColor = [UIColor whiteColor];
    calendar.appearance.todaySelectionColor = [UIColor greenColor];
    calendar.appearance.selectionColor = [UIColor greenColor];
    calendar.appearance.selectExpirationColor = [UIColor redColor];
    calendar.appearance.expirationColor = [UIColor lightGrayColor];
    calendar.appearance.titleDefaultColor = [UIColor blackColor];
    calendar.appearance.titleTodayColor = [UIColor greenColor];
    calendar.appearance.titleSelectionColor = [UIColor whiteColor];
    calendar.appearance.titlePlaceholderColor = [UIColor clearColor];
    calendar.appearance.titleWeekendColor = [UIColor blackColor];
    calendar.today = [NSDate date];
    self.calendar = calendar;
    return calendar;
}

- (void)removeBlurEffect {
    [self removeBlurEffect:self.view];
}

- (BOOL)removeBlurEffect:(UIView*)currentView{
    for (id childView in currentView.subviews) {
        if ([childView isKindOfClass:[UIVisualEffectView class]]) {
            [childView removeFromSuperview];
            return YES;
        }else {
            NSString *className = NSStringFromClass([childView class]);
            if ([className isEqualToString:@"_UIInterfaceActionGroupHeaderScrollView"]) {
                UIView *view = [childView superview];
                view.backgroundColor = [UIColor whiteColor];
            }
        }
        [self removeBlurEffect:childView];
    }
    return NO;
}

- (UIButton*)previousButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [button setImage:[UIImage imageNamed:@"ic_last_page_pad"] forState:UIControlStateNormal];
    [button setTitle:@"PREV" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(16, 40, 60, 40)];
    return button;
}

- (UIButton*)nextButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [button setImage:[UIImage imageNamed:@"ic_next_page_pad"] forState:UIControlStateNormal];
    [button setTitle:@"NEXT" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    CGFloat buttonOriginX = 0;
    if (IS_PAD) {
        CGRect parentFrame = self.parentView.frame;
        buttonOriginX = CGRectGetWidth(parentFrame) - 96;
    }else{
        CGRect bounds = [UIScreen mainScreen].bounds;
        buttonOriginX = bounds.size.width - 20 - 60 - 16;
    }
    [button setFrame:CGRectMake(buttonOriginX, 40, 60, 40)];
    return button;
}

- (UIButton*)doneButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat buttonOriginX = 0;
    if (IS_PAD) {
        CGRect parentFrame = self.parentView.frame;
        buttonOriginX = CGRectGetWidth(parentFrame) - 20 - 60 - 16;
    }else{
        CGRect bounds = [UIScreen mainScreen].bounds;
        buttonOriginX = bounds.size.width - 20 - 60 - 16;
    }
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:CGRectMake(buttonOriginX, 10, 60, 40)];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [button addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)cancelButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(16, 10, 60, 40)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)done:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FSCalendarDidSelectDateNotification" object:self.calendar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addCalendarAction:(void (^)(FSCalendar *, NSDate*))action onView:(UIView *)view{
    self.parentView = view;
    [self.view addSubview:[self doneButton]];
    [self.view addSubview:[self calendar]];
    [self.view addSubview:[self previousButton]];
    [self.view addSubview:[self nextButton]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ORBCalendarViewHeight+90]];
    action(self.calendar, self.calendar.selectedDate);
}

- (void)previousClicked:(id)sender
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *previousMonth = [gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:previousMonth animated:YES];
}

- (void)nextClicked:(id)sender
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *nextMonth = [gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

#pragma mark - <FSCalendarDataSource>

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    return 0;
}

#pragma mark - <FSCalendarDelegate>

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    if (monthPosition == FSCalendarMonthPositionNext) {
        return NO;
    }
    if (monthPosition == FSCalendarMonthPositionPrevious) {
        return NO;
    }
    return [[NSDate date] timeIntervalSinceDate:date] <= 0;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"MMM d, yyyy";
//    NSLog(@"[%p][%p]did select date %@",self.calendar, calendar ,[dateFormatter stringFromDate:date]);
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"MMM d, yyyy";
//    NSLog(@"did change to page %@",[dateFormatter stringFromDate:calendar.currentPage]);
}
@end

@interface ORBCalendarActionFlow () <FSCalendarDataSource, FSCalendarDelegate> {
    UIViewController *_parentViewController;
}


@property (nonatomic, strong) UIView *divider;
@property (nonatomic, strong) FSCalendar *calendar;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIAlertController *actionSheet;
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, copy) void(^selectCallback)(NSDate*);
@end

@implementation ORBCalendarActionFlow

- (instancetype) initWithTargetViewController:(id)target selectDate:(NSDate*)date{
    self = [super init];
    if (self) {
        _parentViewController = target;
        _selectedDate = date;
    }
    return self;
}

- (void)showActionSheetFlow {
    _actionSheet = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [_actionSheet removeBlurEffect];
    [_actionSheet addCalendarAction:^(FSCalendar *calendar, NSDate *selectDate){
        if (self->_selectedDate != nil) {
            ORBCalendarActionFlow *strongSelf = weakSelf;
            if (!strongSelf) {
                return ;
            }
            [calendar selectDate:strongSelf->_selectedDate];
            [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(calendarDidSelectDate:) name:@"FSCalendarDidSelectDateNotification" object:calendar];
        }
    } onView:_parentViewController.view];
    [_actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        ORBCalendarActionFlow *strongSelf = weakSelf;
        if (!strongSelf) { return ;}
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FSCalendarDidSelectDateNotification" object:strongSelf.actionSheet.calendar];
    }]];
    [_parentViewController presentViewController:_actionSheet animated:YES completion:nil];
}

#pragma mark - Actions

- (void)didSelectDate:(void (^)(NSDate *))completion {
    [self showActionSheetFlow];
    _selectCallback = completion;
}

#pragma mark - Notification

- (void)calendarDidSelectDate:(NSNotification*)notification {
    FSCalendar *calendar = notification.object;
    if (_selectCallback) {
        _selectCallback(calendar.selectedDate);
    }
}

@end
