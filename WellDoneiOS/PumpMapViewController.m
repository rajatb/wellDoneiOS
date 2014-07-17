//
//  PumpMapViewController.m
//  WellDoneiOS
//
//  Created by Aparna Jain on 7/12/14.
//  Copyright (c) 2014 welldone. All rights reserved.
//

#import "PumpMapViewController.h"
#import "PumpDetailViewController.h"

#define METERS_PER_MILE 1609.344

@interface PumpMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) NSMutableArray *pumpViewControllers;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *bottomPanGestureRecognizer;
@property (nonatomic, assign) CGPoint bottomContainerCenter;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGFloat initialY;
@property (nonatomic, assign) BOOL firstLoad;

- (UIViewController *)pumpViewControllerAtIndex:(int)index;
- (IBAction)onBottomPan:(UIPanGestureRecognizer *)sender;
@end

@implementation PumpMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.firstLoad = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self loadPumps];

    self.bottomPanGestureRecognizer.delegate = self;
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self addChildViewController:self.pageViewController];
    

    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    self.pageViewController.view.frame = self.viewContainer.bounds;
    [self.viewContainer addSubview:self.pageViewController.view];    
    
    [self.pageViewController didMoveToParentViewController:self];
    self.initialY = self.viewContainer.frame.origin.y;
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark PageviewController delegate methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    int index = (int)[self.pumpViewControllers indexOfObject:viewController];
    
    if (index > 0) {
//        self.pump = self.pumps[index-1];
        return [self pumpViewControllerAtIndex:index - 1];
    } else {
        return nil;
    }
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    int index = (int)[self.pumpViewControllers indexOfObject:viewController];
    if (index < self.pumpViewControllers.count - 1) {
//        self.pump = self.pumps[index+1];
        return [self pumpViewControllerAtIndex:index + 1];
    } else {
        return nil;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers NS_AVAILABLE_IOS(6_0){
        self.panGestureRecognizer.enabled = YES;
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    int index = (int)[self.pumpViewControllers indexOfObject:pageViewController.viewControllers[0]];
    self.pump = self.pumps[index];
}

- (UIViewController *)pumpViewControllerAtIndex:(int)index {
    return self.pumpViewControllers[index];
}

#pragma mark Pan handler

- (IBAction)onBottomPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    self.panGestureRecognizer = panGestureRecognizer;
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
   
    if (fabs(velocity.y) > fabs(velocity.x)) {
        [self disablePageViewController];
        panGestureRecognizer.enabled = YES;
    }else {
        [self enablePageViewController];
        panGestureRecognizer.enabled = NO;
    }

    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touch = [panGestureRecognizer locationInView:self.viewContainer];
        if (touch.y > 50) {
            // Cancel current gesture
        }
        self.bottomContainerCenter = self.viewContainer.center;
        // Disable Page View Controller
        
        if (fabs(velocity.y) > fabs(velocity.x)) {
            [self disablePageViewController];
            panGestureRecognizer.enabled = YES;
        }else {
            [self enablePageViewController];
            panGestureRecognizer.enabled = NO;
        }

    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.viewContainer.center = CGPointMake(self.bottomContainerCenter.x, self.bottomContainerCenter.y + translation.y);
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // Enable Page View Controller
        [UIView animateWithDuration:0.5 animations:^{
            if (velocity.y < 0) {
                self.viewContainer.center = self.view.center;
            } else { //going down
                self.viewContainer.frame = CGRectMake(0, self.initialY, self.view.frame.size.width, self.view.frame.size.height);
                self.viewContainer.alpha = 1;
            }
 
        }];
    }
}
- (void) disablePageViewController{
    for (UIScrollView *view  in self.pageViewController.view.subviews) {
        if([view isKindOfClass:[UIScrollView class]]){
            view.scrollEnabled = NO;
        }
    }
}
- (void) enablePageViewController{
    for (UIScrollView *view  in self.pageViewController.view.subviews) {
        if([view isKindOfClass:[UIScrollView class]]){
            view.scrollEnabled = YES;
        }
    }
}

#pragma mark- Setting up pageviews and adding annotations
- (void) setUpView {
//    [self plotPump:self.pump];
    self.pumpViewControllers = [NSMutableArray array];
    
    for (Pump *p in self.pumps) {
//        [self plotPump:p];
        if(self.firstLoad){
            PumpDetailViewController *currPumpController = [[PumpDetailViewController alloc] init];
            // TODO: Only if there are performance issues with 20 view controllers, then switch to using a dictionary and lazy create the view controllers. The key of the dictionary is the index of the pump.
            currPumpController.pump = p;
            [self.pumpViewControllers addObject:currPumpController];
        }
    }
    self.firstLoad = NO;
    [self.pageViewController setViewControllers:@[self.pumpViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
}

//TODO: remove this call from here
- (void) loadPumps {
    PFQuery *queryForReports = [Pump query];
    [queryForReports findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.pumps = objects;
            //TODO: remove this line and tie it to a pump being clicked on the list view?
            self.pump = self.pumps[0];
            [self setUpView];
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
- (void)setPump:(Pump *)pump {
    _pump = pump;
    [self loadMapAtRegion];
    [self plotPump:pump];
}
- (void)loadMapAtRegion {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.pump.location.latitude;
    coordinate.longitude = self.pump.location.longitude;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, 1.0*METERS_PER_MILE, 1.0*METERS_PER_MILE)];
}

- (void)plotPump:(Pump *)pump {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:pump];
}

#pragma mark MapView delegate methods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //add a delay here and test
    [self.mapView selectAnnotation:self.pump animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{

    Pump *pump = (Pump *)annotation;
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation)
    {
        static NSString *defaultPinID = @"map.welldone";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];

        pinView.canShowCallout = YES;
        if (pump == self.pump) {
            pinView.image = [UIImage imageNamed:@"177-building"];
        }else {
            pinView.image = [UIImage imageNamed:@"07-map-marker"];
        }

    }
    else {
        [self.mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    for (MKAnnotationView *annView in annotationViews)
    {
        CGRect endFrame = annView.frame;
        annView.frame = CGRectOffset(endFrame, 0, -500);
//        [UIView animateWithDuration:0.9
//                         animations:^{ annView.frame = endFrame; }];
    }
}

-(void)onListButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
