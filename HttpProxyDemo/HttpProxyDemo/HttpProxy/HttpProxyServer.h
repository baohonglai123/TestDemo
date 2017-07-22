//
//  HttpProxyServer.h
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/10.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpProxyServer : NSObject

//是否允许预加载
@property(nonatomic,assign) BOOL allowPreLoad;

- (instancetype) initWithUrl:(NSURL*)url;
- (void) start;
- (void) pause;
- (void) stop;

@end
