#import "RGObject.h"
#import <CoreData+MagicalRecord.h>


@interface RGObject ()

// Private interface goes here.

@end


@implementation RGObject

// Custom logic goes here.

+ (id)objectWithItemId:(NSString *)itemId inContext:(NSManagedObjectContext *)context
{
    RGObject *object = [self MR_findFirstByAttribute:@"itemId" withValue:itemId inContext:context];
    if (object == nil)
    {
        object = [self MR_createInContext:context];
        object.itemId = itemId;
    }
    return object;
}

@end
