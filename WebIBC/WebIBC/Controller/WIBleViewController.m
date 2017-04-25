//
//  WIBleViewController.m
//  WebIBC
//
//  Created by zhaole on 2017/4/24.
//  Copyright © 2017年 WEB. All rights reserved.
//

#import "WIBleViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import<CoreLocation/CoreLocation.h>

#import<CoreLocation/CoreLocation.h>

#define BEACONUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]//iBeacon自己设备的uuid

@interface WIBleViewController () <CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) CLBeaconRegion *beacon;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationmanager;

@property (nonatomic,weak)UITableView * tableview;

@property (nonatomic,strong)NSMutableArray * dataArray;

@end

@implementation WIBleViewController

-(NSMutableArray *)dataArray
{
    if(_dataArray == nil){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpManager];
    
    [self setUpTableview];
    
    NSLog(@"%@",BEACONUUID);
}

#pragma mark 初始化蓝牙设备
- (void)setUpManager
{
    self.locationmanager = [[CLLocationManager alloc] init];//初始化
    
    self.locationmanager.delegate = self;
    
    self.beacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACONUUID] identifier:@"media"];//初始化监测的iBeacon信息
    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许
}

- (void)setUpTableview
{
    UITableView * tableview = [[UITableView alloc]initWithFrame:self.view.bounds];
    tableview.tableFooterView = [[UIView alloc]init];
    tableview.delegate = self;
    tableview.dataSource = self;
    self.tableview = tableview;
    [self.view addSubview:tableview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }   
    return cell;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationmanager startMonitoringForRegion:self.beacon];//开始
    }
}

//发现有iBeacon进入监测范围
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [self.locationmanager startRangingBeaconsInRegion:self.beacon];//开始RegionBeacons
}

//找的iBeacon后扫描它的信息
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{

//    打印信息
    
    for (CLBeacon* beacon in beacons) {
        
        NSLog(@"rssi is :%ld",beacon.rssi);
        
        NSLog(@"beacon.proximity %ld",beacon.proximity);
        
        NSLog(@"beacon.major %@",beacon.major);
        
        NSLog(@"beacon.minor %@",beacon.minor);
    }
}

@end
