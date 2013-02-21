//
//  AsyncImageView.h
//
//  Ryan Jennings
//  QuickMobile 2011
//
//  See ImageCache.h for cache details.
//
// Use case: 
//
// In a table listing view, where loading images should not block UI
//
// To use:
//
// In a table cell XIB you can place a UIImageView and change its subclass to AsyncImageView.
// Setting an image in the XIB (or initializer if in code) will become the "default image".
// If the image loader has to download the image, the activity display will be set automatically.
//
// When downloading an image its simply a matter of:
//
// if(imageURL exists) {
//      [cell.imageView loadImageFromURL:imageURL];
// }
//
// You also have the ability to implement AsyncImageViewDelegate for example
// if you only want to show an image in some cases, and need to adjust the layout
//
// - (void) asyncImageLoaded: (AsyncImageView *) asyncImage {
//       [self adjustLayoutForImage]
// }
//
//

#import <UIKit/UIKit.h>


@protocol AsyncImageViewDelegate;

@interface AsyncImageView : UIImageView {
	NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
	UIActivityIndicatorView* activityIndicator; //for the loader
    NSError *_error;
    NSURL *_url;
}

@property (nonatomic, assign) BOOL hidePlaceholderImageOnError;
@property (nonatomic, assign) IBOutlet id<AsyncImageViewDelegate> delegate;
@property (nonatomic, retain) UIImage *defaultImage;

- (id) initWithImage:(UIImage *) image andFrame: (CGRect) frame;
- (id) initWithFrame:(CGRect)frame andDelegate: (id<AsyncImageViewDelegate>) theDelegate;
- (id) initWithImage:(UIImage *)image andFrame:(CGRect)frame andDelegate: (id<AsyncImageViewDelegate>) theDelegate;

-(void)loadImageFromURL:(NSString*)url;
-(void)setLoaderImage:(NSString*)defaultImage;
- (NSURL *) imageURL;
- (NSError *) lastError;
-(void)setPlaceholderImage:(NSString*)defaultImage;

@end

@protocol AsyncImageViewDelegate <NSObject>

@optional
- (void) asyncImageDidFinishLoading: (AsyncImageView *) asyncImage;
@optional
- (void) asyncImageLoaded: (AsyncImageView *) asyncImage;
@optional
- (void) asyncImageError: (AsyncImageView *) asyncImage error: (NSError *) error;
@optional
- (void) asyncImageViewWasTapped:(AsyncImageView *)asyncImage;

@end
