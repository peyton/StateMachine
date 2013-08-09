#import "NSString+Capitalize.h"

#import "LSStateMachineDynamicAdditions.h"
#import "LSStateMachine.h"
#import "LSEvent.h"
#import "LSTransition.h"

#import <objc/runtime.h>

extern void * LSStateMachineDefinitionKey;

BOOL LSStateMachineTriggerEvent(id self, SEL _cmd);
void LSStateMachineInitializeInstance(id self, SEL _cmd);

// This is the implementation of all the event instance methods
BOOL LSStateMachineTriggerEvent(id self, SEL _cmd) {
    LSState *currentState = [self performSelector:@selector(state)];
    LSStateMachine *sm = [[self class] performSelector:@selector(stateMachine)];
    NSString *eventName = NSStringFromSelector(_cmd);
    
    SEL canPerformEventQuery = NSSelectorFromString([NSString stringWithFormat:@"can%@", [eventName initialCapital]]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    BOOL canPerformEvent = [self performSelector:canPerformEventQuery withObject:nil];
#pragma clang diagnostic pop
    LSTransition *transition = [sm transitionFrom:currentState.name forEvent:eventName];
    
    if (transition && canPerformEvent) {
        LSState *fromState = [sm stateWithName:transition.from];
        LSState *toState = [sm stateWithName:transition.to];
        
        if (sm.debug)
        {
            NSLog(@"Transitioning from %@ to %@:\n%@\n%@", transition.from, transition.to, fromState, toState);
        }
        
        NSArray *fromCallbacks = fromState.fromCallbacks;
        for (void(^fromCallback)(id) in fromCallbacks) {
            fromCallback(self);
        }
        
        LSEvent *event = [sm eventWithName:eventName];
        NSArray *beforeCallbacks = event.beforeCallbacks;
        for (void(^beforeCallback)(id) in beforeCallbacks) {
            beforeCallback(self);
        }
        
        [self performSelector:@selector(setState:) withObject:toState];
        
        NSArray *afterCallbacks = event.afterCallbacks;
        for (LSStateMachineTransitionCallback afterCallback in afterCallbacks) {
            afterCallback(self);
        }
        
        NSArray *toCallbacks = toState.toCallbacks;
        for (void(^toCallback)(id) in toCallbacks) {
            toCallback(self);
        }
        return YES;
    } else {
        if (sm.debug)
        {
            NSLog(@"No transition from %@ for event %@", currentState.name, eventName);
        }
        
        return NO;
    }
}

// This is the implementation of the initializeStateMachine instance method
void LSStateMachineInitializeInstance(id self, SEL _cmd) {
    LSStateMachine *sm = [[self class] performSelector:@selector(stateMachine)];
    [self performSelector:@selector(setState:) withObject:[sm initialState]];
}

// This is the implementation of all the is<StateName> instance methods
BOOL LSStateMachineCheckState(id self, SEL _cmd) {
    LSState *currentState = [self performSelector:@selector(state)];
    NSString *query = [[NSStringFromSelector(_cmd) substringFromIndex:2] initialLowercase];
    return [query isEqualToString:currentState.name];
}

// This is the implementation of all the can<EventName> instance methods
BOOL LSStateMachineCheckCanTransition(id self, SEL _cmd) {
    LSStateMachine *sm = [[self class] performSelector:@selector(stateMachine)];
    LSState *currentState = [self performSelector:@selector(state)];
    NSString *query = [[NSStringFromSelector(_cmd) substringFromIndex:3] initialLowercase];
    LSTransition *transition = [sm transitionFrom:currentState.name forEvent:query];
    return transition != nil && [transition meetsCondition:self];
}

// This is called in the initilize class method in the STATE_MACHINE macro
void LSStateMachineInitializeClass(Class klass) {
    LSStateMachine *sm = [klass performSelector:@selector(stateMachine)];
    for (LSEvent *event in sm.events) {
        class_addMethod(klass, NSSelectorFromString(event.name), (IMP) LSStateMachineTriggerEvent, "i@:");
        
        NSString *transitionQueryMethodName = [NSString stringWithFormat:@"can%@", [event.name initialCapital]];
        class_addMethod(klass, NSSelectorFromString(transitionQueryMethodName), (IMP) LSStateMachineCheckCanTransition, "i@:");
    }
    
    for (LSState *state in sm.states) {
        NSString *queryMethodName = [NSString stringWithFormat:@"is%@", [state.name initialCapital]];
        class_addMethod(klass, NSSelectorFromString(queryMethodName), (IMP) LSStateMachineCheckState, "i@:");
    }
    class_addMethod(klass, @selector(initializeStateMachine), (IMP) LSStateMachineInitializeInstance, "v@:");
}

// This is called in the stateMachine class method defined by the STATE_MACHINE macro
LSStateMachine * LSStateMachineSetDefinitionForClass(Class klass,void(^definition)(LSStateMachine *)) {
    LSStateMachine *sm = (LSStateMachine *)objc_getAssociatedObject(klass, &LSStateMachineDefinitionKey);
    if (!sm) {
        sm = [[LSStateMachine alloc] init];
        objc_setAssociatedObject (
                                  klass,
                                  &LSStateMachineDefinitionKey,
                                  sm,
                                  OBJC_ASSOCIATION_RETAIN
                                  );
    }
    [sm configureWithDefinition:definition forClass:klass];
    return sm;
    
}