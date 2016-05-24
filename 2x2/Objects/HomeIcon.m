//
//  HomeIcon.m
//  2x2
//
//  Created by aDb on 3/9/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "HomeIcon.h"
#define URLaddress "http://new.chargoosh.ir/"
@implementation HomeIcon
-(id)init
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        _iconId =[self.dataDictionary valueForKey:@"id"];
        _iconURL =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[self.dataDictionary valueForKey:@"iconUrl"]]];
        _caption = [self.dataDictionary valueForKey:@"caption"];
        _type = [self.dataDictionary valueForKey:@"type"];
        _data = [self.dataDictionary valueForKey:@"data"];
        
    }
    return self;
    
}
@end
