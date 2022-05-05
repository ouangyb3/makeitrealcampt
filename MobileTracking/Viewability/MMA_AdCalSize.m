//
//  AdCalSize.m
//  AdCoverDemo
//
//  Created by admin on 2019/5/20.
//  Copyright © 2019 admaster. All rights reserved.
//

#import "MMA_AdCalSize.h"

@interface MMA_AdNode : NSObject
@property (nonatomic) float aLeft;
@property (nonatomic) float aRight;
@property (nonatomic) NSInteger coveredNum;
@property (nonatomic) float len;
@property (nonatomic) float left;
@property (nonatomic) float right;
@end
@implementation MMA_AdNode

@end

@interface MMA_AdLine : NSObject <NSCopying>

@property (nonatomic) float left;
@property (nonatomic) float right;
@property (nonatomic) float y;
@property (nonatomic) BOOL isTop;

- (instancetype)initWithRect:(CGRect)rect top:(BOOL)isTop;

@end

@implementation MMA_AdLine

- (instancetype)initWithRect:(CGRect)rect top:(BOOL)isTop;
{
    self = [super init];
    if (self) {
        self.left = rect.origin.x;
        self.isTop = isTop;
        self.right = rect.origin.x + rect.size.width;
        self.y = isTop ? rect.origin.y : rect.origin.y + rect.size.height;
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    MMA_AdLine *line = [[[self class] allocWithZone:zone] init];
    line.left = _left;
    line.right = _right;
    line.isTop = _isTop;
    line.y = _y;
    return line;
}

@end

@interface MMA_AdCalSize ()

@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) NSMutableSet *xValues;
@property (nonatomic, strong) NSMutableDictionary *nodeList;

@property (nonatomic, strong) NSArray *sortedLines;
@property (nonatomic, strong) NSArray *sortedXValues;

@end

@implementation MMA_AdCalSize

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.lines = [NSMutableArray arrayWithCapacity:100];
        self.xValues = [NSMutableSet setWithCapacity:100];
        self.nodeList = [NSMutableDictionary dictionaryWithCapacity:100];
        
    }
    return self;
}

- (CGFloat)calSize:(NSArray *)rects {
    
    for (NSString *sRect in rects) {
        CGRect rect = CGRectFromString(sRect);
        MMA_AdLine *line1 = [[MMA_AdLine alloc] initWithRect:rect top:YES];
        MMA_AdLine *line2 = [[MMA_AdLine alloc] initWithRect:rect top:NO];
        [self.lines addObjectsFromArray:@[line1, line2]];
        [self.xValues addObjectsFromArray:@[@(line1.left),@(line1.right)]];
    }
    
    _sortedLines = [self.lines sortedArrayUsingComparator:^NSComparisonResult(MMA_AdLine *obj1, MMA_AdLine *obj2) {
        return obj1.y > obj2.y;
    }];

    _sortedXValues = [[self.xValues allObjects] sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return obj1.floatValue > obj2.floatValue;
    }];
    [self buildTree:1 areaX:1 areaY:_sortedXValues.count];
    CGFloat res = 0;
    for (int i = 0; i < _sortedLines.count - 1; i++) {
        [self updateTree:1 line:self.sortedLines[i]];
        MMA_AdLine *line = self.sortedLines[i+1];
        MMA_AdLine *last_line = self.sortedLines[i];
        MMA_AdNode *adNode = [self.nodeList objectForKey:@(1)];
        res += adNode.len*(line.y - last_line.y);
    }
    return res;
}

- (void)buildTree:(NSInteger)index areaX:(NSInteger)aX areaY:(NSInteger)aY  {
    
    MMA_AdNode *adNode = [[MMA_AdNode alloc] init];
    adNode.aLeft = aX;
    adNode.aRight = aY;
    adNode.coveredNum = 0;
    adNode.left = [self.sortedXValues[aX-1] floatValue];
    adNode.right = [self.sortedXValues[aY-1] floatValue];
    adNode.len = 0;
    [self.nodeList setObject:adNode forKey:@(index)];
    
    if (aX + 1 >= aY) {
        return;
    }
    
    NSInteger middle = (aX + aY) >> 1;
    
    [self buildTree:index<<1 areaX:aX areaY:middle];
    [self buildTree:index<<1|1 areaX:middle areaY:aY];
    
}

- (void)updateTree:(NSInteger)index line:(MMA_AdLine *)line {
    
    if (index < 0) {
        return;
    }
    MMA_AdNode *adNode = [self.nodeList objectForKey:@(index)];
    MMA_AdNode *leftNode = [self.nodeList objectForKey:@(index<<1)];
    MMA_AdNode *rightNode = [self.nodeList objectForKey:@(index<<1|1)];
    if (adNode == nil) {
        return;
    }
//    if (leftNode == nil) {
//        return;
//    }
//    if (rightNode == nil) {
//        return;
//    }
    if (line.left == adNode.left && line.right == adNode.right) {
        adNode.coveredNum += line.isTop ? 1 : -1;
//        计算当前所有的区间的覆盖面积
        if (adNode.coveredNum > 0) {
            adNode.len = adNode.right - adNode.left;
        } else if (adNode.aLeft + 1 == adNode.aRight) {
            adNode.len = 0;
        } else {
            adNode.len = leftNode.len + rightNode.len;
        }
        [self.nodeList setObject:adNode forKey:@(index)];
        return;
    }
    
    if (line.right <= leftNode.right) {
        [self updateTree:index<<1 line:line];
    } else if (line.left >= rightNode.left) {
        [self updateTree:index<<1|1 line:line];
    } else {
        MMA_AdLine *tmpline = [line copy];
        tmpline.right = leftNode.right;
        [self updateTree:index<<1 line:tmpline];
        tmpline = line;
        tmpline.left = rightNode.left;
        [self updateTree:index<<1|1 line:tmpline];
    }
    // 计算当前所有区间覆盖的面积  以及映射到父节点
    if (adNode.coveredNum > 0) {
        adNode.len = adNode.right - adNode.left;
        [self.nodeList setObject:adNode forKey:@(index)];
        return;
    } else if (adNode.left+1 == adNode.aRight) {
        adNode.len = 0;
    } else {
        adNode.len = leftNode.len + rightNode.len;
    }
//    if (adNode != nil) {
        [self.nodeList setObject:adNode forKey:@(index)];
//    }
}

@end
