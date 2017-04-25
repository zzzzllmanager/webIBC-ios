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

@interface WIBleViewController () <CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CLBeaconRegion *beacon;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationmanager;

@property (nonatomic, strong) CBCentralManager *manager;

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
    
    [self setUpTableview];
}

#pragma mark 初始化蓝牙设备
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if(indexPath.row == 0){
    
        cell.textLabel.text = @"点击搜索设备";
    }else{
        cell.textLabel.text = @"点击获取设备需要信息";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }else{
    
        [self.manager stopScan];
        self.locationmanager = [[CLLocationManager alloc] init];//初始化
        
        self.locationmanager.delegate = self;
    
        [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许
    }
}

//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
//            蓝牙已打开
            [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        }
            break;
        case CBCentralManagerStatePoweredOff:
//            蓝牙没有打开,请先打开蓝牙
            break;
        default:
            break;
    }
}

//查到外设后，停止扫描，连接设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%@",[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData]);
    
    BOOL inArray = NO;
    
    for (CBPeripheral * per in self.dataArray) {
        if(per.identifier == peripheral.identifier){
            inArray = YES;
            break;
        }
    }
    if(!inArray){
        [self.dataArray addObject:peripheral];
    }
}

- (void)startMonitoringForRegionWithPer:(CBPeripheral*)per
{
    CLBeaconRegion * beacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[per.identifier UUIDString]] identifier:@"media"];//初始化监测的iBeacon信息
    [self.locationmanager startMonitoringForRegion:beacon];
}

- (void)startRangingBeaconsInRegionWithPer:(CBPeripheral*)per
{
    CLBeaconRegion * beacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[per.identifier UUIDString]] identifier:@"media"];//初始化监测的iBeacon信息
    [self.locationmanager startRangingBeaconsInRegion:beacon];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        //开始
        for (CBPeripheral * per in self.dataArray) {
            [self startMonitoringForRegionWithPer:per];
        }
    }
}

//发现有iBeacon进入监测范围
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    for (CBPeripheral * per in self.dataArray) {
        [self startRangingBeaconsInRegionWithPer:per];
    }
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
