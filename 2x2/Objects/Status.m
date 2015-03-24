//
//  Status.m
//  2x2
//
//  Created by aDb on 3/10/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "Status.h"

@implementation Status
-(id)init
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        _name =[self.dataDictionary valueForKey:@"name"];
        _score = [self.dataDictionary valueForKey:@"score"];
        _summarize = [self.dataDictionary valueForKey:@"summarize"];
        
    }
    return self;
    
}
@end
