//
//  HttpClient.h
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/21.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpClient : NSObject

@property (nonatomic,readonly) NSData *nextBuffer;
@property (nonatomic,readonly) NSDictionary *respHeaders;

- (instancetype) initWithUrl:(NSURL *) url;
- (void) start;
- (void) pause;
- (void) stop;
@end
