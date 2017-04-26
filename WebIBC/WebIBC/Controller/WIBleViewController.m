//
//  WIBleViewController.m
//  WebIBC
//
//  Created by zhaole on 2017/4/24.
//  Copyright © 2017年 WEB. All rights reserved.
//

#import "WIBleViewController.h"

#import<CoreLocation/CoreLocation.h>

#import<CoreLocation/CoreLocation.h>

#import "BabyBluetooth.h"

#define BEACONUUID @"12334566-7173-4889-9579-954995439125"//iBeacon自己设备的uuid

@interface WIBleViewController () <CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>{
    BabyBluetooth *baby;
}

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
    
    [self setUpNaVc];
    
    [self setUpTableview];
}

- (void)setUpNaVc
{

    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:@"开始搜索" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.locationmanager = [[CLLocationManager alloc] init];//初始化
    
    self.locationmanager.delegate = self;
    
    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许
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
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    CLBeacon* beacon = self.dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",beacon.proximity];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    
    [self.tableview reloadData];
}

- (void)rightItemClick
{
    
    self.beacon = [[CLBeaconRegion alloc]initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACONUUID] identifier:@"id"];
    self.beacon.notifyOnEntry=YES;
    self.beacon.notifyOnExit=YES;
    self.beacon.notifyEntryStateOnDisplay=YES;

    [self.locationmanager startMonitoringForRegion:self.beacon];
    
//    //初始化BabyBluetooth 蓝牙库
//    baby = [BabyBluetooth shareBabyBluetooth];
//    
//    [baby cancelAllPeripheralsConnection];
//    
//    //设置蓝牙委托
//    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
//        if (central.state == CBCentralManagerStatePoweredOn) {
//            //设备打开成功
//        }
//    }];
//    //设置扫描到设备的委托
//    __weak typeof(self) weakSelf = self;
//    
//    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
//        
//        if(peripheral.name == nil||[peripheral.name isEqualToString:@""]){
//            return;
//        }
//        NSLog(@"搜索到了设备:%@",peripheral.name);
//        BOOL inArray = NO;
//        for (CBPeripheral * per in weakSelf.dataArray) {
//            if(per.identifier == peripheral.identifier){
//                inArray = YES;
//                break;
//            }
//        }
//        if(!inArray){
//            [weakSelf.dataArray addObject:peripheral];
//            [weakSelf.tableview reloadData];
//        }
//    }];
//
//    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
//    baby.scanForPeripherals().begin();
}

@end
