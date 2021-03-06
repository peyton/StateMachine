#import "LSStateMachine.h"
#import "LSEvent.h"
#import "LSTransition.h"
#import "LSStateMachineTypedefs.h"

void * LSStateMachineDefinitionKey = &LSStateMachineDefinitionKey;

@interface LSStateMachine ()
- (LSEvent *)eventWithName:(NSString *)name;
@end

@interface LSStateMachine ()
@property (nonatomic, strong) NSMutableSet *mutableStates;
@property (nonatomic, strong) NSMutableSet *mutableEvents;
@property (nonatomic, strong) NSMutableSet *configuredClasses;
@end
@implementation LSStateMachine
- (id)init {
    self = [super init];
    if (self) {
        _mutableStates = [[NSMutableSet alloc] init];
        _mutableEvents = [[NSMutableSet alloc] init];
        _configuredClasses = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)configureWithDefinition:(void(^)(LSStateMachine *))definition forClass:(Class)klass;
{
    if (![self.configuredClasses containsObject:klass])
    {
        [self.configuredClasses addObject:klass];
        definition(self);
    }
}

#pragma mark - State creation

- (void)addState:(NSString *)stateName {
    LSState *state = [LSState stateWithName:stateName];
    [self.mutableStates addObject:state];
    if (!self.initialState) {
        self.initialState = state;
    }
}

- (void)initializeWithState:(NSString *)stateName;
{
    LSState *state = [LSState stateWithName:stateName];
    self.initialState = state;
}

#pragma mark - Event creation

- (void)when:(NSString *)eventName transitionFrom:(NSString *)fromName to:(NSString *)toName;
{
    [self when:eventName transitionFrom:fromName to:toName if:nil];
}

- (void)when:(NSString *)eventName transitionFrom:(NSString *)fromName to:(NSString *)toName if:(LSStateMachineTransitionCondition)condition; {
    LSState *from = [self stateWithName:fromName];
    LSState *to = [self stateWithName:toName];
    if (!(from && to)) return;
    
    LSEvent *event = [self eventWithName:eventName];
    LSTransition *transition = [LSTransition transitionFrom:fromName to:toName];
    transition.condition = condition;
    if (!event) {
        event = [LSEvent eventWithName:eventName transitions:[NSSet setWithObject:transition]];
    } else {
        [self.mutableEvents removeObject:event];
        event = [event addTransition:transition];
    }
    [self.mutableEvents addObject:event];
}

#pragma mark - State callbacks

- (void)fromState:(NSString *)stateName do:(LSStateMachineTransitionCallback)callback;
{
    LSState *oldState = [self stateWithName:stateName];
    [self.mutableStates removeObject:oldState];
    LSState *newState = [oldState addFromCallback:callback];
    [self.mutableStates addObject:newState];
}

- (void)toState:(NSString *)stateName do:(LSStateMachineTransitionCallback)callback;
{
    LSState *oldState = [self stateWithName:stateName];
    [self.mutableStates removeObject:oldState];
    LSState *newState = [oldState addToCallback:callback];
    [self.mutableStates addObject:newState];
}

#pragma mark - Event callbacks

- (void)beforeEvent:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback {
    LSEvent *oldEvent = [self eventWithName:eventName];
    [self.mutableEvents removeObject:oldEvent];
    LSEvent *newEvent = [oldEvent addBeforeCallback:callback];
    [self.mutableEvents addObject:newEvent];
}

- (void)afterEvent:(NSString *)eventName do:(LSStateMachineTransitionCallback)callback {
    LSEvent *oldEvent = [self eventWithName:eventName];
    [self.mutableEvents removeObject:oldEvent];
    LSEvent *newEvent = [oldEvent addAfterCallback:callback];
    [self.mutableEvents addObject:newEvent];
}

#pragma mark - Collection convenience

- (void)fromStates:(NSArray *)stateNames do:(LSStateMachineTransitionCallback)callback;
{
    for (NSString *stateName in stateNames)
        [self fromState:stateName do:callback];
}

- (void)toStates:(NSArray *)stateNames do:(LSStateMachineTransitionCallback)callback;
{
    for (NSString *stateName in stateNames)
        [self toState:stateName do:callback];
}

- (void)beforeEvents:(NSArray *)eventNames do:(LSStateMachineTransitionCallback)callback;
{
    for (NSString *eventName in eventNames)
        [self beforeEvent:eventName do:callback];
}

- (void)afterEvents:(NSArray *)eventNames do:(LSStateMachineTransitionCallback)callback;
{
    for (NSString *eventName in eventNames)
        [self afterEvent:eventName do:callback];
}

#pragma mark - Getters and setters

- (NSSet *)states {
    return [NSSet setWithSet:self.mutableStates];
}

- (NSSet *)events {
    return [NSSet setWithSet:self.mutableEvents];
}

- (void)setInitialState:(LSState *)defaultState {
    [self willChangeValueForKey:@"initialState"];
    _initialState = defaultState;
    [self.mutableStates addObject:defaultState];
    [self didChangeValueForKey:@"initialState"];
}

- (LSState *)stateWithName:(NSString *)name;
{
    for (LSState *state in self.states)
        if ([state.name isEqualToString:name])
            return state;
    return nil;
}

- (LSEvent *)eventWithName:(NSString *)name {
    for (LSEvent *event in self.events) {
        if ([event.name isEqualToString:name])
            return event;
    }
    return nil;
}

- (LSTransition *)transitionFrom:(NSString *)fromName forEvent:(NSString *)eventName;
{
    LSEvent *event = [self eventWithName:eventName];
    for (LSTransition *transition in event.transitions) {
        if ([transition.from isEqual:fromName]) {
            return transition;
        }
    }
    return nil;
}

@end
