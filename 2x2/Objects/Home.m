//
//  Home.m
//  2x2
//
//  Created by aDb on 3/9/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "Home.h"
#import "HomeIcon.h"

@implementation Home

-(id)init
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        _name =[self.dataDictionary valueForKey:@"name"]==[NSNull null]?@"":[self.dataDictionary valueForKey:@"name"];
        _comment = [self.dataDictionary valueForKey:@"comment"];
        _weekDay = [self.dataDictionary valueForKey:@"week"];
        _icon = [self.dataDictionary valueForKey:@"icon"];
        
        _homeIconList = [[NSMutableArray alloc]init];
        
        for (NSMutableDictionary *item in self.icon) {
            
            HomeIcon *homeIcon = [HomeIcon alloc];
            homeIcon.dataDictionary = item;
            homeIcon = [homeIcon init];
            
            [_homeIconList addObject:homeIcon];
        }
        
    }
    return self;
    
}
@end
