#import <Foundation/Foundation.h>
#import "LSStateMachineTypedefs.h"
#import "LSEvent.h"
#import "LSState.h"
#import "LSTransition.h"

@class LSEvent;
@class LSTransition;

@interface LSStateMachine : NSObject
@property (nonatomic, strong, readonly) NSSet *states;
@property (nonatomic, strong, readonly) NSSet *events;
@property (nonatomic, strong) LSState *initialState;
- (void)addState:(LSState *)state;
- (void)when:(NSString *)eventName transitionFrom:(LSState *)from to:(LSState *)to;
- (void)when:(NSString *)eventName transitionFrom:(LSState *)from to:(LSState *)to if:(LSStateMachineTransitionCondition)condition;
- (LSState *)stateWithName:(NSString *)name;
- (LSEvent *)eventWithName:(NSString *)name;

- (void)from:(LSState *)state do:(LSStateMachineTransitionCallback)callback;
- (void)to:(LSState *)state do:(LSStateMachineTransitionCallback)callback;

- (void)before:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback;
- (void)after:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback;

- (LSTransition *)transitionFrom:(LSState *)from forEvent:(NSString *)eventName;

@end