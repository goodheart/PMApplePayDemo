//
//  PMOrderExceptionMonitor.h
//  Pocket48IOS
//
//  Created by majian on 15/10/9.
//  Copyright © 2015年 com.DuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMSimpleTransaction.h"

@class PMTransactionExceptionMonitor;
@protocol PMOrderExceptionMonitorDelegate <NSObject>
//当前环境可以进行订单确认
- (void)transactionExceptionMonitor:(PMTransactionExceptionMonitor *)monitor
           handlePendingTransaction:(PMSimpleTransaction *)simpleTransaction complete:(void(^)(BOOL res,PMSimpleTransaction * simpleTransaction))complete;
@end

@interface PMTransactionExceptionMonitor : NSObject
/*
    订单成功--> 开始监听
    成功接收到服务器返回确认数据，无论订单是否伪造--> 结束监听
    进入支付页面时检查一下当前是否还有没确认的订单
*/
@property (nonatomic,weak) id<PMOrderExceptionMonitorDelegate> delegate;

- (void)toCompletePendingTransaction; //业务方进入支付页面时，执行该方法
- (void)startMoniteWithTransaction:(PMSimpleTransaction *)transaction;//收到苹果服务器完成订单时即开始监听
- (void)stopMoniteWithTransaction:(PMSimpleTransaction *)transaction;//自己公司服务器确认订单后停止监听

@end







