//
//  ViewController.m
//  ApplePayDemo
//
//  Created by majian on 15/10/8.
//  Copyright © 2015年 majian. All rights reserved.
//

#import <PassKit/PassKit.h>
#import <StoreKit/StoreKit.h>
#import "ViewController.h"
#import "UIDevice+PMDevice.h"

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic,strong) NSOperationQueue * operationQueue;
@property (nonatomic,copy) NSString * networkCacheDirecotry;

/* Private Method */
- (void)getProductInfo;
- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
@end

@implementation ViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString * networkCacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"com.haoyi.webNetwork.cache"];
    self.networkCacheDirecotry = networkCacheDirectory;
    BOOL isDirectory = YES;
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:networkCacheDirectory isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:networkCacheDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 6;
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //监听购买结果
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

//应用内支付
- (IBAction)IAPAction:(id)sender {
    

    if ([[UIDevice currentDevice] isBrokedDevice]) {
        return;
    }
    
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"可以进行应用内支付");
        //获取商品信息
        [self getProductInfo];
    } else {
        NSLog(@"禁止应用内支付");
    }
}

#pragma mark - Private Method
- (void)getProductInfo {
    //通过productID向AppStore查询，活的SKPayment实例，然后通过SKPaymentQueue的addPayment方法发起一个购买操作.
    //以下的ProductID应该是事先在intunesConnect中添加好的，已存在的付费项目，否则查询失败
    NSSet * set = [NSSet setWithArray:@[@"ProductID"]];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSString * productID = transaction.payment.productIdentifier;
//    NSString * receipt = [[NSBundle mainBundle] appStoreReceiptURL];
    NSString * receipt = @"";
    if (productID.length > 0) {
        //向自己服务器验证购买凭证
        //购买成功，需要将凭证发送到服务器进行验证。考虑到网络异常情况，iOS端的发送凭证操作应该进行持久化，如果程序退出，崩溃或网络异常，可以回复重试
        //服务器的工作，分4步：
        /*
            1、接收iOS端发过来的购买凭证
            2、判断凭证是否已经存在或验证过，然后存储该凭证
            3、将该凭证发送到苹果的服务器验证，并将验证结果返回给客户端
            4、如果需要，修改用户相应的会员权限
            考虑到网络异常情况，服务器的验证应该是一个可回复的队列，如果网络失败了，应该进行重试。
         苹果的验证接口文档地址：https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40008267-CH104-SW3
            将该购买凭证用Base64编码，然后POST给苹果的验证服务器，苹果将验证结果以JSON形式返回
         
         苹果AppStore线上的购买凭证验证地址是https://buy.itunes.apple.com/verifyReceipt ，测试的验证地址是：https://sandbox.itunes.apple.com/verifyReceipt
         */
    }
    
    //移除transaction
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"购买失败");
    } else {
        NSLog(@"用户取消交易");
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    //对于已购商品，处理恢复购买的逻辑
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray<SKProduct *> * productArrayI = response.products;
    if (0 == productArrayI.count) {
        NSLog(@"无法获取产品信息，购买失败");
        return;
    }
    
    SKPayment * payment = [SKPayment paymentWithProduct:[productArrayI firstObject]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"transactionIdentifier = %@",transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
                case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
                case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
                case SKPaymentTransactionStatePurchasing://商品添加进列表
                NSLog(@"商品添加进列表");
                break;
                case SKPaymentTransactionStateDeferred: //延迟付款
                NSLog(@"延迟付款");
                break;
            default:
                break;
        }
    }
}

//苹果支付
- (IBAction)applePayAction:(id)sender {
    //确认设备是否支持Apple Pay
    if ([PKPaymentAuthorizationViewController canMakePayments]) {
        
        NSLog(@"支持Apple Pay");
        
        PKPaymentRequest * request = [[PKPaymentRequest alloc] init];
        
        
        PKPaymentSummaryItem *widget1 = [PKPaymentSummaryItem summaryItemWithLabel:@"Widget 1"
                                                                            amount:[NSDecimalNumber decimalNumberWithString:@"0.99"]];
        
        PKPaymentSummaryItem *widget2 = [PKPaymentSummaryItem summaryItemWithLabel:@"Widget 2"
                                                                            amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]];
        
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total"
                                                                          amount:[NSDecimalNumber decimalNumberWithString:@"1.99"]];
        
        request.paymentSummaryItems = @[widget1, widget2, total];

        
        request.countryCode = @"CN";
        request.currencyCode = @"USD";
        request.supportedNetworks = @[PKPaymentNetworkAmex,PKPaymentNetworkMasterCard,PKPaymentNetworkVisa];
        request.merchantCapabilities = PKMerchantCapabilityEMV;
        request.merchantIdentifier = @"merchant.com.haoyi.ApplePayDemo";
        
        PKPaymentAuthorizationViewController * paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentPane.delegate = self;
        
        [self presentViewController:paymentPane animated:YES completion:nil];
    } else {
        NSLog(@"该设备不支持apple Pay");
    }
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    completion(PKPaymentAuthorizationStatusSuccess);
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentAuthorizationViewControllerWillAuthorizePayment:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"WillAuthorizePayment");
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                    didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod
                                completion:(void (^)(NSArray<PKPaymentSummaryItem *> *summaryItems))completion {
    NSLog(@"didSelectPaymentMethod : %@",paymentMethod);
    PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"apple"
            amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d",arc4random() % 100]]];
    completion(@[total]);
}





@end
















