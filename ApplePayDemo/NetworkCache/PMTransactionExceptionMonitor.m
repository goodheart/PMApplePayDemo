//
//  PMOrderExceptionMonitor.m
//  Pocket48IOS
//
//  Created by majian on 15/10/9.
//  Copyright © 2015年 com.DuYi. All rights reserved.
//

#import "PMTransactionExceptionMonitor.h"

static NSString * PMTransactionExtension = @"pmtransactionexceptionmonitor";

@interface PMTransactionExceptionMonitor ()
/* Private Property */
@property (nonatomic,copy) NSString * transactionCacheDirectory;

/* Private Method */
- (NSArray *)pendingTransaction;//检查是否有还没确认的订单
@end

@implementation PMTransactionExceptionMonitor

#pragma mark - Public Method

//业务方进入支付页面时，执行该方法
- (void)toCompletePendingTransaction {
    NSArray * pendingTransactionArrayI = [self pendingTransaction];
    if (pendingTransactionArrayI.count <= 0) {
        return;
    }
    
    if (nil == self.delegate) {
        return;
    }
    
    if (![self.delegate respondsToSelector:@selector(transactionExceptionMonitor:handlePendingTransaction:complete:)]) {
        return;
    }
    
    for (NSString * pendingTransactionFileName in pendingTransactionArrayI) {
        NSString * pendingTransactionFilePath = [self.transactionCacheDirectory stringByAppendingPathComponent:pendingTransactionFileName];
        PMSimpleTransaction * transaction = [NSKeyedUnarchiver unarchiveObjectWithFile:pendingTransactionFilePath];
        
        [self.delegate transactionExceptionMonitor:self handlePendingTransaction:transaction complete:^(BOOL res, PMSimpleTransaction *simpleTransaction) {
            if (YES == res) {
                [self stopMoniteWithTransaction:simpleTransaction];
            }
        }];
    }
}

//收到苹果服务器完成订单时即开始监听
- (void)startMoniteWithTransaction:(PMSimpleTransaction *)transaction {
    //取transactionIdentifier作为文件名，可以防止文件名重复,格式是：1000000175159215
    //为了确保是transaction,在identifier后面加上标识符
    NSString * fileName = [transaction.transactionIdentifier stringByAppendingString:PMTransactionExtension];
    NSString * filePath = [self.transactionCacheDirectory stringByAppendingPathComponent:fileName];
    
    //先把已经存在的文件删除
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        return;
    }
    
    [NSKeyedArchiver archiveRootObject:transaction toFile:filePath];
}

//自己公司服务器确认订单后停止监听
- (void)stopMoniteWithTransaction:(PMSimpleTransaction *)transaction {
    NSString * fileName = [transaction.transactionIdentifier stringByAppendingString:PMTransactionExtension];
    NSString * filePath = [self.transactionCacheDirectory stringByAppendingPathComponent:fileName];
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath
                                             isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

#pragma mark - Private Method
//获取还没确认的订单文件名
- (NSArray *)pendingTransaction {
    NSArray<NSString *> * fileArrayI = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.transactionCacheDirectory error:nil];
    
    NSArray<NSString *> * pendingTransactionArrayI = [fileArrayI filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *  _Nonnull fileName, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [fileName rangeOfString:PMTransactionExtension].location != NSNotFound;
    }]];
    
    return pendingTransactionArrayI;
}

#pragma mark - Lazy Initialization
- (NSString *)transactionCacheDirectory {
    if (_transactionCacheDirectory) {
        return _transactionCacheDirectory;
    }
    
    NSString * sysCacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    _transactionCacheDirectory = [sysCacheDirectory stringByAppendingPathComponent:@"com.DuYi.SNH48.Transaction.cache"];
    BOOL isDirectory = YES;
    //没有缓存位置就创建
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:_transactionCacheDirectory
                                                   isDirectory:&isDirectory]) {
        //如果没有创建成功，则下次需要重新创建
        if (NO == [[NSFileManager defaultManager] createDirectoryAtPath:_transactionCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            _transactionCacheDirectory = nil;
        }
    }
    
    return _transactionCacheDirectory;
}


@end




