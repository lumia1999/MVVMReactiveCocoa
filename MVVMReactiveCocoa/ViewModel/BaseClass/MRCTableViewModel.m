//
//  MRCTableViewModel.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 14/12/27.
//  Copyright (c) 2014年 leichunfeng. All rights reserved.
//

#import "MRCTableViewModel.h"

@interface MRCTableViewModel ()

@property (strong, nonatomic, readwrite) RACCommand *requestRemoteDataCommand;

@end

@implementation MRCTableViewModel

- (void)initialize {
    [super initialize];
    
    @weakify(self)
    self.requestRemoteDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [[self requestRemoteDataSignal] takeUntil:self.willDisappearSignal];
    }];
    
    RAC(self, shouldDisplayEmptyDataSet) = [RACSignal
        combineLatest:@[ self.requestRemoteDataCommand.executing, RACObserve(self, dataSource) ]
        reduce:^id(NSNumber *executing, NSArray *dataSource) {
            RACSequence *sequenceOfSequences = [dataSource.rac_sequence map:^id(NSArray *array) {
                NSParameterAssert([array isKindOfClass:[NSArray class]]);
                return array.rac_sequence;
            }];
            return @(!executing.boolValue && sequenceOfSequences.flatten.array.count == 0);
        }];
    
    [self.requestRemoteDataCommand.errors subscribe:self.errors];
}


- (RACSignal *)requestRemoteDataSignal {
    return [RACSignal empty];
}

@end
