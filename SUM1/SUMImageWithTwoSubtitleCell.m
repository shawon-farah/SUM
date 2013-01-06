//
//  SUMImageWithTwoSubtitleCell.m
//  SUM
//
//  Created by Abdullah Farah on 12/1/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import "SUMImageWithTwoSubtitleCell.h"

@implementation SUMImageWithTwoSubtitleCell

@synthesize imageView, titleTextLabel, detailsTextLabel, intervalTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
