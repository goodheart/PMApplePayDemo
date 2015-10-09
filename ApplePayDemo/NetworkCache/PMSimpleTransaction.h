//
//  PMSimpleTransaction.h
//  Pocket48IOS
//
//  Created by majian on 15/10/9.
//  Copyright © 2015年 com.DuYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMSimpleTransaction : NSObject<NSCoding>

@property (nonatomic,copy) NSString * applepayId;
@property (nonatomic,copy) NSString * status;
@property (nonatomic,copy) NSString * money;
@property (nonatomic,copy) NSString * receipt;
@property (nonatomic,copy) NSString * transactionIdentifier;//订单唯一标识
@property (nonatomic,copy) NSString * url;

+ (id)simpleTransactionWithApplePayID:(NSString *)applepayID
                               status:(NSString *)status
                                money:(NSString *)money
                              receipt:(NSData *)receipt
                transactionIdentifier:(NSString *)transactionIdentifier
                                  URL:(NSString *)url;

- (NSDictionary *)toDictionary;

@end
