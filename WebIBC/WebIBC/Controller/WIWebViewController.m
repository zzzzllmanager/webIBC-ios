//
//  WIWebViewController.m
//  WebIBC
//
//  Created by zhaole on 2017/4/24.
//  Copyright © 2017年 WEB. All rights reserved.
//

#import "WIWebViewController.h"

#import<CoreLocation/CoreLocation.h>

#import "BabyBluetooth.h"

#import "MJExtension.h"

#define WEB_URL @"http://api.minorfish.com/kjcmin/index.html"//自己的网址

#define BEACONUUID @"12334566-7173-4889-9579-954995439125"//iBeacon自己设备的uuid
@interface WIWebViewController ()<UIWebViewDelegate,CLLocationManagerDelegate>
{
    BabyBluetooth *baby;
}

@property (strong, nonatomic) CLBeaconRegion *beacon;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationmanager;

@property (nonatomic,strong)NSMutableArray * dataArray;

@property (nonatomic,strong)NSMutableArray * blueArray;

@property (nonatomic,strong)NSTimer * timer;

@property (nonatomic,strong)JSContext * context;

@property (nonatomic,weak)UIWebView * webView;

@end

@implementation WIWebViewController

-(NSMutableArray *)blueArray
{
    if(_blueArray == nil){
        _blueArray = [NSMutableArray array];
    }
    return _blueArray;
}

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
                NSInteger rssi = 0;
                for (NSDictionary * per in self.blueArray) {
                    if(per[@"identifier"] == beacon.proximityUUID){
                        rssi = [per[@"RSSI"] integerValue];
                        break;
                    }
                }
                
                [sendArray addObject:@{@"major":beacon.major,@"minor":beacon.minor,@"rssi":@(rssi)}];
            }
            if(self.context){
                NSString * str = [@{@"errMsg":@"ok",@"beacons":sendArray} mj_JSONString];
                
                NSString * sendString = [NSString stringWithFormat:@"leScanCallback('%@')",str];
                [self.context evaluateScript:sendString];
            }
        }
    }];
    
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];

    [baby cancelAllPeripheralsConnection];

    //设置蓝牙委托
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            //设备打开成功
        }
    }];
    //设置扫描到设备的委托
    __weak typeof(self) weakSelf = self;

    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        BOOL inArray = NO;
        
        NSDictionary * dic = @{@"identifier":peripheral.identifier,@"RSSI":RSSI};
        for (NSDictionary * per in weakSelf.blueArray) {
            if(per[@"identifier"] == peripheral.identifier){
                inArray = YES;
                break;
            }
        }
        if(!inArray){
            [weakSelf.blueArray addObject:dic];
        }
    }];
    
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin();

    
}

#pragma mark 加载webView

- (void)setUpWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView = webView;
    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    NSURL *url = [[NSURL alloc]initWithString:WEB_URL];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    self.context[@"JsInterface"] = self;
}

#pragma mark -js调oc方法
- (void)getRegistInfo:(NSString *)str
{
    
    
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


- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}


@end
