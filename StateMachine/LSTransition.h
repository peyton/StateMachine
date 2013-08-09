#import <Foundation/Foundation.h>
#import "LSStateMachineTypedefs.h"
#import "LSState.h"

@interface LSTransition : NSObject
+ (id)transitionFrom:(LSState *)from to:(LSState *)to;
- (id)initFrom:(LSState *)from to:(LSState *)to;
- (BOOL)meetsCondition:(id)obj;
@property (nonatomic, copy, readonly) LSState *from;
@property (nonatomic, copy, readonly) LSState *to;
@property (nonatomic, copy) LSStateMachineTransitionCondition condition;
@end
