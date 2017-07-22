//
//  HttpProxyServer.m
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/10.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "HttpProxyServer.h"
#import "GCDAsyncSocket.h"
@interface HttpProxyServer() <NSURLSessionDataDelegate,GCDAsyncSocketDelegate>{
    long long _expectTotalBytes;
    NSURLSession *_session;
    NSURLSessionDataTask *_dataTask;
    NSURL *_url;
    GCDAsyncSocket *_asyncSocket;
    uint16_t _localPort;
    NSDictionary *_responseHeaders;
    GCDAsyncSocket *_clientSocket;
}

@property(nonatomic) NSMutableData *bufferData;
@end

#define TIMEOUT_NONE -1
enum tag_tcp {
    TAG_REQUEST,
    TAG_HEADER,
    TAG_CONTENT,
    TAG_REPLY,
};

@implementation HttpProxyServer

- (instancetype) initWithUrl:(NSURL*)url {
    if ((self = [super init]) && url) {
        _url = url;
        [self reset];
    }
    return self;
}

- (void) reset {
    NSURLSessionConfiguration *sessionConfig =[NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = NO;
    sessionConfig.shouldUseExtendedBackgroundIdleMode = NO;
    _session = [NSURLSession sessionWithConfiguration: sessionConfig delegate:self delegateQueue:nil];
    _dataTask = [_session dataTaskWithURL:_url];
    _bufferData = [[NSMutableData alloc] init];
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    _localPort = 8898;
}

- (void) start {
    if (!_session) {
        [self reset];
    }
    [_dataTask resume];
    [_session finishTasksAndInvalidate];
    [self startHttpServer];
}

- (void) startHttpServer {
    NSError *error;
    if(![_asyncSocket acceptOnPort:_localPort error:&error]) {
        NSLog(@"startHttpServer failed error:%@",error);
    }
}

- (void) pause {
    if (_dataTask.state == NSURLSessionTaskStateRunning) {
        [_dataTask suspend];
    }
}

- (void) stop {
    [_dataTask cancel];
    [_session invalidateAndCancel];
    _session = nil;
    [_asyncSocket disconnectAfterReadingAndWriting];
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
    [self.bufferData appendData:data];
    if (_expectTotalBytes>0) {
        NSLog(@"didReceiveData data progress:%f",[self.bufferData length]*1.0/(_expectTotalBytes *1.0));
    } else {
        NSLog(@"didReceiveData data length:%lu",[data length]);
    }
    
}
/** 告诉delegate, task已经完成. */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"task didCompleteWithError");
//    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp4"];
//    [self.bufferData writeToFile:tmpPath atomically:YES];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"didAcceptNewSocket newsocket:%p,localPort:%d",newSocket,[newSocket localPort]);
    _clientSocket = newSocket;
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:5 tag:TAG_REQUEST];
}

- (void)replyOK:(GCDAsyncSocket *)socket
    withHeaders:(NSDictionary *)headers
       withData:(NSData *)data
{
    NSLog(@"replyOK called socket:%p",socket);
    NSMutableData *rep = [[NSMutableData alloc] init];
    NSMutableString *str = [NSMutableString stringWithString:@"HTTP/1.1 200 OK\r\n"];
    
    if (headers) {
        for (NSString *key in headers) {
            if ([key isEqualToString:@"Content-Encoding"]) {
                continue;
            }
            [str appendFormat:@"%@: %@\r\n", key, [headers valueForKey:key]];
        }
    }
    [str appendString:@"\r\n"];
    NSData *rep_data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [rep appendData:rep_data];
    
    [socket writeData:rep withTimeout:TIMEOUT_NONE tag:TAG_REPLY];
    [self writeData];
}

- (void) writeData {
//    for (int i=0; i<100; ++i) {
//        NSString *dataStr = @"abcd";
//        [_clientSocket writeData:[dataStr dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];
//    }
    [_clientSocket writeData:self.bufferData withTimeout:-1 tag:0];
    
    
    [_clientSocket disconnectAfterReadingAndWriting];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(nonnull NSData *)data withTag:(long)tag {
    NSLog(@"didReadData called tag:%ld, data size:%lu",tag,[data length]);
    NSString *method,*location;
    NSMutableDictionary *headers;
    switch (tag)
    {
        case TAG_REQUEST:
        {
            
            NSString *request = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"========Request============:%@",request);
            NSArray *a = [request componentsSeparatedByString:@" "];
            method = [a objectAtIndex:0];
            location = [a objectAtIndex:1];

            
            headers = [[NSMutableDictionary alloc] init];
            [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:TIMEOUT_NONE tag:TAG_HEADER];
            return;
        }
            
        case TAG_HEADER:
        {
            NSString *header = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"========Header============ :%@",header);
            [self replyOK:sock withHeaders:_responseHeaders withData:nil];

            return;
        }
            
        case TAG_CONTENT:
        {
            NSLog(@"========Content============");
            return;
        }
    }
    
    NSLog(@"Error: invalid read tag %lu", tag);
}
@end
