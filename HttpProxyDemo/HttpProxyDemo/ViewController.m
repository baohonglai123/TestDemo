//
//  ViewController.m
//  HttpProxyDemo
//
//  Created by 包红来 on 2017/7/10.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "ViewController.h"
#import "HttpProxyServer.h"

@interface ViewController () {
    BOOL _isPause;
    BOOL _isStart;
}
@property (weak, nonatomic) IBOutlet UIButton *startBt;

@property (weak, nonatomic) IBOutlet UIButton *pauseBt;

@property(nonatomic,strong) NSURLSession *session;
@property(nonatomic) NSUInteger expectTotalBytes;
@property(nonatomic) NSMutableData *bufferData;
@property(nonatomic,strong) NSURLSessionDataTask *dataTask;
@property(nonatomic,strong) HttpProxyServer *proxyServer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *urlStr = @"http://www.baidu.com";
//    urlStr = @"http://mvvideo1.meitudata.com/595cdb60aafc39280.mp4";
    _proxyServer = [[HttpProxyServer alloc] initWithUrl:[NSURL URLWithString:urlStr]];
}

- (NSMutableData *) bufferData {
    if (!_bufferData) {
        _bufferData = [[NSMutableData alloc] init];
    }
    return _bufferData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startAction:(id)sender {
    if (_isStart) {
        [_proxyServer stop];
    } else {
        [_proxyServer start];
    }
    _isStart = !_isStart;
    NSString *title = _isStart?@"停止":@"开始";
    [self.startBt setTitle:title forState:UIControlStateNormal];
    NSLog(@"startAction called");
    
}
- (IBAction)clientStartAction:(id)sender {
    [self startHttpRequest];
}

- (void) startHttpRequest {
    NSString *localPath = @"http://127.0.0.1:8898/index";
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:localPath]];
    NSLog(@"before request:%p",request);
    request.timeoutInterval = 5;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"dataTaskWithRequest error:%@",error);
        } else {
            NSLog(@"response :%@",response);
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//            NSLog(@"data:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

- (IBAction)pauseAction:(id)sender {
    if (_isPause) {
        [_proxyServer start];
    } else {
        [_proxyServer pause];
    }
    _isPause = !_isPause;
    NSString *title = _isPause?@"继续":@"暂停";
    [self.pauseBt setTitle:title forState:UIControlStateNormal];
}


@end
