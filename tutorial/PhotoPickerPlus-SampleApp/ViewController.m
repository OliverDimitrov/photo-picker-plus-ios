//
//  ViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 7/28/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "ViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CustomImageView.h"

//#import "GCPopoverBackgroundView.h"

@interface ViewController ()

@property (nonatomic, strong) MPMoviePlayerViewController   *videoPlayer;

@end

@implementation ViewController

@synthesize scrollView, pageControl, popoverController, videoPlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageControl.numberOfPages = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)pickPhotoSelected:(id)sender
{
    PhotoPickerViewController *picker = [PhotoPickerViewController new];
    [picker setDelegate:self];
//    [picker setOauth2Client:[GCOAuth2Client clientWithClientID:@"4f3c39ff38ecef0c89000003" clientSecret:@"c9a8cb57c52f49384ab6117c4f6483a1a5c5a14c4a50d4cef276a9a13286efc9"]];
    [picker setIsMultipleSelectionEnabled:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (![[self popoverController] isPopoverVisible]) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
//            [popover setPopoverBackgroundViewClass:[GCPopoverBackgroundView class]];
            [popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popoverController = popover;
        }
        else {
            [[self popoverController] dismissPopoverAnimated:YES];
        }
    }
    else {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)pickMultiplePhotosSelected:(id)sender
{
    PhotoPickerViewController *picker = [PhotoPickerViewController new];
    [picker setDelegate:self];
//    [picker setOauth2Client:[GCOAuth2Client clientWithClientID:@"4f3c39ff38ecef0c89000003" clientSecret:@"c9a8cb57c52f49384ab6117c4f6483a1a5c5a14c4a50d4cef276a9a13286efc9"]];
    [picker setIsMultipleSelectionEnabled:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (![[self popoverController] isPopoverVisible]) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
//            [popover setPopoverBackgroundViewClass:[GCPopoverBackgroundView class]];
            [popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popoverController = popover;
        }
        else {
            [[self popoverController] dismissPopoverAnimated:YES];
        }
    }
    else {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)changePage:(id)sender {
    CGFloat x = self.pageControl.currentPage * self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

#pragma mark - PhotoPickerViewController Delegate Methods

- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info
{

    [self.scrollView setDelegate:self];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setContentOffset:CGPointZero];
    [self.pageControl setCurrentPage:0];

    
    for (UIView *v in [scrollView subviews]) {
        [v removeFromSuperview];
    }
    
    CGRect workingFrame = self.scrollView.frame;
    workingFrame.origin.x = 0;
    
    for(NSDictionary *dict in info) {
        
        CustomImageView *imageView = [[CustomImageView alloc] initWithFrame:workingFrame andInfo:dict];
        imageView.delegate = self;
        [self.scrollView addSubview:imageView];
        
        workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
    }
    
    [self.scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
    
    self.pageControl.numberOfPages = self.scrollView.contentSize.width/self.scrollView.frame.size.width;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];

    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    [self.scrollView setDelegate:self];
    
    for (UIView *v in [self.scrollView subviews]) {
        [v removeFromSuperview];
    }
    
    CGRect workingFrame = scrollView.frame;
    workingFrame.origin.x = 0;
    
    CustomImageView *imageView = [[CustomImageView alloc] initWithFrame:workingFrame andInfo:info];
    imageView.delegate = self;
    [self.scrollView addSubview:imageView];
    
    workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
    [self.scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
    
    self.pageControl.numberOfPages = self.scrollView.contentSize.width/self.scrollView.frame.size.width;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];

    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)imagePickerControllerDidCancel:(PhotoPickerViewController *)picker
{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

#pragma mark - ScrollView layout method

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect workingFrame = self.scrollView.frame;
    workingFrame.origin.x = 0;

    for (UIView *v in [self.scrollView subviews]) {
        v.frame = workingFrame;
        workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
    }
    [self.scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
    CGFloat x = self.pageControl.currentPage * self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0)];
}

#pragma mark - UIScrollView Delegate methods

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
    NSInteger pageNumber = roundf(self.scrollView.contentOffset.x / (self.scrollView.frame.size.width));
    pageControl.currentPage = pageNumber;
}

#pragma mark - CustomImageView Delegate methods

- (void)playVideoWithURL:(NSURL *)videoURL
{
    NSString *url = [NSString stringWithFormat:@"%@",videoURL];
    if ([url rangeOfString:@"youtube"].location == NSNotFound) {
        
        self.videoPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideo:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.videoPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideo:) name:MPMoviePlayerDidExitFullscreenNotification object:self.videoPlayer];
        
        [self presentMoviePlayerViewControllerAnimated:self.videoPlayer];        
    }
    else
        [[UIApplication sharedApplication] openURL:videoURL];
}

#pragma mark - Notification Methods

-(void)stopVideo:(NSNotification*) aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.videoPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:self.videoPlayer];
    [self dismissMoviePlayerViewControllerAnimated];
}

@end
