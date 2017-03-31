//
//  NEFTPServer.h
//  ftp-server-ios
//
//  Created by hzyuxiaohua on 2017/3/31.
//  Copyright © 2017年 XY Network Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEFTPServer : NSObject

+ (instancetype)shareInstance;

- (void)stop;

- (void)startWithPort:(unsigned)port directory:(NSString *)dir;

@end
