#import <Foundation/Foundation.h>
#import "LSStateMachineTypedefs.h"
#import "LSState.h"

@interface LSTransition : NSObject
+ (instancetype)transitionFrom:(NSString *)fromName to:(NSString *)toName;
- (id)initFrom:(NSString *)fromName to:(NSString *)toName;
- (BOOL)meetsCondition:(id)obj;
@property (nonatomic, copy, readonly) NSString *from;
@property (nonatomic, copy, readonly) NSString *to;
@property (nonatomic, copy) LSStateMachineTransitionCondition condition;
@end
