//
//  NEFTPServer.m
//  ftp-server-ios
//
//  Created by hzyuxiaohua on 2017/3/31.
//  Copyright © 2017年 XY Network Co., Ltd. All rights reserved.
//

#import "NEFTPServer.h"

#import "FtpServer.h"
#import "NetworkController.h"

#import <UIKit/UIKit.h>

@interface NEFTPServer ()

@property (nonatomic, strong) FtpServer *ftp;

@end

@implementation NEFTPServer

+ (instancetype)shareInstance
{
    static NEFTPServer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NEFTPServer new];
    });
    
    return instance;
}

+ (void)stop
{
    [[NEFTPServer shareInstance] stop];
}

+ (void)startWithPort:(unsigned)port directory:(NSString *)dir
{
    [[NEFTPServer shareInstance] startWithPort:port directory:dir];
}

- (void)dealloc
{
    [self.ftp release];
    [super dealloc];
}

#pragma mark - private

- (void)stop
{
    if (!self.ftp) {
        return;
    }
    
    [self.ftp stopFtpServer];
    self.ftp = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)startWithPort:(unsigned)port directory:(NSString *)dir
{
    [self stop];
    
    // is wifi available
    NSString *wifi_ip_addr = [NetworkController localWifiIPAddress];
    if (wifi_ip_addr.length == 0 || [wifi_ip_addr isEqualToString:@"error"]) {
        [self showAlertWithMessage:@"Invalid IP, Please Check Wi-Fi Network!"];
        return;
    }
    
    // is directory available
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDirectory];
    
    if (!isExist || !isDirectory) {
        [self showAlertWithMessage:@"The Sepcified Directory: %@ Not Exist!", dir];
        return;
    }
    
    self.ftp = [[FtpServer alloc] initWithPort:port withDir:dir notifyObject:nil];
    
    if (!self.ftp) {
        [self showAlertWithMessage:@"Start FTP Server Failed!"];
        return;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self showAlertWithMessage:@"FTP Server is Running On %@:%@", wifi_ip_addr, @(port)];
}

- (void)showAlertWithMessage:(NSString *)format, ...
{
    va_list vl;
    va_start(vl, format);
    NSString *message = [[[NSString alloc] initWithFormat:format arguments:vl] autorelease];
    va_end(vl);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
