//
//  ViewController.m
//  闹钟
//
//  Created by 广州昂鼎信息科技有限公司 on 16/3/18.
//  Copyright © 2016年 广州昂鼎信息科技有限公司. All rights reserved.
//
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UILabel *presentTime;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@end

@implementation ViewController
-  (AVSpeechSynthesizer *)synthesizer
{
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _synthesizer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //当前时间
    NSDate *now = [NSDate date];
    //日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitYear |  NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *dd = [calendar components:unitFlags fromDate:now];
    NSInteger y = [dd year];
    NSInteger m = [dd month];
    NSInteger d = [dd day];
    NSInteger hour = [dd hour];
    NSInteger min = [dd minute];
    
    self.presentTime.text = [NSString stringWithFormat:@"%ld-%ld-%ld %ld:%ld",y,m,d,hour,min];
    self.timeLabel.text = @"时间";
    self.datePicker.date = now;
}
//添加按钮
- (IBAction)sure:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //时区
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    NSString *dateTimeString = [dateFormatter stringFromDate:self.datePicker.date];
    self.timeLabel.text = dateTimeString;
    
    // 点击确定 设置好时间之后添加本地提醒  用UILocalNotification来实现。
    [self scheduleLocalNotificationWithDate:self.datePicker.date];
    [self remindController:@"闹钟已经添加"];

    [self voiceAnnouncementsText:@"闹钟已经添加"];
}
//取消按钮
- (IBAction)cencal:(id)sender {
    //取消所有的本地通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self remindController:@"闹钟提醒已经取消"];
    
    [self voiceAnnouncementsText:@"闹钟提醒已经取消"];
}
//通知
- (void)scheduleLocalNotificationWithDate:(NSDate *)fireDate
{
    //0.创建推送
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //1.设置推送类型
    UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    //2.设置setting
    UIUserNotificationSettings *setting  = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    //3.主动授权
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    //4.设置推送时间
    [localNotification setFireDate:fireDate];
    //5.设置时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //6.推送内容
    [localNotification setAlertBody:@"Time to wake up!"];
    //7.推送声音
    [localNotification setSoundName:@"Thunder Song.m4r"];
    //8.添加推送到UIApplication
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
//提示页面
- (void)remindController:(NSString *)remindText
{
    //提示页面（8.0出现）
    /**
     *  1.创建UIAlertController的对象
     2.创建UIAlertController的方法
     3.控制器添加action
     4.用presentViewController模态视图控制器
     */
    UIAlertController *alart = [UIAlertController alertControllerWithTitle:@"提示" message:remindText preferredStyle:UIAlertControllerStyleActionSheet];
    [self presentViewController:alart animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alart dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}
//语音播报
- (void)voiceAnnouncementsText:(NSString *)text
{AVAudioSessionInterruptionTypeKey
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    [self.synthesizer speakUtterance:utterance];
}
@end
