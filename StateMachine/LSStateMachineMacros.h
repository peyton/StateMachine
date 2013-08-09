#ifndef StateMachine_LSStateMachineMacros_h
#define StateMachine_LSStateMachineMacros_h
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "LSStateMachineDynamicAdditions.h"

#define STATE_MACHINE(definition) \
+ (LSStateMachine *)stateMachine {\
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        if ([[self superclass] respondsToSelector:@selector(stateMachine)]) \
            [[self superclass] performSelector:@selector(stateMachine) withObject:nil]; \
    }); \
    return LSStateMachineSetDefinitionForClass(self, definition);\
}\
+ (void) initialize {\
    LSStateMachineInitializeClass(self);\
}
#endif
