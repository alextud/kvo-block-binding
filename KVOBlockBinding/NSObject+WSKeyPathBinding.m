//
//  NSObject+WSKeyPathBinding.m
//  Local
//
//  Created by Ray Hilton on 27/06/12.
//  Copyright (c) 2012 Wirestorm Pty Ltd. All rights reserved.
//

#import "NSObject+WSKeyPathBinding.h"
#import "NSObject+WSObservation.h"
#import <objc/runtime.h>


#define ASSOCIATED_OBJ_BINDINGS_KEY @"rayh_block_based_bindings"

@implementation NSObject (WSKeyPathBinding)

-(NSMutableArray*)allKeyPathBindings
{
	NSMutableArray *objects = objc_getAssociatedObject(self, ASSOCIATED_OBJ_BINDINGS_KEY);
    if(!objects) {
        objects = [NSMutableArray array];
        objc_setAssociatedObject(self, ASSOCIATED_OBJ_BINDINGS_KEY, objects, OBJC_ASSOCIATION_RETAIN);
    }
    
    return objects;
}


- (void)bindSourceKeyPath:(NSString *)sourcePath to:(id)target targetKeyPath:(NSString *)targetPath reverseMapping:(BOOL)reverseMapping
{
    [self bindSourceKeyPath:sourcePath to:target targetKeyPath:targetPath reverseMapping:reverseMapping owner:self];
}

- (void)bindSourceKeyPath:(NSString *)sourcePath to:(id)target targetKeyPath:(NSString *)targetPath reverseMapping:(BOOL)reverseMapping owner:(id)owner {
    __weak id weakTarget = target;
    WSObservationBinding *binding = [self observe:self keyPath:sourcePath block:^(id observed, NSDictionary *change) {
        [weakTarget setValue:[change valueForKey:NSKeyValueChangeNewKey] forKey:targetPath];
    }];
    binding.owner = owner;
    [[self allKeyPathBindings] addObject:binding];
    
    if(reverseMapping)
    {
        __weak id weakSelf = self;
        WSObservationBinding *binding = [self observe:target keyPath:targetPath block:^(id observed, NSDictionary *change) {
            [weakSelf setValue:[change valueForKey:NSKeyValueChangeNewKey] forKey:sourcePath];
        }];
        binding.owner = owner;
        [[self allKeyPathBindings] addObject:binding];
    }
}

- (void)unbindKeyPath:(NSString*)keyPath forOwner:(id)owner;
{
    NSArray *bindings = [self allKeyPathBindings];
    for(WSObservationBinding *binding in bindings)
    {
        BOOL shouldInvalidate = binding.owner == owner && [binding.keyPath isEqualToString:keyPath];
        if(shouldInvalidate)
        {
            [binding invalidate];
            binding.block = nil;
            [[self allKeyPathBindings] removeObject:binding];
        }
    }
}

- (void)unbindAllKeyPaths
{
    for(WSObservationBinding *binding in [self allKeyPathBindings])
    {
        [binding invalidate];
        binding.block = nil;
    }
    
    [[self allKeyPathBindings] removeAllObjects];
}

- (void)unbindAllKeyPathsForOwner:(id)owner
{
    for(WSObservationBinding *binding in [[self allKeyPathBindings] copy])
    {
        if (binding.owner == owner) {
            [binding invalidate];
            binding.block = nil;
            [[self allKeyPathBindings] removeObject:binding];
        }
    }
}


@end
