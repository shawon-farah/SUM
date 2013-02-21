//
//  AsyncImageView.m
//

#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageCache.h"

@implementation AsyncImageView

@synthesize hidePlaceholderImageOnError, delegate, defaultImage;

// called on initialization
- (void) setImageViewDefaults {
    
    activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] retain];
    activityIndicator.color = [UIColor blackColor];
	activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	activityIndicator.hidesWhenStopped = YES;
	activityIndicator.hidden = YES;
	[self addSubview:activityIndicator];
	
    self.defaultImage = self.image;
    
    //addTapGesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(asyncImageViewTapped:)];
    [self addGestureRecognizer:tap];
    [tap release];
    
}


//this function basically sets the image to a placeholder specified - in cases where no image record exists
-(void)setPlaceholderImage:(NSString*)_defaultImage{
	if ([[self subviews] count] >0) {
		//then this must be another image, the old one is still in subviews
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
	}
	
	UIImageView* defaultImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:_defaultImage]] autorelease];
	[self addSubview:defaultImageView];
	defaultImageView.frame = self.bounds;
	defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
	defaultImageView.autoresizingMask = 0;
	
	[defaultImageView setNeedsLayout];
	[self setNeedsLayout];
}

-(void)setLoaderImage:(NSString*)_defaultImage{
	if ([[self subviews] count] >0) {
		//then this must be another image, the old one is still in subviews
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
	}
	
	UIImageView* defaultImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:_defaultImage]] autorelease];
	[self addSubview:defaultImageView];
	defaultImageView.frame = self.bounds;
	//NSLog(@"defaultimage view frame %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, defaultImageView.frame.size.width, defaultImageView.frame.size.height);
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor blackColor];
	activityIndicator.center = CGPointMake((self.frame.size.width) / 2, (self.frame.size.height) / 2);
	activityIndicator.hidesWhenStopped = YES;
	
	defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
	defaultImageView.autoresizingMask = 0;
	
	[self addSubview:activityIndicator];
	[activityIndicator startAnimating];
	[defaultImageView setNeedsLayout];
	[activityIndicator setNeedsLayout];
	[self setNeedsLayout];
}


- (IBAction)asyncImageViewTapped:(UITapGestureRecognizer *)sender{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(asyncImageViewWasTapped:)]) {
        [self.delegate asyncImageViewWasTapped:self];
    }
}


#pragma mark -
#pragma mark Initializers

- (id) init {
    if((self = [super init])) {
        [self setImageViewDefaults];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])) {
        [self setImageViewDefaults];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        [self setImageViewDefaults];
    }
    return self;
}

- (id) initWithImage:(UIImage *)image {
    if((self = [super initWithImage:image])) {
        [self setImageViewDefaults];
    }
    return self;
}

- (id) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if((self = [super initWithImage:image highlightedImage:highlightedImage])) {
        [self setImageViewDefaults];
    }
    return self;
}

- (id) initWithImage:(UIImage *) image andFrame: (CGRect) frame {
    if((self = [super initWithFrame: frame])) {
        [self setImageViewDefaults];
        self.image = image;
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andDelegate: (id<AsyncImageViewDelegate>) theDelegate {
    if((self = [super initWithFrame:frame])) {
        [self setImageViewDefaults];
        self.delegate = theDelegate;
    }
    return self;
}

- (id) initWithImage:(UIImage *)image andFrame:(CGRect)frame andDelegate: (id<AsyncImageViewDelegate>) theDelegate {
    if ((self = [super initWithFrame:frame])) {
        [self setImageViewDefaults];
        self.delegate = theDelegate;
        self.image = image;
    }
    return self;
}

#pragma mark -
#pragma mark Memory Handlers

- (void)dealloc {
    // clean up animation stuff, just in case
    [self.layer removeAllAnimations];
    [UIView setAnimationDelegate:nil];
    
    [connection cancel]; //in case the URL is still downloading
    [activityIndicator release];
    [data release]; 
    [_error release];
    [super dealloc];
}

#pragma mark - 
#pragma mark Methods

// turns off the activity indicator
- (void) stopLoading {
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
}

// turns the activity indicator on
- (void) setLoading {
    activityIndicator.hidden = NO;
    activityIndicator.center = self.center;
    [activityIndicator startAnimating];
	[activityIndicator setNeedsLayout];
    [self setNeedsLayout];
	
}

// displays an image in the view with possible animation
-(void) displayImage:(UIImage *)someImage animated: (BOOL) animated {
    //Remove the loaderImage so we can show the actual image.
    if ([[self subviews] count] >0) {
        //then this must be another image, the old one is still in subviews
        [[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
    }
    	
    // stop the acitivity indicator, we're done downloading
    [self stopLoading];
    
    // set the image view
    self.image = someImage;
    
    // perform a transition effect if desired
    if(animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [self.layer addAnimation:transition forKey:nil];
    }
    
    // sanity checks
    // [self setNeedsLayout];
    //[self setNeedsDisplay];
    
    // if(self.superview && self.superview) {
    //  [self.superview.superview setNeedsDisplay];
    //  [self.superview.superview setNeedsLayout];
    //}
}

// loads an image from a URL in the background
- (void)loadImageFromURL:(NSString*)url {
    
    // short circuit if empty
    if(url == nil || [url length] == 0)
        return;
    
    // reset any previous connection
	if (connection!=nil) { 
		
		[connection cancel];
		[connection release];
		connection = nil;
		
	} 
    
    // reset any previous data
	if (data!=nil) {
		[data release];
		data = nil;
	}
    
    if(_url != nil) {
        [_url release];
        _url = nil;
    }
    
 
    
    // set the default image while loading
    self.image = self.defaultImage;
	
    // check cache first (memory or disk)
    UIImage *_image = [[ImageCache sharedImageCache] imageForKey:url];
    if(_image == nil){
        
        // check resource next (more intensive)
        _image = [UIImage imageNamed:url];
        
        if(_image == nil){
            
            // checks failed - better download
            
            if(_error != nil) {
                [_error release];
                _error = nil;
            }
            
            [self setLoading];
            
            _url = [NSURL URLWithString:url];
			
            NSURLRequest* request = [NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain]; //notice how delegate set to self object
			
            return;
        }
    }
	
    // won't get here if image == nil
    
    // display image file
    [self displayImage:_image animated:NO];
	
    // check the delegate
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(asyncImageLoaded:)]) {
        [self.delegate asyncImageLoaded:self];
    }
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; } 
	[data appendData:incrementalData];
}

// common stuff that happens on an error
- (void) onError
{
    
    NSLog(@"%@", _error);
    
    // check delegate
    if(self.delegate != nil) {
        if( [self.delegate respondsToSelector:@selector(asyncImageError:error:)]) {
            [self.delegate asyncImageError:self error:_error];
        }
    }
    
    // optionally hide the original image
    if(hidePlaceholderImageOnError) {
        self.hidden = YES;
    } 
}

// check for errors
- (void) connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    if(_url != nil) {
        [_url release];
        _url = nil;
    }
    
    // we keep this for checking in parent controller
    _error = [error retain];
    if(connection != nil) {
        [connection release];
        connection = nil;
    }
    
    // stop activity indicator
    [self stopLoading];
	
    [self onError];
}

// check for HTTP status errors
// connectionDidFinishLoading isn't called if we end up here
- (void) connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    if([response isKindOfClass:[NSHTTPURLResponse class]]) {
        int code = [(NSHTTPURLResponse *) response statusCode];
        if(code >= 400) {
            // we non-connection related error
            _error = [[[NSError alloc] initWithDomain:response.URL.absoluteString code:code userInfo:nil] retain];
        }
    }
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
	//so self data now has the complete image 
    if(connection != nil) {
        [connection release];
        connection=nil;
    }
    
    // we can stop the indicator
	[self stopLoading];
	
    // did the server respond with an error?
    if(_error != nil) {
        [self onError];
        return;
    }
    
    // woohoo display the image
	[self displayImage:[UIImage imageWithData:data] animated:YES];
    
    // check the delegate
    if(self.delegate != nil) {
        if( _error && [self.delegate respondsToSelector:@selector(asyncImageError:error:)]) {
            [self.delegate asyncImageError:self error:_error];
        }
        
        if ([self.delegate respondsToSelector:@selector(asyncImageDidFinishLoading:)]) {
            [self.delegate asyncImageDidFinishLoading:self];
        }
    }
    
    // cache for future use
    
    [[ImageCache sharedImageCache] storeImage:self.image withKey:_url.absoluteString];
	
    if(data != nil) {
        [data release]; //don't need this any more, its in the UIImageView now
        data=nil;
    }
}

// the URL the image came from
- (NSURL  *) imageURL {
    return _url;
}

// the last error if any
- (NSError *) lastError {
    return _error;
}

@end