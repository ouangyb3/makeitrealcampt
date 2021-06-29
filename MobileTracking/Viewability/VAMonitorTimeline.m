

//
//  VAMontorTimeline.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import "VAMonitorTimeline.h"
#import "VAMonitorFrame.h"
#import "NSDate+VASDK.h"
#import "VAMaros.h"
#import "VAMonitor.h"

@interface VAMonitorTimeline ()
@property (nonatomic, strong) VAMonitorFrame *start;
@property (nonatomic, strong) VAMonitorFrame *visibleStart;
@property (nonatomic, strong) VAMonitorFrame *end;
@property (nonatomic, strong) NSMutableArray <VAMonitorFrame *> *frames;

@end


@implementation VAMonitorTimeline

- (instancetype)initWithMonitor:(VAMonitor *)monitor {
    if(self = [super init]) {
        self.frames = [NSMutableArray array];
        _exposeDuration = 0;
        _monitorDuration = 0;
        _monitor = monitor;
    }
    return self;
}


// 需要添加结尾  头已经添加进去数组  尾巴一定情况需要合并进去
- (void)enqueueFrame:(VAMonitorFrame *)frame {
    if(!frame) {
        NSLog(@"当前帧为空");

        return;
    }
    
    /**
     *  第一个添加为首 然后判断是否需要记录与end 相比较相同则放弃,end 换为当前帧
     */
    if(!_frames.count ) {
        NSLog(@"start 帧保存成功");

        _start = frame;
    }
    
    if([self needRecord:frame]) {
        [_frames addObject:frame];
        NSInteger count = self.monitor.config.maxUploadCount;
        if(_frames.count > count) {
            [_frames removeObjectAtIndex:0];
        }
        NSLog(@"当前帧发生变更记录%@",frame.captureDate);

    }
    
    _end = frame;

    
    /**
     *  计算曝光时长
     */
    if([frame isVisible] && (1 - frame.coverRate) >= self.monitor.config.vaildExposeShowRate) { // 当前帧可见 累计曝光时间.
        if(!_visibleStart) {
            _visibleStart = frame;
        }
        _exposeDuration = [frame.captureDate timeIntervalSinceDate:_visibleStart.captureDate];
        
    } else {  // 当前帧不可见 曝光时间重置
        _visibleStart = nil;
        _exposeDuration = 0;
    }
    
    _monitorDuration = [_end.captureDate timeIntervalSinceDate:_start.captureDate];
    NSLog(@"ID:%p 持续监测时长:%f 曝光时长:%f",self,_monitorDuration,_exposeDuration);

}

- (BOOL)needRecord:(VAMonitorFrame *)frame {
    // end 不存在 直接记录
    if (!_end) {
        return YES;
    }
    
    // 与end 相同 不记录
    if([_end isEqualFrame:frame]) {
        return NO;
    }
    
    return YES;
}

- (NSArray<VAMonitorFrame *> *)generateOutputFrames {
    @try {
        VAMonitorFrame *last = [self.frames lastObject];
        //TODO:// 对比时间戳一致检查
        if(last && [last isEqual:_end]) {
            return [_frames copy];
        } else {
            NSMutableArray *array = [NSMutableArray arrayWithArray:_frames];
            if(_end) {
                [array addObject:_end];
            }
            return [array copy];
        }
    } @catch (NSException *exception) {
        
    }
   
}

- (NSInteger)count {
    return [self generateOutputFrames].count;
}

- (NSString *)generateUploadEvents {
    NSArray<VAMonitorFrame *> *outputframes = [self generateOutputFrames];
    NSInteger count = self.monitor.config.maxUploadCount;
    if(outputframes.count > count) {
        outputframes = [outputframes subarrayWithRange:NSMakeRange(outputframes.count - count, count)];
    }
    NSMutableArray *array = [NSMutableArray array];
    [outputframes enumerateObjectsUsingBlock:^(VAMonitorFrame * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        

        NSDictionary *dictionary = @{
                                     AD_VB_TIME : obj.captureDate.mtimestamp,          // 监测时间戳毫秒秒
                                     AD_VB_FRAME : VAStringFromSize(obj.frame.size), // 广告原始尺寸
                                     AD_VB_POINT : VAStringFromPoint(obj.windowFrame.origin), // 广告可视的原点位置
                                     AD_VB_ALPHA : [NSString stringWithFormat:@"%.2f",obj.alpha], // 透明度
                                     AD_VB_HIDE : [NSString stringWithFormat:@"%d",!obj.hidden],  // 隐藏
                                     AD_VB_COVER_RATE : [NSString stringWithFormat:@"%.2f",obj.coverRate], // 覆盖比例
                                     AD_VB_SHOWFRAME : VAStringFromSize(obj.showFrame.size), // 广告可视尺寸
                                     AD_VB_FORGROUND : [NSString stringWithFormat:@"%d",obj.isForground]  // 是否前台
                                     };
        
        NSMutableDictionary *accessDictionary = [NSMutableDictionary dictionary];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key,NSString  *obj, BOOL * _Nonnull stop) {
            if([self.monitor canRecord:key]) {
                accessDictionary[[self.monitor keyQuery:key]] = obj;
            }
        }];

        [array addObject:[accessDictionary copy]];
    }];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\"" withString:@""]; // 替换双引号为空

    return jsonString;
    
}


#pragma mark ---- Coder

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self =[super init]) {
        _start = [aDecoder decodeObjectOfClass:[VAMonitorFrame class] forKey:@"start"];
        _visibleStart = [aDecoder decodeObjectOfClass:[VAMonitorFrame class] forKey:@"visibleStart"];
        _end = [aDecoder decodeObjectOfClass:[VAMonitorFrame class] forKey:@"end"];
        _monitor = [aDecoder decodeObjectOfClass:[VAMonitor class] forKey:@"monitor"];

        _frames = [aDecoder decodeObjectForKey:@"frames"];

        _exposeDuration = [aDecoder decodeFloatForKey:@"exposeDuration"];
        _monitorDuration = [aDecoder decodeFloatForKey:@"monitorDuration"];
        
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_start forKey:@"start"];
    [aCoder encodeObject:_visibleStart forKey:@"visibleStart"];
    [aCoder encodeObject:_end forKey:@"end"];
    [aCoder encodeObject:_monitor forKey:@"monitor"];

    [aCoder encodeObject:_frames forKey:@"frames"];
    [aCoder encodeFloat:_exposeDuration forKey:@"exposeDuration"];
    [aCoder encodeFloat:_monitorDuration forKey:@"monitorDuration"];
}

@end
