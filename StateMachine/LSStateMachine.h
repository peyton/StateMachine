#import <Foundation/Foundation.h>
#import "LSStateMachineTypedefs.h"

@class LSEvent;
@class LSState;
@class LSTransition;

@interface LSStateMachine : NSObject
@property (nonatomic, strong, readonly) NSSet *states;
@property (nonatomic, strong, readonly) NSSet *events;
@property (nonatomic, strong) LSState *initialState;
- (void)initializeWithState:(NSString *)stateName;
- (void)addState:(NSString *)stateName;
- (void)when:(NSString *)eventName transitionFrom:(NSString *)fromName to:(NSString *)toName;
- (void)when:(NSString *)eventName transitionFrom:(NSString *)fromName to:(NSString *)toName if:(LSStateMachineTransitionCondition)condition;
- (LSState *)stateWithName:(NSString *)name;
- (LSEvent *)eventWithName:(NSString *)name;

- (void)fromState:(NSString *)stateName do:(LSStateMachineTransitionCallback)callback;
- (void)toState:(NSString *)stateName do:(LSStateMachineTransitionCallback)callback;

- (void)beforeEvent:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback;
- (void)afterEvent:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback;

- (LSTransition *)transitionFrom:(NSString *)fromName forEvent:(NSString *)eventName;

@property (nonatomic, assign) BOOL debug;

@end