//
//  WIWebViewController.h
//  WebIBC
//
//  Created by zhaole on 2017/4/24.
//  Copyright © 2017年 WEB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJSExport <JSExport>
//JSExportAs
//(calculateForJS  /** handleFactorialCalculateWithNumber 作为js方法的别名 */,
// - (void)handleFactorialCalculateWithNumber:(NSNumber *)number
// );
- (void)getRegistInfo:(NSString *)str;

@end

@interface WIWebViewController : UIViewController<TestJSExport>

@end
