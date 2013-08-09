#import "LSTransition.h"

@implementation LSTransition
+ (instancetype)transitionFrom:(NSString *)fromName to:(NSString *)toName;
{
    return [[self alloc] initFrom:fromName to:toName];
}
- (id)initFrom:(NSString *)fromName to:(NSString *)toName;
{
    self = [super init];
    if (self) {
        _from = [fromName copy];
        _to = [toName copy];
    }
    return self;
}

- (BOOL)meetsCondition:(id)obj;
{
    if (!self.condition)
    {
        return YES;
    }
    return self.condition(obj);
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![self isKindOfClass:[object class]]) {
        return NO;
    }
    LSTransition *other = (LSTransition *)object;
    if (![self.from isEqualToString:other.from]) {
        return NO;
    }
    if (![self.to isEqualToString:other.to]) {
        return NO;
    }
    return YES;
}

- (NSUInteger) hash {
    NSUInteger result = 17;
    result = 31 * result + self.from.hash;
    result = 31 * result + self.to.hash;
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ from: '%@' to '%@'", self.class, self.from, self.to];
}

@end
