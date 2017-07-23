//
//  HttpClient.m
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/21.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "HttpClient.h"

@interface SocketPacket : NSObject {
    @public
    NSData *buffer;
}
- (instancetype) initWithData:(NSData *)data;
@end

@implementation SocketPacket

- (instancetype) initWithData:(NSData *)data {
    if ((self = [super init])) {
        self->buffer = data;
    }
    return self;
}

@end

@interface HttpClient()<NSURLSessionDataDelegate> {
    NSURL *_httpUrl;
    NSURLSession *_session;
    NSURLSessionDataTask *_dataTask;
    NSMutableArray *_bufferQueue;
    NSDictionary *_responseHeaders;
    long long _expectTotalBytes;
    NSUInteger _bufferFullThresh;

}
@end


@implementation HttpClient

- (instancetype) initWithUrl:(NSURL *) url {
    if (self = [super init]) {
        _httpUrl = url;
        [self reset];
    }
    return self;
}
- (void) reset {
    NSURLSessionConfiguration *sessionConfig =[NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = NO;
    sessionConfig.shouldUseExtendedBackgroundIdleMode = NO;
    _session = [NSURLSession sessionWithConfiguration: sessionConfig delegate:self delegateQueue:nil];
    _dataTask = [_session dataTaskWithURL:_httpUrl];
    _bufferQueue = [NSMutableArray new];
    _expectedMaxSize = 100*1024;
    _bufferFullThresh = (NSUInteger)(_expectedMaxSize * 0.1);
}

- (void) start {
    [_dataTask resume];
}
- (void) pause {
    if (_dataTask.state == NSURLSessionTaskStateSuspended) {
        return;
    }
    [_dataTask suspend];
}
- (void) stop {
    [_dataTask suspend];
    [_session invalidateAndCancel];
}

- (NSData *) nextBuffer {
    @synchronized (_bufferQueue) {
        NSMutableData *result = [NSMutableData new];
        for (SocketPacket *packet in _bufferQueue) {
            [result appendData:packet->buffer];
        }
        [_bufferQueue removeAllObjects];
        [self start];
        NSLog(@"继续下载");
        return [result copy];
    }
}

- (NSDictionary*) respHeaders {
    return [_responseHeaders copy];
}

- (BOOL) checkBufferFull {
    NSUInteger avalibleBytes = 0;
    for (SocketPacket *packet in _bufferQueue) {
        avalibleBytes += packet->buffer.length;
    }
    NSLog(@"avalibleBytes :%lu",avalibleBytes);
    if (avalibleBytes + _bufferFullThresh > _expectedMaxSize) {
        return YES;
    }
    return NO;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSLog(@"didReceiveResponse response status code:%ld",httpResponse.statusCode);
    NSLog(@"didReceiveResponse response header:%@",httpResponse.allHeaderFields);
    _responseHeaders = httpResponse.allHeaderFields;
    _expectTotalBytes = response.expectedContentLength;
    completionHandler(NSURLSessionResponseAllow);//继续数据传输
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    SocketPacket *packet = [[SocketPacket alloc] initWithData:data];
    [_bufferQueue addObject:packet];
    if (_expectTotalBytes>0) {
        NSLog(@"didReceiveData data progress:%f",[data length]*1.0/(_expectTotalBytes *1.0));
    } else {
        NSLog(@"didReceiveData data length:%lu",[data length]);
    }
    if ([self checkBufferFull]) {
        NSLog(@"buffer is full 暂停下载");
        [self pause];
    }
    
}
/** 告诉delegate, task已经完成. */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"task didCompleteWithError");
}


@end
