//
//  WIWebViewController.m
//  WebIBC
//
//  Created by zhaole on 2017/4/24.
//  Copyright © 2017年 WEB. All rights reserved.
//

#import "WIWebViewController.h"

#import<CoreLocation/CoreLocation.h>


#define WEB_URL @"http://www.baidu.com"//自己的网址

#define BEACONUUID @"12334566-7173-4889-9579-954995439125"//iBeacon自己设备的uuid
@interface WIWebViewController ()<UIWebViewDelegate,CLLocationManagerDelegate>

@property WebViewJavascriptBridge *bridge;

@property (strong, nonatomic) CLBeaconRegion *beacon;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationmanager;

@property (nonatomic,strong)NSMutableArray * dataArray;

@property (nonatomic,strong)NSTimer * timer;

@end

@implementation WIWebViewController

-(NSMutableArray *)dataArray
{
    if(_dataArray == nil){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpWebView];

    [self setUpAction];
    
    [self setUpManager];
    
}

#pragma mark 加载定位
- (void)setUpManager
{
    self.locationmanager = [[CLLocationManager alloc] init];//初始化
    
    self.locationmanager.delegate = self;
    
    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许
    
    self.beacon = [[CLBeaconRegion alloc]initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACONUUID] identifier:@"id"];
    self.beacon.notifyOnEntry=YES;
    self.beacon.notifyOnExit=YES;
    self.beacon.notifyEntryStateOnDisplay=YES;
    
    [self.locationmanager startMonitoringForRegion:self.beacon];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(self.dataArray.count>0){
            NSMutableArray * sendArray = [NSMutableArray array];
            for (CLBeacon* beacon in self.dataArray) {
                [sendArray addObject:@{@"major":beacon.major,@"minor":beacon.minor,@"rssi":@(beacon.rssi)}];
            }
            [self.bridge callHandler:@"leScanCallback" data:@{@"errMsg":@"ok",@"beacons":sendArray}];
        }
    }];
}

#pragma mark 加载webView

- (void)setUpWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    NSURL *url = [[NSURL alloc]initWithString:WEB_URL];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    // 开启日志
    [WebViewJavascriptBridge enableLogging];
    
    // 给哪个webview建立JS与OjbC的沟通桥梁
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    
    [self.bridge setWebViewDelegate:self];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
        [self.locationmanager startMonitoringForRegion:self.beacon];//开始MonitoringiBeacon
    }
}
- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationmanager requestStateForRegion:self.beacon];
}

-(void)locationManager:(CLLocationManager *)manager
        didEnterRegion:(CLRegion *)region{
    
    [self.locationmanager startRangingBeaconsInRegion:self.beacon];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            
            [self.locationmanager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
            NSLog(@"INSIDE the Region");//not logging
            break;
        case CLRegionStateOutside:
            NSLog(@"OUTSIDE the Region");
            break;
        case CLRegionStateUnknown:
        default:
            NSLog(@"Region state UNKNOWN!!!"); //Logging on console
            [self.locationmanager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
            break;
    }
}


-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if(beacons.count<=0)return;
    //    打印信息
    for (CLBeacon* beacon in beacons) {
        
        NSLog(@"rssi is :%ld",beacon.rssi);
        
        NSLog(@"beacon.proximity %ld",beacon.proximity);
        
        NSLog(@"beacon.major %@",beacon.major);
        
        NSLog(@"beacon.minor %@",beacon.minor);
        
    }
    self.dataArray = [NSMutableArray arrayWithArray:beacons];
    
}

#pragma mark -注册js方法

- (void)setUpAction
{
    // JS主动调用OjbC的方法
    [self.bridge registerHandler:@"getRegistInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            // 反馈给JS
            responseCallback(@{@"info": @"123456"});
        }
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}


@end
