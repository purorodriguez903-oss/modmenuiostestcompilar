//
//  Menu.mm
//  ModMenu
//
//  Created by Joey on 3/14/19.
//  Copyright © 2019 Joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"

@interface Menu ()

@property (assign, nonatomic) CGPoint lastMenuLocation;
@property (strong, nonatomic) UIView *header;
@property (strong, nonatomic) UIView *tabsView;
@property (strong, nonatomic) UIView *footer;
@property (strong, nonatomic) NSMutableArray<UIButton *> *tabButtons;

@end

@implementation Menu

NSUserDefaults *defaults;
UIScrollView *scrollView;
CGFloat menuWidth = 320.0f;
CGFloat menuHeight = 440.0f;
CGFloat scrollViewX = 0;
NSString *credits;
UIColor *switchOnColor;
NSString *switchTitleFont;
UIColor *switchTitleColor;
UIColor *infoButtonColor;
NSString *menuIconBase64;
NSString *menuButtonBase64;
float scrollViewHeight = 6.0f;
BOOL hasRestoredLastSession = false;
UIButton *menuButton;

const char *frameworkName = NULL;
UIWindow *mainWindow;

Menu *menu = [Menu alloc];
Switches *switches = [Switches alloc];

-(id)initWithTitle:(NSString *)title_ titleColor:(UIColor *)titleColor_ titleFont:(NSString *)titleFont_ credits:(NSString *)credits_ headerColor:(UIColor *)headerColor_ switchOffColor:(UIColor *)switchOffColor_ switchOnColor:(UIColor *)switchOnColor_ switchTitleFont:(NSString *)switchTitleFont_ switchTitleColor:(UIColor *)switchTitleColor_ infoButtonColor:(UIColor *)infoButtonColor_ maxVisibleSwitches:(int)maxVisibleSwitches_ menuWidth:(CGFloat )menuWidth_ menuIcon:(NSString *)menuIconBase64_ menuButton:(NSString *)menuButtonBase64_ {
    mainWindow = [UIApplication sharedApplication].keyWindow;
    defaults = [NSUserDefaults standardUserDefaults];

    menuWidth = 320.0f;
    menuHeight = 440.0f;
    switchOnColor = [UIColor colorWithRed:229.0f/255.0f green:29.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
    credits = credits_;
    switchTitleFont = switchTitleFont_;
    switchTitleColor = [UIColor whiteColor];
    infoButtonColor = switchOnColor;
    menuButtonBase64 = menuButtonBase64_;

    // Main Card Container Setup
    self = [super initWithFrame:CGRectMake(0, 0, menuWidth, menuHeight)];
    self.center = mainWindow.center;
    self.layer.opacity = 0.0f;
    self.backgroundColor = [UIColor colorWithRed:14.0f/255.0f green:14.0f/255.0f blue:18.0f/255.0f alpha:0.96f];
    self.layer.cornerRadius = 22.0f;
    self.layer.borderWidth = 1.5f;
    self.layer.borderColor = switchOnColor.CGColor;
    self.layer.masksToBounds = YES;

    // Header (Y: 0 to 62)
    self.header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, 62)];
    self.header.backgroundColor = [UIColor clearColor];
    [self addSubview:self.header];

    // Left Icon Badge Container
    UIView *iconContainer = [[UIView alloc] initWithFrame:CGRectMake(14, 10, 44, 44)];
    iconContainer.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:22.0f/255.0f blue:28.0f/255.0f alpha:1.0f];
    iconContainer.layer.cornerRadius = 22.0f;
    iconContainer.layer.borderWidth = 1.5f;
    iconContainer.layer.borderColor = switchOnColor.CGColor;
    iconContainer.clipsToBounds = YES;
    [self.header addSubview:iconContainer];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:menuIconBase64_ options:0];
    UIImage* menuIconImage = [UIImage imageWithData:data];

    UIButton *menuIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    menuIcon.frame = CGRectMake(0, 0, 44, 44);
    menuIcon.backgroundColor = [UIColor clearColor];
    [menuIcon setBackgroundImage:menuIconImage forState:UIControlStateNormal];
    [menuIcon addTarget:self action:@selector(menuIconTapped) forControlEvents:UIControlEventTouchUpInside];
    [iconContainer addSubview:menuIcon];

    // Crown label on top of badge
    UILabel *crownLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 44, 14)];
    crownLbl.text = @"👑";
    crownLbl.font = [UIFont systemFontOfSize:10.0f];
    crownLbl.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview:crownLbl];

    // Title: RAFA iOS (dual-tone)
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:@"RAFA " attributes:@{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0f],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    }];
    NSAttributedString *attrIos = [[NSAttributedString alloc] initWithString:@"iOS" attributes:@{
        NSFontAttributeName: [UIFont italicSystemFontOfSize:20.0f],
        NSForegroundColorAttributeName: switchOnColor
    }];
    [attrTitle appendAttributedString:attrIos];

    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(68, 12, 180, 24)];
    titleLbl.attributedText = attrTitle;
    [self.header addSubview:titleLbl];

    // Subtitle: — MOD MENU —
    UILabel *subTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(68, 36, 180, 14)];
    subTitleLbl.text = @"— MOD MENU —";
    subTitleLbl.textColor = [UIColor colorWithRed:126.0f/255.0f green:126.0f/255.0f blue:138.0f/255.0f alpha:1.0f];
    subTitleLbl.font = [UIFont systemFontOfSize:10.0f weight:UIFontWeightBold];
    [self.header addSubview:subTitleLbl];

    // Tabs Bar (Y: 62 to 94)
    self.tabsView = [[UIView alloc] initWithFrame:CGRectMake(0, 62, menuWidth, 34)];
    self.tabsView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tabsView];

    self.tabButtons = [NSMutableArray new];
    NSArray *tabTitles = @[@"⚙️ Main", @"🚀 Player", @"🎯 ESP", @"⚙️ Misc"];
    CGFloat tabW = (menuWidth - 24.0f - 18.0f) / 4.0f; // ~69pt each
    for (int i = 0; i < 4; i++) {
        UIButton *tBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tBtn.frame = CGRectMake(12.0f + i * (tabW + 6.0f), 2.0f, tabW, 28.0f);
        tBtn.layer.cornerRadius = 14.0f;
        tBtn.titleLabel.font = [UIFont systemFontOfSize:10.5f weight:UIFontWeightBold];
        [tBtn setTitle:tabTitles[i] forState:UIControlStateNormal];
        tBtn.tag = i;
        if (i == 0) {
            tBtn.backgroundColor = switchOnColor;
            [tBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            tBtn.backgroundColor = [UIColor colorWithRed:26.0f/255.0f green:26.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
            [tBtn setTitleColor:[UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:158.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        }
        [tBtn addTarget:self action:@selector(tabClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabButtons addObject:tBtn];
        [self.tabsView addSubview:tBtn];
    }

    // ScrollView for items (Y: 98 to 345)
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 98, menuWidth, 246)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];

    // Info Banner (Y: 348 to 378)
    UIView *infoBanner = [[UIView alloc] initWithFrame:CGRectMake(12, 348, menuWidth - 24, 30)];
    infoBanner.backgroundColor = [UIColor colorWithRed:20.0f/255.0f green:20.0f/255.0f blue:28.0f/255.0f alpha:1.0f];
    infoBanner.layer.cornerRadius = 10.0f;
    infoBanner.layer.borderWidth = 0.5f;
    infoBanner.layer.borderColor = [UIColor colorWithRed:35.0f/255.0f green:35.0f/255.0f blue:46.0f/255.0f alpha:1.0f].CGColor;
    
    UILabel *infoIcon = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 20, 20)];
    infoIcon.text = @"ⓘ";
    infoIcon.textColor = switchOnColor;
    infoIcon.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightBold];
    [infoBanner addSubview:infoIcon];

    UILabel *infoText = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 230, 20)];
    infoText.text = @"Enjoy the Mod Menu!";
    infoText.textColor = [UIColor colorWithRed:180.0f/255.0f green:180.0f/255.0f blue:195.0f/255.0f alpha:1.0f];
    infoText.font = [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium];
    [infoBanner addSubview:infoText];
    [self addSubview:infoBanner];

    // Footer (Y: 384 to 430)
    self.footer = [[UIView alloc] initWithFrame:CGRectMake(0, 384, menuWidth, 46)];
    self.footer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.footer];

    UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 170, 22)];
    footerLbl.text = @"👤 Rafa iOS  |  👑 v1.0";
    footerLbl.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:158.0f/255.0f alpha:1.0f];
    footerLbl.font = [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium];
    [self.footer addSubview:footerLbl];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(menuWidth - 96, 7, 84, 30);
    closeBtn.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:22.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
    closeBtn.layer.cornerRadius = 15.0f;
    closeBtn.layer.borderWidth = 1.0f;
    closeBtn.layer.borderColor = switchOnColor.CGColor;
    [closeBtn setTitle:@"✕ Close" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideMenuAction) forControlEvents:UIControlEventTouchUpInside];
    [self.footer addSubview:closeBtn];

    // Drag recognizer
    UIPanGestureRecognizer *dragMenuRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(menuDragged:)];
    [self.header addGestureRecognizer:dragMenuRecognizer];

    [mainWindow addSubview:self];
    [self showMenuButton];

    return self;
}

-(void)tabClicked:(UIButton *)sender {
    for (UIButton *btn in self.tabButtons) {
        if (btn == sender) {
            btn.backgroundColor = switchOnColor;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            btn.backgroundColor = [UIColor colorWithRed:26.0f/255.0f green:26.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
            [btn setTitleColor:[UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:158.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.lastMenuLocation = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    [super touchesBegan:touches withEvent:event];
}

- (void)menuDragged:(UIPanGestureRecognizer *)pan {
    CGPoint newLocation = [pan translationInView:self.superview];
    self.frame = CGRectMake(self.lastMenuLocation.x + newLocation.x, self.lastMenuLocation.y + newLocation.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

-(void)hideMenuAction {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
        menuButton.alpha = 1.0f;
    }];
}

-(void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        menuButton.alpha = 0.0f;
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0f;
        }];
    }
    if(!hasRestoredLastSession) {
        restoreLastSession();
        hasRestoredLastSession = true;
    }
}

void restoreLastSession() {
    for(id switch_ in scrollView.subviews) {
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            BOOL isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
            for(int i = 0; i < memoryPatches.size(); i++) {
                if(isOn){
                    memoryPatches[i].Modify();
                } else {
                    memoryPatches[i].Restore();
                }
            }
            [((OffsetSwitch*)switch_) setSwitchOn:isOn];
        }
    }
}

-(void)showMenuButton {
    NSData* data = [[NSData alloc] initWithBase64EncodedString:menuButtonBase64 options:0];
    UIImage* menuButtonImage = [UIImage imageWithData:data];

    menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuButton.frame = CGRectMake((mainWindow.frame.size.width/2), (mainWindow.frame.size.height/2), 50, 50);
    menuButton.backgroundColor = [UIColor clearColor];
    [menuButton setBackgroundImage:menuButtonImage forState:UIControlStateNormal];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [menuButton addGestureRecognizer:tapGestureRecognizer];

    [menuButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];

    [mainWindow addSubview:menuButton];
}

- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;
    button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);
}

-(void)menuIconTapped {
    [self showPopup:@"Credits" description:credits];
    self.layer.opacity = 0.0f;
}

-(void)showPopup:(NSString *)title_ description:(NSString *)description_ {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];

    alert.shouldDismissOnTapOutside = NO;
    alert.customViewColor = [UIColor colorWithRed:229.0f/255.0f green:29.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

    [alert addButton: @"Ok!" actionBlock: ^(void) {
        self.layer.opacity = 1.0f;
    }];

    [alert showInfo:title_ subTitle:description_ closeButtonTitle:nil duration:9999999.0f];
}

- (void)addSwitchToMenu:(id)switch_ {
    CGFloat cardH = 54.0f;
    CGFloat spacing = 6.0f;
    ((UIView*)switch_).frame = CGRectMake(12.0f, scrollViewHeight, menuWidth - 24.0f, cardH);
    scrollViewHeight += cardH + spacing;
    scrollView.contentSize = CGSizeMake(menuWidth, scrollViewHeight + 10.0f);
    [scrollView addSubview:switch_];
}

- (void)changeSwitchBackground:(id)switch_ isSwitchOn:(BOOL)isSwitchOn_ {
    if([switch_ isKindOfClass:[OffsetSwitch class]]) {
        [((OffsetSwitch*)switch_) setSwitchOn:!isSwitchOn_];
    }
    [defaults setBool:!isSwitchOn_ forKey:[switch_ getPreferencesKey]];
}

-(void)switchClicked:(id)switch_ {
    BOOL isOn = [defaults boolForKey:[switch_ getPreferencesKey]];

    if([switch_ isKindOfClass:[OffsetSwitch class]]) {
        std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
        for(int i = 0; i < memoryPatches.size(); i++) {
            if(!isOn){
                memoryPatches[i].Modify();
            } else {
                memoryPatches[i].Restore();
            }
        }
    }

    [self changeSwitchBackground:switch_ isSwitchOn:isOn];
}

-(void)setFrameworkName:(const char *)name_ {
    frameworkName = name_;
}

-(const char *)getFrameworkName {
    return frameworkName;
}

@end


/****************************************
    FLOATING SWITCH VIEW (HUD WIDGET)
*****************************************/

@implementation FloatingSwitchView

-(id)initWithOffsetSwitch:(OffsetSwitch *)parent {
    CGFloat startY = 110.0f + (arc4random_uniform(4) * 44.0f);
    CGFloat startX = mainWindow.frame.size.width - 146.0f;
    if (startX < 20.0f) startX = 180.0f;

    self = [super initWithFrame:CGRectMake(startX, startY, 140.0f, 36.0f)];
    if (self) {
        self.parentSwitch = parent;
        self.backgroundColor = [UIColor colorWithRed:14.0f/255.0f green:14.0f/255.0f blue:20.0f/255.0f alpha:0.92f];
        self.layer.cornerRadius = 18.0f;
        self.layer.borderWidth = 1.2f;
        self.layer.borderColor = [UIColor colorWithRed:229.0f/255.0f green:29.0f/255.0f blue:46.0f/255.0f alpha:0.95f].CGColor;
        self.clipsToBounds = YES;

        // Close button 'x' (left)
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(4.0f, 6.0f, 20.0f, 24.0f);
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:11.0f weight:UIFontWeightBold];
        [closeBtn setTitleColor:[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:210.0f/255.0f alpha:0.85f] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];

        // Switch Name Label (center)
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(26.0f, 8.0f, 66.0f, 20.0f)];
        self.nameLabel.text = [parent getPreferencesKey];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:10.5f];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.nameLabel];

        // Mini UISwitch (right)
        self.miniSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(92.0f, 3.0f, 38.0f, 24.0f)];
        self.miniSwitch.transform = CGAffineTransformMakeScale(0.65f, 0.65f);
        self.miniSwitch.onTintColor = [UIColor colorWithRed:229.0f/255.0f green:29.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
        [self.miniSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:[parent getPreferencesKey]] animated:NO];
        [self.miniSwitch addTarget:self action:@selector(miniSwitchToggled:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.miniSwitch];

        // Pan gesture to drag anywhere on screen
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

-(void)closeTapped {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
        [self.parentSwitch floatingClosed];
    }];
}

-(void)miniSwitchToggled:(UISwitch *)sender {
    [self.parentSwitch setSwitchOn:sender.isOn];
    [self.parentSwitch toggleSwitchChanged:sender];
}

-(void)updateSwitchState:(BOOL)isOn {
    [self.miniSwitch setOn:isOn animated:YES];
}

-(void)handlePan:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.lastLocation = self.center;
    }
    CGPoint translation = [pan translationInView:self.superview];
    self.center = CGPointMake(self.lastLocation.x + translation.x, self.lastLocation.y + translation.y);
}

@end


/********************************
    OFFSET SWITCH STARTS HERE!
*********************************/

@implementation OffsetSwitch {
    std::vector<MemoryPatch> memoryPatches;
}

- (id)initHackNamed:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::vector<uint64_t>)offsets_ bytes:(std::vector<std::string>)bytes_ {
    description = description_;
    preferencesKey = hackName_;

    for(int i = 0; i < offsets_.size(); i++) {
        MemoryPatch patch = MemoryPatch::createWithHex([menu getFrameworkName], offsets_[i], bytes_[i]);
        if(patch.isValid()) {
            memoryPatches.push_back(patch);
        }
    }

    self = [super initWithFrame:CGRectMake(12, 0, menuWidth - 24, 54)];
    self.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:22.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
    self.layer.cornerRadius = 12.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor colorWithRed:35.0f/255.0f green:35.0f/255.0f blue:46.0f/255.0f alpha:1.0f].CGColor;
    self.adjustsImageWhenHighlighted = NO;

    // Icon container
    UIView *iconBg = [[UIView alloc] initWithFrame:CGRectMake(10, 11, 32, 32)];
    iconBg.backgroundColor = [UIColor colorWithRed:28.0f/255.0f green:28.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    iconBg.layer.cornerRadius = 8.0f;
    iconBg.userInteractionEnabled = NO;
    [self addSubview:iconBg];

    UILabel *iconLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    iconLbl.textAlignment = NSTextAlignmentCenter;
    iconLbl.font = [UIFont systemFontOfSize:16.0f];
    NSString *lower = [hackName_ lowercaseString];
    if ([lower containsString:@"god"]) {
        iconLbl.text = @"👑";
    } else if ([lower containsString:@"kill"] || [lower containsString:@"hit"]) {
        iconLbl.text = @"💀";
    } else if ([lower containsString:@"gold"] || [lower containsString:@"money"]) {
        iconLbl.text = @"💎";
    } else if ([lower containsString:@"speed"]) {
        iconLbl.text = @"⚡";
    } else {
        iconLbl.text = @"🚀";
    }
    [iconBg addSubview:iconLbl];

    // Title
    switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 9, 140, 18)];
    switchLabel.text = hackName_;
    switchLabel.textColor = [UIColor whiteColor];
    switchLabel.font = [UIFont boldSystemFontOfSize:13.5f];
    [self addSubview:switchLabel];

    // Subtitle
    subLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 28, 140, 14)];
    subLabel.text = description_;
    subLabel.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:158.0f/255.0f alpha:1.0f];
    subLabel.font = [UIFont systemFontOfSize:10.0f];
    [self addSubview:subLabel];

    // Pin Button for Floating HUD toggle (X: menuWidth - 24 - 88)
    pinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pinBtn.frame = CGRectMake(menuWidth - 24 - 88, 14, 28, 26);
    [pinBtn setTitle:@"📌" forState:UIControlStateNormal];
    pinBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    pinBtn.alpha = 0.5f;
    [pinBtn addTarget:self action:@selector(pinTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pinBtn];

    // Right-aligned UISwitch
    toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(menuWidth - 24 - 54, 12, 48, 28)];
    toggleSwitch.onTintColor = [UIColor colorWithRed:229.0f/255.0f green:29.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
    toggleSwitch.transform = CGAffineTransformMakeScale(0.82f, 0.82f);
    BOOL isOn = [defaults boolForKey:preferencesKey];
    [toggleSwitch setOn:isOn animated:NO];
    [toggleSwitch addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:toggleSwitch];

    [self addTarget:self action:@selector(cardTapped) forControlEvents:UIControlEventTouchUpInside];

    return self;
}

-(void)pinTapped {
    if (floatingView && floatingView.superview) {
        [floatingView closeTapped];
    } else {
        floatingView = [[FloatingSwitchView alloc] initWithOffsetSwitch:self];
        [mainWindow addSubview:floatingView];
        pinBtn.alpha = 1.0f;
    }
}

-(void)floatingClosed {
    pinBtn.alpha = 0.5f;
    floatingView = nil;
}

-(void)cardTapped {
    [toggleSwitch setOn:!toggleSwitch.isOn animated:YES];
    [self toggleSwitchChanged:toggleSwitch];
}

-(void)toggleSwitchChanged:(UISwitch *)sw {
    BOOL on = sw.isOn;
    for(int i = 0; i < memoryPatches.size(); i++) {
        if(on) {
            memoryPatches[i].Modify();
        } else {
            memoryPatches[i].Restore();
        }
    }
    [defaults setBool:on forKey:preferencesKey];
    if (floatingView) {
        [floatingView updateSwitchState:on];
    }
}

-(void)setSwitchOn:(BOOL)on {
    [toggleSwitch setOn:on animated:YES];
    if (floatingView) {
        [floatingView updateSwitchState:on];
    }
}

-(UISwitch *)getToggleSwitch {
    return toggleSwitch;
}

-(void)showInfo:(UIGestureRecognizer *)gestureRec {
    if(gestureRec.state == UIGestureRecognizerStateEnded) {
        [menu showPopup:[self getPreferencesKey] description:[self getDescription]];
    }
}

-(NSString *)getPreferencesKey { return preferencesKey; }
-(NSString *)getDescription { return description; }
-(std::vector<MemoryPatch>)getMemoryPatches { return memoryPatches; }

@end


/**************************************
    TEXTFIELD SWITCH STARTS HERE!
***************************************/

@implementation TextFieldSwitch {
    UIButton *minusBtn;
    UIButton *plusBtn;
}

- (id)initTextfieldNamed:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    self = [super initHackNamed:hackName_ description:description_ offsets:std::vector<uint64_t>{} bytes:std::vector<std::string>{}];
    
    // Hide toggleSwitch and pinBtn since this is a textfield stepper
    [toggleSwitch setHidden:YES];
    [pinBtn setHidden:YES];
    
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];

    CGFloat rightX = menuWidth - 24 - 108;
    
    minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    minusBtn.frame = CGRectMake(rightX, 12, 26, 30);
    minusBtn.backgroundColor = [UIColor colorWithRed:36.0f/255.0f green:36.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
    minusBtn.layer.cornerRadius = 6.0f;
    [minusBtn setTitle:@"−" forState:UIControlStateNormal];
    minusBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [minusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [minusBtn addTarget:self action:@selector(minusTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:minusBtn];

    textfieldValue = [[UITextField alloc] initWithFrame:CGRectMake(rightX + 30, 12, 48, 30)];
    textfieldValue.backgroundColor = [UIColor colorWithRed:14.0f/255.0f green:14.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    textfieldValue.layer.cornerRadius = 6.0f;
    textfieldValue.layer.borderWidth = 0.5f;
    textfieldValue.layer.borderColor = [UIColor colorWithRed:45.0f/255.0f green:45.0f/255.0f blue:56.0f/255.0f alpha:1.0f].CGColor;
    textfieldValue.textColor = [UIColor whiteColor];
    textfieldValue.textAlignment = NSTextAlignmentCenter;
    textfieldValue.font = [UIFont boldSystemFontOfSize:12.0f];
    textfieldValue.delegate = self;
    textfieldValue.text = @"99999";
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        textfieldValue.text = [[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey];
    }
    [self addSubview:textfieldValue];

    plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    plusBtn.frame = CGRectMake(rightX + 82, 12, 26, 30);
    plusBtn.backgroundColor = [UIColor colorWithRed:36.0f/255.0f green:36.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
    plusBtn.layer.cornerRadius = 6.0f;
    [plusBtn setTitle:@"+" forState:UIControlStateNormal];
    plusBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [plusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [plusBtn addTarget:self action:@selector(plusTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:plusBtn];

    return self;
}

-(void)minusTapped {
    long long val = [textfieldValue.text longLongValue];
    if (val > 1000) val -= 1000;
    else if (val > 0) val = 0;
    textfieldValue.text = [NSString stringWithFormat:@"%lld", val];
    [defaults setObject:textfieldValue.text forKey:[self getSwitchValueKey]];
}

-(void)plusTapped {
    long long val = [textfieldValue.text longLongValue];
    val += 1000;
    textfieldValue.text = [NSString stringWithFormat:@"%lld", val];
    [defaults setObject:textfieldValue.text forKey:[self getSwitchValueKey]];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textfieldValue_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    [defaults setObject:textfieldValue_.text forKey:[self getSwitchValueKey]];
    [textfieldValue_ resignFirstResponder];
    return true;
}

-(NSString *)getSwitchValueKey { return switchValueKey; }
-(UITextField *)getTextField { return textfieldValue; }

@end


/*******************************
    SLIDER SWITCH STARTS HERE!
*******************************/

@implementation SliderSwitch {
    float minVal;
    float maxVal;
}

- (id)initSliderNamed:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_{
    self = [super initTextfieldNamed:hackName_ description:description_ inputBorderColor:sliderColor_];
    
    minVal = minimumValue_;
    maxVal = maximumValue_;
    sliderVal = 5.0f;

    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    if([[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey]) {
        sliderVal = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
    }
    
    textfieldValue.text = [NSString stringWithFormat:@"%.1f", sliderVal];

    return self;
}

-(void)minusTapped {
    sliderVal = [textfieldValue.text floatValue];
    sliderVal -= 0.5f;
    if (sliderVal < minVal) sliderVal = minVal;
    textfieldValue.text = [NSString stringWithFormat:@"%.1f", sliderVal];
    [defaults setFloat:sliderVal forKey:[self getSwitchValueKey]];
}

-(void)plusTapped {
    sliderVal = [textfieldValue.text floatValue];
    sliderVal += 0.5f;
    if (sliderVal > maxVal) sliderVal = maxVal;
    textfieldValue.text = [NSString stringWithFormat:@"%.1f", sliderVal];
    [defaults setFloat:sliderVal forKey:[self getSwitchValueKey]];
}

@end


/*******************************
    SWITCHES CONTAINER
*******************************/

@implementation Switches

-(void)addSwitch:(NSString *)hackName_ description:(NSString *)description_ {
    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc] initHackNamed:hackName_ description:description_ offsets:std::vector<uint64_t>{} bytes:std::vector<std::string>{}];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::initializer_list<uint64_t>)offsets_ bytes:(std::initializer_list<std::string>)bytes_ {
    std::vector<uint64_t> offsetVector;
    std::vector<std::string> bytesVector;

    offsetVector.insert(offsetVector.begin(), offsets_.begin(), offsets_.end());
    bytesVector.insert(bytesVector.begin(), bytes_.begin(), bytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc] initHackNamed:hackName_ description:description_ offsets:offsetVector bytes:bytesVector];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addTextfieldSwitch:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc] initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToMenu:textfieldSwitch];
}

- (void)addSliderSwitch:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToMenu:sliderSwitch];
}

- (NSString *)getValueFromSwitch:(NSString *)name {
    NSString *correctKey = [name stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];

    if([[NSUserDefaults standardUserDefaults] objectForKey:correctKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:correctKey];
    }
    else if([[NSUserDefaults standardUserDefaults] floatForKey:correctKey]) {
        return [NSString stringWithFormat:@"%f", [[NSUserDefaults standardUserDefaults] floatForKey:correctKey]];
    }

    return 0;
}

-(bool)isSwitchOn:(NSString *)switchName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:switchName];
}

@end
