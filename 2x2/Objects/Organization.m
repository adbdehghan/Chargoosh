//
//  Organization.m
//  2x2
//
//  Created by aDb on 2/27/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import "Organization.h"
#define URLaddress "http://new.chargoosh.ir/"

@implementation Organization
-(id)init
{
    self = [super init];
    if (self)
    {
        _iconId =[self.dataDictionary valueForKey:@"id"];
        _iconURL =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[self.dataDictionary valueForKey:@"iconUrl"]]];
        _caption = [self.dataDictionary valueForKey:@"name"];
        _mine = [self.dataDictionary valueForKey:@"mine"];
        
    }
    return self;
}
@end
