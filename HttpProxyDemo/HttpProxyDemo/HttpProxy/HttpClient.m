//
//  HttpClient.m
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/21.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "HttpClient.h"
@interface HttpClient()<NSURLSessionDataDelegate> {
    NSURL *_httpUrl;
    NSURLSession *_session;
    NSURLSessionDataTask *_dataTask;
    NSMutableData *_bufferData;
    NSDictionary *_responseHeaders;
    long long _expectTotalBytes;

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
    _bufferData = [[NSMutableData alloc] init];
}

- (void) start {
    [_dataTask resume];
}
- (void) pause {
    [_dataTask suspend];
}
- (void) stop {
    [_dataTask suspend];
    [_session invalidateAndCancel];
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
    [_bufferData appendData:data];
    if (_expectTotalBytes>0) {
        NSLog(@"didReceiveData data progress:%f",[_bufferData length]*1.0/(_expectTotalBytes *1.0));
    } else {
        NSLog(@"didReceiveData data length:%lu",[data length]);
    }
    
}
/** 告诉delegate, task已经完成. */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"task didCompleteWithError");
}


@end
