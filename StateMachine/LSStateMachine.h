#import <Foundation/Foundation.h>
#import "LSStateMachineTypedefs.h"

@class LSEvent;
@class LSState;
@class LSTransition;

@interface LSStateMachine : NSObject
@property (nonatomic, strong, readonly) NSSet *states;
@property (nonatomic, strong, readonly) NSSet *events;
@property (nonatomic, strong) LSState *initialState;

/* Configuration */
- (void)configureWithDefinition:(void(^)(LSStateMachine *))definition forClass:(Class)klass;

/* State creation */
- (void)initializeWithState:(NSString *)stateName;
- (void)addState:(NSString *)stateName;

/* Event creation */
- (void)when:(NSString *)eventName transitionFrom:(NSString *)fromName to:(NSString *)toName;
- (void)when:(NSString *)eventName transitionFrom:(NSString *)fromName to:(NSString *)toName if:(LSStateMachineTransitionCondition)condition;

/* State callbacks */
- (void)fromState:(NSString *)stateName do:(LSStateMachineTransitionCallback)callback;
- (void)toState:(NSString *)stateName do:(LSStateMachineTransitionCallback)callback;

/* Event callbacks */
- (void)beforeEvent:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback;
- (void)afterEvent:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback;

/* Collection convenience */
- (void)fromStates:(NSArray *)stateNames do:(LSStateMachineTransitionCallback)callback;
- (void)toStates:(NSArray *)stateNames do:(LSStateMachineTransitionCallback)callback;
- (void)beforeEvents:(NSArray *)eventNames do:(LSStateMachineTransitionCallback)callback;
- (void)afterEvents:(NSArray *)eventNames do:(LSStateMachineTransitionCallback)callback;

/* Accessors */
- (LSState *)stateWithName:(NSString *)name;
- (LSEvent *)eventWithName:(NSString *)name;
- (LSTransition *)transitionFrom:(NSString *)fromName forEvent:(NSString *)eventName;

/* Debug */
@property (nonatomic, assign) BOOL debug;

@end