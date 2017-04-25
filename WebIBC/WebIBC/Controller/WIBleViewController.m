//
//  WIBleViewController.m
//  WebIBC
//
//  Created by zhaole on 2017/4/24.
//  Copyright © 2017年 WEB. All rights reserved.
//

#import "WIBleViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface WIBleViewController () <CBCentralManagerDelegate, CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;

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
}

#pragma mark 初始化蓝牙设备
- (void)setUpManager
{
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
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
    CBPeripheral * lbc = self.dataArray[indexPath.row];
    cell.textLabel.text = lbc.name;
    return cell;
}


//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
        //@"蓝牙已打开,请扫描外设"
            [_manager scanForPeripheralsWithServices:nil  options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        }
            break;
        case CBCentralManagerStatePoweredOff:
        //@"蓝牙没有打开,请先打开蓝牙"
            break;
        default:
            break;
    }
}

//查到外设后
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if (peripheral.name != nil&&peripheral.isAccessibilityElement == NO) {
        NSLog(@"%@", [NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData]);
        
        if(self.dataArray.count == 0){
            [self.dataArray addObject:peripheral];
        }else{
            BOOL isArrayModel = NO;
            for (CBPeripheral * lbc in self.dataArray) {
                if(lbc.identifier == peripheral.identifier){
                    isArrayModel = YES;
                    break;
                }
            }
            if(!isArrayModel){
                [self.dataArray addObject:peripheral];
            }
        }
        [self.tableview reloadData];
    }

}

@end
