#import <Foundation/Foundation.h>
#import "LSStateMachineTypedefs.h"

@class LSEvent;
@class LSState;
@class LSTransition;

@interface LSStateMachine : NSObject
@property (nonatomic, strong, readonly) NSSet *states;
@property (nonatomic, strong, readonly) NSSet *events;
@property (nonatomic, strong) LSState *initialState;
- (void)setInitialStateName:(NSString *)stateName;
- (void)addState:(NSString *)stateName;
- (void)when:(NSString *)eventName transitionFrom:(NSString *)fromName to:(NSString *)toName;
- (void)when:(NSString *)eventName transitionFrom:(NSString *)fromName to:(NSString *)toName if:(LSStateMachineTransitionCondition)condition;
- (LSState *)stateWithName:(NSString *)name;
- (LSEvent *)eventWithName:(NSString *)name;

- (void)from:(NSString *)stateName do:(LSStateMachineTransitionCallback)callback;
- (void)to:(NSString *)stateName do:(LSStateMachineTransitionCallback)callback;

- (void)before:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback;
- (void)after:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback;

- (LSTransition *)transitionFrom:(LSState *)from forEvent:(NSString *)eventName;

@end