//
//  Notifier.h
//  Passenger
//
//  Created by Connor Myers on 12/29/15.
//  Copyright © 2015 Astral. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notifier : NSObject
-(void)registerAppforDetectLockState;
-(bool)isLocked;
@end
