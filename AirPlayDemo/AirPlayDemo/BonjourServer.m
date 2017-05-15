//
//  BonjourServer.m
//  AirPlayDemo
//
//  Created by 包红来 on 2017/5/14.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "BonjourServer.h"

@interface BonjourServer() {
    NSNetService *_service;
}
@end

@implementation BonjourServer

-(instancetype) init {
    if (self = [super init]) {
        _service = [[NSNetService alloc] initWithDomain:@"local." type:@"_http._tcp." name:@"DamonWebServer" port:8848];
        __weak id weakSelf = self;
        _service.delegate = weakSelf;
    }
    return self;
}

- (void) publish {
    [_service publish];
    NSLog(@"_service start publish");
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"netServiceDidPublish called");
}
@end
