//
//  ClientTestViewController.m
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/18.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "ClientTestViewController.h"
#import "GCDAsyncSocket.h"

@interface ClientTestViewController ()<GCDAsyncSocketDelegate> {
    GCDAsyncSocket *asyncSocket;
}

@property (weak, nonatomic) IBOutlet UITextView *messageView;

@end

@implementation ClientTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [asyncSocket setIPv6Enabled:NO];
    self.messageView.text = @"";

    NSError *error = nil;
    if(![asyncSocket connectToHost:@"192.168.2.2" onPort:8899 error:&error]) {
        NSLog(@"asyncSocket connect host error:%@",error);
        [self updateMessageTextView:[NSString stringWithFormat:@"asyncSocket connect host error:%@",error]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateMessageTextView:(NSString *)message {
    self.messageView.text = [self.messageView.text stringByAppendingFormat:@"%@\n",message];
}

#pragma mark - GCDAsyncSocketDelegate

- (IBAction)sendAction:(id)sender {
    NSString *message = @"hello socket\r\n";
    NSData *data = [message dataUsingEncoding:NSASCIIStringEncoding];
    [asyncSocket writeData:data withTimeout:-1 tag:0];
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteData");
    [self updateMessageTextView:@"didWriteData"];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"didReadData data:%@",dataStr);
    [self updateMessageTextView:dataStr];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"socket didConnectToHost success");
    [self updateMessageTextView:@"socket didConnectToHost success"];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect called");
    [self updateMessageTextView:@"socketDidDisconnect called"];
}

- (void) dealloc {
    [asyncSocket disconnect];
    asyncSocket = nil;
}
@end
