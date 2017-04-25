//
//  WIHomeViewController.m
//  WebIBC
//
//  Created by zhaole on 2017/4/25.
//  Copyright © 2017年 WEB. All rights reserved.
//

#import "WIHomeViewController.h"


#import "WIBleViewController.h"

#import "WIWebViewController.h"

@interface WIHomeViewController ()

@end

@implementation WIHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavtion];
    
    [self setUpSubViews];
}

- (void)setUpNavtion
{
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setUpSubViews
{
    UIButton * webButton = [[UIButton alloc]init];
    [webButton addTarget:self action:@selector(webButtonClick) forControlEvents:UIControlEventTouchUpInside];
    webButton.backgroundColor = [UIColor blueColor];
    webButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [webButton setTitle:@"web" forState:UIControlStateNormal];
    [self.view addSubview:webButton];
    
    [webButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(200);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];

    UIButton * IBCButton = [[UIButton alloc]init];
    
    [IBCButton addTarget:self action:@selector(IBCButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    IBCButton.backgroundColor = [UIColor blueColor];
    IBCButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [IBCButton setTitle:@"蓝牙" forState:UIControlStateNormal];
    [self.view addSubview:IBCButton];
    
    [IBCButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(webButton.mas_bottom).offset(30);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];

}

- (void)IBCButtonClick
{
    WIBleViewController * bleVC = [[WIBleViewController alloc]init];
    [self.navigationController pushViewController:bleVC animated:YES];
}

- (void)webButtonClick
{
    WIWebViewController * bleVC = [[WIWebViewController alloc]init];
    [self.navigationController pushViewController:bleVC animated:YES];
}

@end
