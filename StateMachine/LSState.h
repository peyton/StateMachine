//
//  LSState.h
//  StateMachine
//
//  Created by Peyton Randolph on 8/8/13.
//  Copyright (c) 2013 Luis Solano Bonet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSStateMachineTypedefs.h"


@interface LSState : NSObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) NSArray *fromCallbacks;
@property (nonatomic, copy, readonly) NSArray *toCallbacks;

+ (instancetype)stateWithSelector:(SEL)selector;
+ (instancetype)stateWithName:(NSString *)name;
- (id)initWithName:(NSString *)name;

+ (instancetype)stateWithName:(NSString *)name fromCallbacks:(NSArray *)fromCallbacks toCallbacks:(NSArray *)toCallbacks;
- (id)initWithName:(NSString *)name fromCallbacks:(NSArray *)fromCallbacks toCallbacks:(NSArray *)toCallbacks;

- (instancetype)addFromCallback:(LSStateMachineTransitionCallback)fromCallback;
- (instancetype)addToCallback:(LSStateMachineTransitionCallback)toCallback;

@end

#define state(name) try{} @finally([LSState stateWithSelector:@selector([NSString stringWithFormat:@"is%@", [@name initialCapital]])])
