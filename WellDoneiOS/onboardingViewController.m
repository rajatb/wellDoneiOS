//
//  onboardingViewController.m
//  WellDoneiOS
//
//  Created by Tyler Miller on 7/22/14.
//  Copyright (c) 2014 welldone. All rights reserved.
//

#import "onboardingViewController.h"
#import "LoginViewController.h"

@interface onboardingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageImageView;
@property (weak, nonatomic) IBOutlet UIImageView *positionMarkerImageView;

@end

@implementation onboardingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = YES;
    
    // Set to first center
    self.bgImageImageView.center = CGPointMake(480, self.bgImageImageView.center.y);
    
    // Animation
    
    [UIView animateWithDuration:.4 delay:0.1 usingSpringWithDamping:.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // Set to second center
        self.bgImageImageView.center = CGPointMake(160, self.bgImageImageView.center.y);
        
        // Move indicator 1
        self.positionMarkerImageView.center = CGPointMake(self.positionMarkerImageView.center.x +12, self.positionMarkerImageView.center.y);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.4 delay:0.1 usingSpringWithDamping:.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // Set to third center
            self.bgImageImageView.center = CGPointMake(-160, self.bgImageImageView.center.y);
            
            // Move indicator 1
            self.positionMarkerImageView.center = CGPointMake(self.positionMarkerImageView.center.x +12, self.positionMarkerImageView.center.y);
            
        } completion:^(BOOL finished) {
            // delay
            [NSTimer scheduledTimerWithTimeInterval:0.10f
                                             target:self selector:@selector(notif1:) userInfo:nil repeats:NO];
        }];
    }];

}


-(void) notif1: (NSTimer *) timer {
    // Switch VC
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
