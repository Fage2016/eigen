#import <Forgeries/ForgeriesUserDefaults.h>

#import "ARDefaults.h"
#import "ARAugmentedVIRSetupViewController.h"

@interface ARAugmentedVIRSetupViewController ()
@property (nonatomic, copy) NSUserDefaults *defaults;

- (void)back;
- (NSString *)subtitleWithDefaults:(NSUserDefaults *)defaults hasPermission:(BOOL)hasPermission;
- (NSString *)buttonTitleWithDefaults:(NSUserDefaults *)defaults hasPermission:(BOOL)hasPermission;
- (SEL)buttonSelectorWithDefaults:(NSUserDefaults *)defaults hasPermission:(BOOL)hasPermission;

@end


SpecBegin(ARAugmentRealitySetupViewController);
__block ForgeriesUserDefaults *untouchedDefaults;
__block ForgeriesUserDefaults *deniedDefaults;
__block ForgeriesUserDefaults *completedDefaults;
__block ForgeriesUserDefaults *setupButNotRanDefaults;

beforeEach(^{
    untouchedDefaults = [ForgeriesUserDefaults defaults:@{
        ARAugmentedRealityCameraAccessGiven: @(NO),
        ARAugmentedRealityHasSeenSetup: @(NO),
        ARAugmentedRealityHasSuccessfullyRan: @(NO)
    }];

    deniedDefaults = [ForgeriesUserDefaults defaults:@{
        ARAugmentedRealityCameraAccessGiven: @(NO),
        ARAugmentedRealityHasSeenSetup: @(YES),
        ARAugmentedRealityHasSuccessfullyRan: @(YES)
    }];

    completedDefaults = [ForgeriesUserDefaults defaults:@{
        ARAugmentedRealityCameraAccessGiven: @(YES),
        ARAugmentedRealityHasSeenSetup: @(YES),
        ARAugmentedRealityHasSuccessfullyRan: @(YES)
    }];

    setupButNotRanDefaults = [ForgeriesUserDefaults defaults:@{
        ARAugmentedRealityCameraAccessGiven: @(YES),
        ARAugmentedRealityHasSeenSetup: @(YES),
        ARAugmentedRealityHasSuccessfullyRan: @(NO)
    }];
});


it(@"gives the right messages for the right setup",^{
    ARAugmentedVIRSetupViewController *vc = [[ARAugmentedVIRSetupViewController alloc] initWithMovieURL:nil config:nil];

    expect([vc subtitleWithDefaults:(id)untouchedDefaults hasPermission:NO]).to.equal(@"To view works in your room, we'll need access to your camera.");
    expect([vc subtitleWithDefaults:(id)untouchedDefaults hasPermission:YES]).to.equal(@"To view works in your room using augmented reality, find a wall and [something].");

    expect([vc subtitleWithDefaults:(id)deniedDefaults hasPermission:NO]).to.equal(@"To view works in your room using augmented reality, we’ll need access to your camera. \n\nPlease update camera access permissions in the iOS settings.");
    // Should never happen
    expect([vc subtitleWithDefaults:(id)deniedDefaults hasPermission:YES]).to.equal(@"To view works in your room using augmented reality, we’ll need access to your camera. \n\nPlease update camera access permissions in the iOS settings.");

    expect([vc subtitleWithDefaults:(id)completedDefaults hasPermission:NO]).to.equal(@"To view works in your room using augmented reality, we’ll need access to your camera. \n\nPlease update camera access permissions in the iOS settings.");
    // Should never happen
    expect([vc subtitleWithDefaults:(id)completedDefaults hasPermission:YES]).to.equal(@"To view works in your room using augmented reality, we’ll need access to your camera. \n\nPlease update camera access permissions in the iOS settings.");

    expect([vc subtitleWithDefaults:(id)setupButNotRanDefaults hasPermission:NO]).to.equal(@"To view works in your room using augmented reality, find a wall and [something].");
    expect([vc subtitleWithDefaults:(id)setupButNotRanDefaults hasPermission:YES]).to.equal(@"To view works in your room using augmented reality, find a wall and [something].");
});


it(@"defaults to asking for camera access",^{
    ARAugmentedVIRSetupViewController *vc = [[ARAugmentedVIRSetupViewController alloc] initWithMovieURL:nil config:nil ];
    vc.defaults = (id)untouchedDefaults;

    expect(vc).to.haveValidSnapshot();
});

it(@"viewWillAppear sets ARAugmentedRealityHasSeenSetup",^{
    ForgeriesUserDefaults *defaults = [ForgeriesUserDefaults defaults:@{
      ARAugmentedRealityHasSeenSetup: @(NO)
    }];

    ARAugmentedVIRSetupViewController *vc = [[ARAugmentedVIRSetupViewController alloc] initWithMovieURL:nil config:nil];
    vc.defaults = (id)defaults;
    [vc viewWillAppear:NO];

    expect([defaults boolForKey:ARAugmentedRealityHasSeenSetup]).to.beTruthy();
});


it(@"has different settings when denied access",^{
    ARAugmentedVIRSetupViewController *vc = [[ARAugmentedVIRSetupViewController alloc] initWithMovieURL:nil config:nil];
    vc.defaults = (id)deniedDefaults;
    expect(vc).to.haveValidSnapshot();
});


it(@"has different settings when you have given access but not succedded in putting a work on the wall",^{
    ARAugmentedVIRSetupViewController *vc = [[ARAugmentedVIRSetupViewController alloc] initWithMovieURL:nil config:nil];
    vc.defaults = (id)setupButNotRanDefaults;
    expect(vc).to.haveValidSnapshot();
});


describe(@"canSkipARSetup", ^{
    it(@"returns true with the right defaults",^{
        __block BOOL called = NO;
        [ARAugmentedVIRSetupViewController canSkipARSetup:(id)completedDefaults callback:^(bool shouldSkipSetup) {
            called = YES;
            expect(shouldSkipSetup).to.beTruthy();
        }];

        // In prod, this won't be sync, but we want to verify the code actually ran
        expect(called).to.beTruthy();
    });

    it(@"returns false with incomplete defaults",^{
        __block BOOL called = NO;
        [ARAugmentedVIRSetupViewController canSkipARSetup:(id)deniedDefaults callback:^(bool shouldSkipSetup) {
            called = YES;
            expect(shouldSkipSetup).to.beFalsy();
        }];

        // Also verify synchronous behavior
        expect(called).to.beTruthy();
    });
});


describe(@"canOpenARView", ^{
    it(@"returns false, because tests run on iOS 10",^{
        expect([ARAugmentedVIRSetupViewController canOpenARView]).to.beFalsy();
    });
});


describe(@"back", ^{
    it(@"calls pop",^{
        id navMock = [OCMockObject mockForClass:[UINavigationController class]];
        [[navMock stub] popViewControllerAnimated:NO];

        ARAugmentedVIRSetupViewController *vc = [[ARAugmentedVIRSetupViewController alloc] initWithMovieURL:nil config:nil];
        [vc back];
        [navMock verify];
    });
});

SpecEnd;

