//
//  ORObjectRelation+ORPrivate.h
//  OR
//
//  Created by GondorBilbo on 2017/9/29.
//  Copyright © 2017年 ORObjectRelation. All rights reserved.
//

#import "ORObjectRelation.h"

@interface ORObjectRelation (ORPrivate)

- (void)_async:(dispatch_block_t)block;

- (void)_sync:(dispatch_block_t)block;

@end
