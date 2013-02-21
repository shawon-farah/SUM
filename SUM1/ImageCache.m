//
//  ImageCache.m
//  ImageCacheTest
//
//  Created by Adrian on 1/28/09.
//  Copyright 2009 Adrian Kosmaczewski. All rights reserved.
//

#import "ImageCache.h"
#import "NSString+QMAdditions.h"

@interface ImageCache (Private)
- (NSArray *) diskCacheContents: (NSString*) cacheDirectoryName;
- (void)addImageToMemoryCache:(UIImage *)image withKey:(NSString *)key;
- (NSString *)getCacheDirectoryName;
- (NSString *)getFileNameForKey:(NSString *)key;

@end

//ImageCache, sharedImageCache

@implementation ImageCache

#pragma mark -
#pragma mark Singleton definition

static ImageCache *_sharedImageCache = nil;  
+ (ImageCache *)sharedImageCache {             
    @synchronized(self) {                            
        if (_sharedImageCache == nil) {             
            /* Note that 'self' may not be the same as _object_name_ */                               
            /* first assignment done in allocWithZone but we must reassign in case init fails */      
            _sharedImageCache = [[self alloc] init];                                                
        }                                              
    }                                                
    return _sharedImageCache;                     
}                                                  
+ (id)allocWithZone:(NSZone *)zone {               
    @synchronized(self) {                            
        if (_sharedImageCache == nil) {             
            _sharedImageCache = [super allocWithZone:zone]; 
            return _sharedImageCache;                 
        }                                              
    }                                                
        
    return nil;                                      
}                                                  
- (id)retain {                                     
    return self;                                     
}                                                  
- (NSUInteger)retainCount {                        
    return NSUIntegerMax;                            
}  

- (oneway void)release {                                  
}    

- (id)autorelease {                                
    return self;                                     
}                                                  
- (id)copyWithZone:(NSZone *)zone {                
    return self;                                     
}                                                  


#pragma mark -
#pragma mark Constructor and destructor

- (id)init
{
    if (self = [super init])
    {
        keyArray = [[NSMutableArray alloc] initWithCapacity:MEMORY_CACHE_SIZE];
        memoryCache = [[NSMutableDictionary alloc] initWithCapacity:MEMORY_CACHE_SIZE];
        fileManager = [NSFileManager defaultManager];
        
        NSString *cacheDirectoryName = [self getCacheDirectoryName];
        BOOL isDirectory = NO;
        BOOL folderExists = [fileManager fileExistsAtPath:cacheDirectoryName isDirectory:&isDirectory] && isDirectory;
        
        if (!folderExists)
        {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:cacheDirectoryName withIntermediateDirectories:YES attributes:nil error:&error];
            [error release];
        }
    }
    return self;
}

- (void)dealloc
{
    [keyArray release];
    keyArray = nil;
    [memoryCache release];
    memoryCache = nil;
    fileManager = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (NSArray *) diskCacheContents: (NSString*) cacheDirectoryName 
{
    NSError *error = nil;
    NSArray *items = [fileManager contentsOfDirectoryAtPath:cacheDirectoryName error:&error];
    if(error != nil) {
        NSLog(@"%@", error);
    }
    return items;
}

#pragma mark -
#pragma mark Public methods

- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *image = [memoryCache objectForKey:key];
    if (image == nil && [self imageExistsInBundle:key])
    {
        NSString *fileName = [[NSBundle mainBundle] pathForResource:[key md5HexDigest] ofType:nil];;
        NSData *data = [NSData dataWithContentsOfFile:fileName];
        image = [[[UIImage alloc] initWithData:data] autorelease];
        [self addImageToMemoryCache:image withKey:key];
    }
    else if (image == nil && [self imageExistsInDisk:key])
    {
        NSString *fileName = [self getFileNameForKey:key];
        NSData *data = [NSData dataWithContentsOfFile:fileName];
        image = [[[UIImage alloc] initWithData:data] autorelease];
        [self addImageToMemoryCache:image withKey:key];
    }
    return image;
}

- (BOOL)hasImageWithKey:(NSString *)key
{
    BOOL exists = [self imageExistsInMemory:key];
    if (!exists)
    {
        exists = [self imageExistsInDisk:key];
    }
    return exists;
}

- (void)storeImage:(UIImage *)image withKey:(NSString *)key
{
    if (image != nil && key != nil)
    {
        NSString *fileName = [self getFileNameForKey:key];
        [UIImagePNGRepresentation(image) writeToFile:fileName atomically:YES];
        [self addImageToMemoryCache:image withKey:key];
    }
}

- (void)removeImageWithKey:(NSString *)key
{
    if ([self imageExistsInMemory:key])
    {
        NSUInteger index = [keyArray indexOfObject:key];
        [keyArray removeObjectAtIndex:index];
        [memoryCache removeObjectForKey:key];
    }
    
    if ([self imageExistsInDisk:key])
    {
        NSError *error = nil;
        NSString *fileName = [self getFileNameForKey:key];
        [fileManager removeItemAtPath:fileName error:&error];
        [error release];
    }
}

- (void)removeAllImages
{
    [memoryCache removeAllObjects];
    
    NSString *cacheDirectoryName = [self getCacheDirectoryName];
    NSArray *items = [self diskCacheContents: cacheDirectoryName];
    for (NSString *item in items)
    {
        NSString *path = [cacheDirectoryName stringByAppendingPathComponent:item];
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        [error release];
    }
}

- (void)removeAllImagesInMemory
{
    [memoryCache removeAllObjects];
}

- (void)removeOldImages
{    
    NSString *cacheDirectoryName = [self getCacheDirectoryName];
    NSArray *items = [self diskCacheContents: cacheDirectoryName];
    for (NSString *item in items)
    {
        NSString *path = [cacheDirectoryName stringByAppendingPathComponent:item];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:nil];
        NSDate *creationDate = [attributes valueForKey:NSFileCreationDate];
        if (abs([creationDate timeIntervalSinceNow]) > IMAGE_FILE_LIFETIME)
        {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
        }
    }
}

- (BOOL)imageExistsInMemory:(NSString *)key
{
    return ([memoryCache objectForKey:key] != nil);
}

- (BOOL)imageExistsInDisk:(NSString *)key
{
    NSString *fileName = [self getFileNameForKey:key];
    return [fileManager fileExistsAtPath:fileName];
}

- (BOOL)imageExistsInBundle:(NSString *)key
{
    NSString *fileName = [[NSBundle mainBundle] pathForResource:[key md5HexDigest] ofType:nil];
    return [fileManager fileExistsAtPath:fileName];
}

- (NSUInteger)countImagesInMemory
{
    return [memoryCache count];
}

- (NSUInteger)countImagesInDisk
{    
    NSString *cacheDirectoryName = [self getCacheDirectoryName];
    NSArray *items = [self diskCacheContents: cacheDirectoryName];
    return [items count];
}

#pragma mark -
#pragma mark Private methods

- (void)addImageToMemoryCache:(UIImage *)image withKey:(NSString *)key
{
    // Add the object to the memory cache for faster retrieval next time
    [memoryCache setObject:image forKey:key];
    
    // Add the key at the beginning of the keyArray
    [keyArray insertObject:key atIndex:0];
    
    // Remove the first object added to the memory cache
    if ([keyArray count] > MEMORY_CACHE_SIZE)
    {
        // This is the "raison d'etre" de keyArray:
        // we use it to keep track of the last object
        // in it (that is, the first we've inserted), 
        // so that the total size of objects in memory
        // is never higher than MEMORY_CACHE_SIZE.
        NSString *lastObjectKey = [keyArray lastObject];
        [memoryCache removeObjectForKey:lastObjectKey];
        [keyArray removeLastObject];
    }    
}

- (NSString *)getCacheDirectoryName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:CACHE_FOLDER_NAME];
    return cacheDirectoryName;
}

- (NSString *)getFileNameForKey:(NSString *)key
{
    NSString *cacheDirectoryName = [self getCacheDirectoryName];
    NSString *fileName = [cacheDirectoryName stringByAppendingPathComponent:[key md5HexDigest]];
    return fileName;
}

@end
