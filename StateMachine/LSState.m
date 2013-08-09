//
//  LSState.m
//  StateMachine
//
//  Created by Peyton Randolph on 8/8/13.
//  Copyright (c) 2013 Luis Solano Bonet. All rights reserved.
//

#import "LSState.h"

@implementation LSState

#pragma mark - Initialization

+ (instancetype)stateWithSelector:(SEL)selector;
{
    return [self stateWithName:[NSStringFromSelector(selector) substringFromIndex:1]];
}

+ (instancetype)stateWithName:(NSString *)name;
{
    return [[self alloc] initWithName:name];
}
- (id)initWithName:(NSString *)name;
{
    if (!(self = [self init]))
        return nil;
    
    _name = [name copy];
    
    return self;
}

+ (instancetype)stateWithName:(NSString *)name fromCallbacks:(NSArray *)fromCallbacks toCallbacks:(NSArray *)toCallbacks;
{
    return [[self alloc] initWithName:name fromCallbacks:fromCallbacks toCallbacks:toCallbacks];
}
- (id)initWithName:(NSString *)name fromCallbacks:(NSArray *)fromCallbacks toCallbacks:(NSArray *)toCallbacks;
{
    if (!(self = [self initWithName:name]))
        return nil;
    
    _fromCallbacks = [fromCallbacks copy];
    _toCallbacks = toCallbacks;
    
    return self;
}

- (instancetype)addFromCallback:(LSStateMachineTransitionCallback)fromCallback;
{
    return [[[self class] alloc] initWithName:self.name fromCallbacks:[self.fromCallbacks arrayByAddingObject:fromCallback] toCallbacks:self.toCallbacks];
}

- (instancetype)addToCallback:(LSStateMachineTransitionCallback)toCallback;
{
    return [[[self class] alloc] initWithName:self.name fromCallbacks:self.fromCallbacks toCallbacks:[self.toCallbacks arrayByAddingObject:toCallback]];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![self isMemberOfClass:[object class]]) {
        return NO;
    }
    LSState *other = (LSState *)object;
    if (![self.name isEqualToString:other.name]) {
        return NO;
    }

    return YES;
}

- (NSUInteger) hash {
    NSUInteger result = 17;
    result = 31 * result + self.name.hash;
    return result;
}

@end
