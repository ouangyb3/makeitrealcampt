//
//  MMA_RequestQueue.h
//
//  Version 1.5.2
//
//  Created by Nick Lockwood on 22/12/2011.
//  Copyright (C) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/MMA_RequestQueue
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "MMA_RequestQueue.h"
#import <UIKit/UIKit.h>

#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


NSString *const MMAHTTPResponseErrorDomain = @"MMAHTTPResponseErrorDomain";


@interface RQOperation () <NSURLConnectionDataDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
{
    BOOL _executing;
    BOOL _finished;
    BOOL _cancelled;
    
    BOOL _isRedirect;
}
@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) NSURLSession *connectionSession;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, strong) NSURLResponse *responseReceived;
@property (nonatomic, strong) NSMutableData *accumulatedData;
@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, getter = isCancelled) BOOL cancelled;

@end


@implementation RQOperation

+ (instancetype)operationWithRequest:(NSURLRequest *)request
{
    return [[self alloc] initWithRequest:request];
}

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    if ((self = [self init]))
    {
        _request = request;
        _autoRetryDelay = 5.0;
       
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        } else {
//            ??????NSURLSession?????????2019???05???
            _connectionSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
            _sessionDataTask = [_connectionSession dataTaskWithRequest:request];
        }
        
    }
    return self;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)start
{
    @synchronized (self)
    {
        if (!_executing && !_cancelled)
        {
            [self willChangeValueForKey:@"isExecuting"];
            _executing = YES;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                [_connection start];
            }else {
                [_sessionDataTask resume];
            }
            
            [self didChangeValueForKey:@"isExecuting"];
        }
    }
}

- (void)cancel
{
    @synchronized (self)
    {
        if (!_cancelled)
        {
            [self willChangeValueForKey:@"isCancelled"];
            _cancelled = YES;
            
            
            [self didChangeValueForKey:@"isCancelled"];
            
            //call callback
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                [_connection cancel];
                [self connection:_connection didFailWithError:error];
            }else {
                [_sessionDataTask cancel];
                [self URLSession:_connectionSession task:_sessionDataTask didCompleteWithError:error];

            }
            
        }
    }
    [self.connectionSession invalidateAndCancel];
       self.connectionSession = nil;
}

- (void)finish
{
    @synchronized (self)
    {
        if (_executing && !_finished)
        {
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            _executing = NO;
            _finished = YES;
            [self didChangeValueForKey:@"isFinished"];
            [self didChangeValueForKey:@"isExecuting"];
        }
    }
    [self.connectionSession invalidateAndCancel];
       self.connectionSession = nil;
}

- (NSSet *)autoRetryErrorCodes
{
    if (!_autoRetryErrorCodes)
    {
        static NSSet *codes = nil;
        if (!codes)
        {
            codes = [NSSet setWithObjects:
                     @(NSURLErrorTimedOut),
                     @(NSURLErrorCannotFindHost),
                     @(NSURLErrorCannotConnectToHost),
                     @(NSURLErrorDNSLookupFailed),
                     @(NSURLErrorNotConnectedToInternet),
                     @(NSURLErrorNetworkConnectionLost),
                     nil];
        }
        return codes;
    }
    return _autoRetryErrorCodes;
}

#pragma mark NSURLSessionDelegate
- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        if (_autoRetry && [self.autoRetryErrorCodes containsObject:@(error.code)])
        {
            _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
            [_connection performSelector:@selector(start) withObject:nil afterDelay:_autoRetryDelay];
        }
        else
        {
            [self finish];
            if (_completionHandler) _completionHandler(_responseReceived, _accumulatedData, error);
        }
    } else {
        [self finish];
        
        NSError *error = nil;
        if ([_responseReceived respondsToSelector:@selector(statusCode)])
        {
            
            //treat status codes >= 400 as an error
            NSInteger statusCode = [(NSHTTPURLResponse *)_responseReceived statusCode];
            if (statusCode / 100 >= 4&& !_isRedirect)
            {
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"The server returned a %i error", @"MMA_RequestQueue HTTPResponse error message format"), statusCode];
                NSDictionary *infoDict = @{NSLocalizedDescriptionKey: message};
                error = [NSError errorWithDomain:MMAHTTPResponseErrorDomain
                                            code:statusCode
                                        userInfo:infoDict];
            }
        }
        
        if (_completionHandler) _completionHandler(_responseReceived, _accumulatedData, error);
    }
    
   [self.connectionSession invalidateAndCancel];
      self.connectionSession = nil;
  
}
- (void) URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data {
    
    if (_accumulatedData == nil)
    {
        _accumulatedData = [[NSMutableData alloc] initWithCapacity:MAX(0, (int)_responseReceived.expectedContentLength)];
    }
    [_accumulatedData appendData:data];
    
 
    
}
- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    _responseReceived = response;

    completionHandler(NSURLSessionResponseAllow);
    
 

}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse.statusCode==301||httpResponse.statusCode==302) {
        _isRedirect = YES;
    }
    completionHandler(request);
    
    
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(__unused NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_autoRetry && [self.autoRetryErrorCodes containsObject:@(error.code)])
    {
        _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
        [_connection performSelector:@selector(start) withObject:nil afterDelay:_autoRetryDelay];
    }
    else
    {
        [self finish];
        if (_completionHandler) _completionHandler(_responseReceived, _accumulatedData, error);
    }
}

- (void)connection:(__unused NSURLConnection *)_connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (_authenticationChallengeHandler)
    {
        _authenticationChallengeHandler(challenge);
    }
    else
    {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    _responseReceived = response;
}

/*****************?????????2?????????????????????*************/
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//    NSLog(@"will send request\n%@,,,,,,%d", [request URL],(int)httpResponse.statusCode);
//    NSLog(@"redirect response\n%@,,,,,,%d", [response URL],(int)httpResponse.statusCode);
    if (httpResponse.statusCode==301||httpResponse.statusCode==302) {
        _isRedirect = YES;
    }
    return request;
}
/************************************/

- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_accumulatedData == nil)
    {
        _accumulatedData = [[NSMutableData alloc] initWithCapacity:MAX(0,(int) _responseReceived.expectedContentLength)];
    }
    [_accumulatedData appendData:data];
    if (_downloadProgressHandler)
    {
        NSInteger bytesTransferred = [_accumulatedData length];
        NSInteger totalBytes = MAX(0, _responseReceived.expectedContentLength);
        _downloadProgressHandler((float)bytesTransferred / (float)totalBytes, bytesTransferred, totalBytes);
    }
}

- (void)connectionDidFinishLoading:(__unused NSURLConnection *)_connection
{
    [self finish];
    
    NSError *error = nil;
    if ([_responseReceived respondsToSelector:@selector(statusCode)])
    {

        //treat status codes >= 400 as an error
        NSInteger statusCode = [(NSHTTPURLResponse *)_responseReceived statusCode];
        if (statusCode / 100 >= 4&& !_isRedirect)
        {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"The server returned a %i error", @"MMA_RequestQueue HTTPResponse error message format"), statusCode];
            NSDictionary *infoDict = @{NSLocalizedDescriptionKey: message};
            error = [NSError errorWithDomain:MMAHTTPResponseErrorDomain
                                        code:statusCode
                                    userInfo:infoDict];
        }
    }
    
    if (_completionHandler) _completionHandler(_responseReceived, _accumulatedData, error);
}

@end


@interface MMA_RequestQueue () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSMutableArray *operations;

@end


@implementation MMA_RequestQueue

+ (instancetype)mainQueue
{
    static MMA_RequestQueue *mainQueue = nil;
    if (mainQueue == nil)
    {
        mainQueue = [[MMA_RequestQueue alloc] init];
    }
    return mainQueue;
}

- (id)init
{
    if ((self = [super init]))
    {
        _queueMode = MMA_RequestQueueModeFirstInFirstOut;
        _operations = [[NSMutableArray alloc] init];
        _maxConcurrentRequestCount = 2;
        _allowDuplicateRequests = NO;
    }
    return self;
}

- (NSUInteger)requestCount
{
    return [_operations count];
}

- (NSArray *)requests
{
    return [_operations valueForKeyPath:@"request"];
}

- (void)dequeueOperations
{
    if (!_suspended)
    {
        NSInteger count = MIN([_operations count], _maxConcurrentRequestCount ?: INT_MAX);
        for (int i = 0; i < count; i++)
        {
            [(RQOperation *)_operations[i] start];
        }
    }
}

#pragma mark Public methods
- (void)setSuspended:(BOOL)suspended
{
    _suspended = suspended;
    [self dequeueOperations];
}

- (void)addOperation:(RQOperation *)operation
{
    if (!_allowDuplicateRequests)
    {
        for (int i = [_operations count] - 1; i >= 0 ; i--)
        {
            RQOperation *_operation = _operations[i];
            if ([_operation.request isEqual:operation.request])
            {
                [_operation cancel];
            }
        }
    }
    
    NSUInteger index = 0;
    if (_queueMode == MMA_RequestQueueModeFirstInFirstOut)
    {
        index = [_operations count];
    }
    else
    {
        for (index = 0; index < [_operations count]; index++)
        {
            if (![_operations[index] isExecuting])
            {
                break;
            }
        }
    }
    if (index < [_operations count])
    {
        [_operations insertObject:operation atIndex:index];
    }
    else
    {
        [_operations addObject:operation];
    }
    
    [operation addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew context:NULL];
    [self dequeueOperations];
}

- (void)addRequest:(NSURLRequest *)request completionHandler:(RQCompletionHandler)completionHandler
{
    RQOperation *operation = [RQOperation operationWithRequest:request];
    operation.completionHandler = completionHandler;
    [self addOperation:operation];
}

- (void)cancelRequest:(NSURLRequest *)request
{
    for (int i = [_operations count] - 1; i >= 0 ; i--)
    {
        RQOperation *operation = _operations[i];
        if (operation.request == request)
        {
            [operation cancel];
        }
    }
}

- (void)cancelAllRequests
{
    NSArray *operationsCopy = _operations;
    _operations = [NSMutableArray array];
    for (RQOperation *operation in operationsCopy)
    {
        [operation cancel];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(__unused NSDictionary *)change context:(__unused void *)context
{
    if ([keyPath isEqualToString:@"isExecuting"])
    {
        RQOperation *operation = object;
        if (!operation.executing)
        {
            [operation removeObserver:self forKeyPath:keyPath];
            [_operations removeObject:operation];
            [self dequeueOperations];
        }
    }
}

@end
