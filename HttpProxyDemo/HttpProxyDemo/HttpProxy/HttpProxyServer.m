//
//  HttpProxyServer.m
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/10.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "HttpProxyServer.h"
#import "GCDAsyncSocket.h"
#import "HttpClient.h"
@interface HttpProxyServer() <GCDAsyncSocketDelegate>{
    NSURL *_url;
    GCDAsyncSocket *_asyncSocket;
    uint16_t _localPort;
    GCDAsyncSocket *_clientSocket;
    HttpClient *_httpClient;
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
        _httpClient = [[HttpClient alloc] initWithUrl:url];
        [self reset];
    }
    return self;
}

- (void) reset {
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    _localPort = 8898;
}

- (void) start {
    [_httpClient start];
    [self startHttpServer];
}

- (void) startHttpServer {
    NSError *error;
    if(![_asyncSocket acceptOnPort:_localPort error:&error]) {
        NSLog(@"startHttpServer failed error:%@",error);
    }
}

- (void) pause {
    [_httpClient pause];
}

- (void) stop {
    [_httpClient stop];
    [_asyncSocket disconnectAfterReadingAndWriting];
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
    NSData *bufferData = [_httpClient nextBuffer];
    NSLog(@"writeData size:%lu",bufferData.length);
    if (bufferData.length > 0) {
        [_clientSocket writeData:bufferData withTimeout:-1 tag:0];
//        [_clientSocket disconnectAfterReadingAndWriting];
    }
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
            [self replyOK:sock withHeaders:_httpClient.respHeaders withData:nil];

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
