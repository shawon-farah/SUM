//
//  SUMImageWithTwoSubtitleCell.h
//  SUM
//
//  Created by Abdullah Farah on 12/1/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AsyncImageView.h"

@interface SUMImageWithTwoSubtitleCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *titleTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailsTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *intervalTextLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@end
