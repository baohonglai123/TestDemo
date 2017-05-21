//
//  BonjourServer.m
//  AirPlayDemo
//
//  Created by 包红来 on 2017/5/14.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "BonjourServer.h"
#import "GCDAsyncSocket.h"
#import "DeviceInfo.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BonjourServer() <NSNetServiceDelegate,GCDAsyncSocketDelegate> {
//    NSNetService *_service;
    GCDAsyncSocket *_asyncSocket;
}

@property(strong,nonatomic) NSNetService *service;
@end

@implementation BonjourServer

-(instancetype) init {
    if (self = [super init]) {
    }
    return self;
}

- (void)publishNetService
{
    // create and publish the bonjour service
    
    UInt16 port = [_asyncSocket localPort];
    
    NSString *name = [[DeviceInfo deviceIdWithSep:@""] stringByAppendingFormat:@"@%@", [[UIDevice currentDevice] name]];
    
    _service = [[NSNetService alloc] initWithDomain:@"local."
                                                 type:@"_raop._tcp."
                                                 name:name
                                                 port:port];
    [_service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_service setDelegate:self];
    [_service publish];
    
    // add TXT record stuff
    
    NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             // txt record version
                             @"1", @"txtvers",
                             
                             // airtunes server version
                             @"104.29", @"vs",
                             
                             // 2 channels, 44100 Hz, 16-bit audio
                             @"2", @"ch",
                             @"44100", @"sr",
                             @"16", @"ss",
                             
                             // no password
                             @"false", @"pw",
                             
                             // encryption types
                             //  0: no encryption
                             //  1: airport express (RSA+AES)
                             //  3: apple tv (FairPlay+AES)
                             @"0,1", @"et",
                             @"1", @"ek",
                             
                             // transport protocols
                             @"TCP,UDP", @"tp",
                             
                             @"0,1", @"cn",
                             @"false", @"sv",
                             @"true", @"da",
                             @"65537", @"vn",
                             @"0,1,2", @"md",							 
                             @"0x4", @"sf",
                             
                             // [DeviceInfo platform], @"am",
                             @"AppleTV2,1", @"am",
                             nil];
    
    NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
    [_service setTXTRecordData:txtData];
    NSLog(@"_service start publish");
}

- (void) publish {
    // Stop the device from sleeping whilst we're playing our tunes
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if (![_asyncSocket acceptOnPort:0 error:&err])
    {
        NSLog(@"Error in acceptOnPort:error: -> %@", err);
        return;
    }
    [self publishNetService];
}

- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"%s",__FUNCTION__);
}

- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"%s",__FUNCTION__);
}
- (void)netServiceDidStop:(NSNetService *)sender {
    NSLog(@"%s",__FUNCTION__);
}

- (void)netServiceDidPublish:(NSNetService *)ns
{
    NSLog(@"[Bonjour] service published: domain(%@) type(%@) name(%@) port(%li)",[ns domain], [ns type], [ns name], (long)[ns port]);
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
    NSLog(@"[Bonjour] failed to publish service: domain(%@) type(%@) name(%@) - %@",
          [ns domain], [ns type], [ns name], errorDict);
}
- (void) dealloc {
    NSLog(@"%s",__FUNCTION__);
}
@end
