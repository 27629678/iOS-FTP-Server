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
        [instance autorelease];
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
    [super dealloc];
    
    self.ftp = nil;
}

#pragma mark - private

- (void)stop
{
    if (!self.ftp) {
        return;
    }
    
    [self.ftp stopFtpServer];
    self.ftp = nil;
}

- (void)startWithPort:(unsigned)port directory:(NSString *)dir
{
    [self stop];
    
    // is wifi available
    NSString *wifi_ip_addr = [[NetworkController localWifiIPAddress] autorelease];
    if (wifi_ip_addr.length == 0) {
        [self showAlertWithMessage:@"Invalid IP, Please Check Wi-Fi Network!"];
        return;
    }
    
    // is directory available
    BOOL isDirectory = NO;
    NSFileManager *fm = [[NSFileManager defaultManager] autorelease];
    BOOL isExist = [fm fileExistsAtPath:dir isDirectory:&isDirectory];
    
    if (!isExist || !isDirectory) {
        NSString *msg =
        [[NSString stringWithFormat:@"The Sepcified Directory: %@ Not Exist!", dir] autorelease];
        [self showAlertWithMessage:msg];
        return;
    }
    
    self.ftp = [[[FtpServer alloc] initWithPort:port withDir:dir notifyObject:self] autorelease];
    if (!self.ftp) {
        [self showAlertWithMessage:@"Start FTP Server Failed!"];
        return;
    }
    
    NSString *msg = [[NSString stringWithFormat:@"FTP Server is Listen On %@:%@",
                      wifi_ip_addr, @(port)] autorelease];
    [self showAlertWithMessage:msg];
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

@end
