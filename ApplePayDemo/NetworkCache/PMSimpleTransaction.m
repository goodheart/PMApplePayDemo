//
//  PMSimpleTransaction.m
//  Pocket48IOS
//
//  Created by majian on 15/10/9.
//  Copyright © 2015年 com.DuYi. All rights reserved.
//

#import "PMSimpleTransaction.h"

static NSString * PMApplepayIdKey = @"applepayId";
static NSString * PMStatusKey = @"status";
static NSString * PMMoneyKey = @"money";
static NSString * PMReceiptKey = @"receipt";
static NSString * PMTransactionIdentifierKey = @"transactionIdentifierKey";
static NSString * PMURLKey = @"URLKey";

@interface PMSimpleTransaction ()

@end

@implementation PMSimpleTransaction
#pragma mark - Public Method
+ (id)simpleTransactionWithApplePayID:(NSString *)applepayID status:(NSString *)status money:(NSString *)money receipt:(NSData *)receipt transactionIdentifier:(NSString *)transactionIdentifier URL:(NSString *)url{
    PMSimpleTransaction * simpleTransaction = [[PMSimpleTransaction alloc] init];
    
    simpleTransaction.applepayId = applepayID;
    simpleTransaction.status = status;
    simpleTransaction.money = money;
    simpleTransaction.receipt = [NSString stringWithFormat:@"%@",receipt];
    simpleTransaction.transactionIdentifier = transactionIdentifier;
    simpleTransaction.url = url;
    
    return simpleTransaction;
}

- (NSDictionary *)toDictionary {
    return @{PMApplepayIdKey : self.applepayId,
             PMStatusKey : self.status,
             PMReceiptKey : self.receipt,
             PMMoneyKey : self.money};
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.applepayId = [aDecoder decodeObjectForKey:PMApplepayIdKey];
        self.status = [aDecoder decodeObjectForKey:PMStatusKey];
        self.money = [aDecoder decodeObjectForKey:PMMoneyKey];
        self.receipt = [aDecoder decodeObjectForKey:PMReceiptKey];
        self.transactionIdentifier = [aDecoder decodeObjectForKey:PMTransactionIdentifierKey];
        self.url = [aDecoder decodeObjectForKey:PMURLKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.applepayId forKey:PMApplepayIdKey];
    [aCoder encodeObject:self.status forKey:PMStatusKey];
    [aCoder encodeObject:self.money forKey:PMMoneyKey];
    [aCoder encodeObject:self.receipt forKey:PMReceiptKey];
    [aCoder encodeObject:self.transactionIdentifier forKey:PMTransactionIdentifierKey];
    [aCoder encodeObject:self.url forKey:PMURLKey];
}

@end





