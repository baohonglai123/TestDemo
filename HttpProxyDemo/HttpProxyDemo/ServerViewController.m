//
//  ServerViewController.m
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/18.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "ServerViewController.h"
#import "GCDAsyncSocket.h"

@interface ServerViewController ()<GCDAsyncSocketDelegate> {
    GCDAsyncSocket *asyncSocket;
    GCDAsyncSocket *clientSocket;
}

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.logTextView.text = @"";
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [asyncSocket disconnect];
    asyncSocket = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startServer:(id)sender {
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    uint16_t localPort = 8899;
    NSError *error = nil;
    NSString *logStr = @"";
    if (![asyncSocket acceptOnPort:localPort error:&error]) {
        logStr = [NSString stringWithFormat:@"socket accept error:%@",error];
        NSLog(@"socket accept error:%@",error);
    } else {
        logStr = @"accept success";
    }
    [self updateMessageTextView:logStr];
}

#pragma mark - GCDAsyncSocketDelegate 

- (void) socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    clientSocket = newSocket;
    NSString *logStr = [NSString stringWithFormat:@"didAcceptNewSocket host:%@, connectedPort:%d",newSocket.connectedHost,newSocket.connectedPort];
    [self updateMessageTextView:logStr];
//    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [self replyMessage:message];
//    [clientSocket readDataWithTimeout:-1 tag:0];
}

- (void) replyMessage:(NSString *)message {
    NSString *str = [NSString stringWithFormat:@"receve message:%@",message];
    [self updateMessageTextView:str];
    [clientSocket writeData:[str dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];
}

- (void) updateMessageTextView:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.text = [self.logTextView.text stringByAppendingFormat:@"%@\n",message];
    });
}

@end
