//
//  NLLoginViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import "NLLoginViewController.h"
#import "NLTabBarController.h"

#import "NLAuthManager.h"
#import <Masonry/Masonry.h>
#import "NLGuestLoginService.h"

@interface NLLoginViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *buttonsContainer;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *googleButton;
@property (nonatomic, strong) UIButton *appleButton;
@property (nonatomic, strong) UIButton *guestLoginButton;
@property (nonatomic, strong) UILabel *registerHintLabel;
@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation NLLoginViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setNeedsStatusBarAppearanceUpdate];

    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.buttonsContainer];
    [self.view addSubview:self.registerHintLabel];
    [self.view addSubview:self.registerButton];

    [self setupConstraints];
}

#pragma mark - Layout

- (void)setupConstraints {
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(120);
        make.width.height.mas_equalTo(80);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    [self.buttonsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(40);
        make.left.right.equalTo(self.view).inset(20);
    }];

    NSArray *buttons = @[self.emailButton, self.phoneButton, self.facebookButton, self.googleButton, self.appleButton, self.guestLoginButton];
    UIButton *previousButton = nil;
    for (UIButton *button in buttons) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.buttonsContainer);
            make.height.mas_equalTo(50);
            if (previousButton) {
                make.top.equalTo(previousButton.mas_bottom).offset(12);
            } else {
                make.top.equalTo(self.buttonsContainer);
            }
        }];
        previousButton = button;
    }
    [previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.buttonsContainer);
    }];

    [self.registerHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
    }];
    [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.registerHintLabel);
        make.left.equalTo(self.registerHintLabel.mas_right).offset(4);
    }];
}

- (UIButton *)createLoginButtonWithTitle:(NSString *)title
                        backgroundColor:(UIColor *)backgroundColor
                              textColor:(UIColor *)textColor
                                    icon:(NSString *)iconName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = backgroundColor;
    button.layer.cornerRadius = 25;
    button.clipsToBounds = YES;

    // 标题
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];

    // 如果有图标
    if (iconName) {
        UIImage *icon = [UIImage systemImageNamed:iconName];
        UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
        iconView.tintColor = textColor;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [button addSubview:iconView];

        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(button).offset(20);
            make.centerY.equalTo(button);
            make.width.height.mas_equalTo(24);
        }];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    } else {
        // 没有图标，居中显示标题
        button.titleEdgeInsets = UIEdgeInsetsZero;
    }

    return button;
}



#pragma mark - Button Actions

- (void)backButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)phoneLoginTapped {
    NSLog(@"手机号登录");
    [self showLoginAlert];
}

- (void)emailLoginTapped {
    NSLog(@"电子邮件登录");
    [self showLoginAlert];
}

- (void)facebookLoginTapped {
    NSLog(@"Facebook登录");
    [self showLoginAlert];
}

- (void)googleLoginTapped {
    NSLog(@"Google登录");
    [self showLoginAlert];
}

- (void)appleLoginTapped {
    NSLog(@"Apple登录");
    [self showLoginAlert];
}

- (void)registerButtonTapped {
    NSLog(@"注册按钮点击");
    [self showLoginAlert];
}

- (void)guestLoginTapped {
    __weak typeof(self) weakSelf = self;
    [NLGuestLoginService anonymousLoginWithSuccess:^(NSDictionary *response) {
        NSString *cookie = response[@"cookie"];
        if (cookie.length > 0) {
            [NLAuthManager setCookie:cookie];
            // NSLog(@"[游客登录] 已取到 cookie，长度=%lu", (unsigned long)cookie.length); // 专注播放器时先注释
        } else {
            // NSLog(@"[游客登录] 登录成功但响应中无 cookie，code=%@", response[@"code"]); // 专注播放器时先注释
        }
        [NLAuthManager setLoginStateWithAccount:response[@"account"]];
        [weakSelf loginSuccess];
    } failure:^(NSError *error) {
        NSLog(@"[游客登录] 失败，未取到 cookie，错误: %@", error.localizedDescription);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"游客登录失败"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [weakSelf presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)showLoginAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"                           错误"
                                                                   message:@"当前不支持该方式登录"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loginSuccess {
    // 切换到主页面
    NLTabBarController *tabBarController = [[NLTabBarController alloc] init];
    // 动画切换
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;

    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [window.layer addAnimation:transition forKey:kCATransition];
    window.rootViewController = tabBarController;
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Getters

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.image = [UIImage imageNamed:@"spotify"];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logoImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"登录到 Spotify";
        _titleLabel.font = [UIFont boldSystemFontOfSize:24];
        _titleLabel.textColor = [UIColor labelColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)buttonsContainer {
    if (!_buttonsContainer) {
        _buttonsContainer = [[UIView alloc] init];
        [_buttonsContainer addSubview:self.emailButton];
        [_buttonsContainer addSubview:self.phoneButton];
        [_buttonsContainer addSubview:self.facebookButton];
        [_buttonsContainer addSubview:self.googleButton];
        [_buttonsContainer addSubview:self.appleButton];
        [_buttonsContainer addSubview:self.guestLoginButton];
    }
    return _buttonsContainer;
}

- (UIButton *)phoneButton {
    if (!_phoneButton) {
        _phoneButton = [self createLoginButtonWithTitle:@"手机号登录" backgroundColor:[UIColor secondarySystemBackgroundColor] textColor:[UIColor labelColor] icon:@"phone.fill"];
        [_phoneButton addTarget:self action:@selector(phoneLoginTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneButton;
}

- (UIButton *)emailButton {
    if (!_emailButton) {
        _emailButton = [self createLoginButtonWithTitle:@"使用电子邮件继续" backgroundColor:[UIColor systemGreenColor] textColor:[UIColor labelColor] icon:nil];
        [_emailButton addTarget:self action:@selector(emailLoginTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emailButton;
}

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        _facebookButton = [self createLoginButtonWithTitle:@"使用Facebook帐号继续" backgroundColor:[UIColor secondarySystemBackgroundColor] textColor:[UIColor labelColor] icon:@"f.circle.fill"];
        [_facebookButton addTarget:self action:@selector(facebookLoginTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _facebookButton;
}

- (UIButton *)googleButton {
    if (!_googleButton) {
        _googleButton = [self createLoginButtonWithTitle:@"使用Google帐号继续" backgroundColor:[UIColor secondarySystemBackgroundColor] textColor:[UIColor labelColor] icon:@"g.circle.fill"];
        [_googleButton addTarget:self action:@selector(googleLoginTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _googleButton;
}

- (UIButton *)appleButton {
    if (!_appleButton) {
        _appleButton = [self createLoginButtonWithTitle:@"使用Apple帐号继续" backgroundColor:[UIColor secondarySystemBackgroundColor] textColor:[UIColor labelColor] icon:@"apple.logo"];
        [_appleButton addTarget:self action:@selector(appleLoginTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _appleButton;
}

- (UIButton *)guestLoginButton {
    if (!_guestLoginButton) {
        _guestLoginButton = [self createLoginButtonWithTitle:@"游客登录" backgroundColor:[UIColor secondarySystemBackgroundColor] textColor:[UIColor labelColor] icon:nil];
        [_guestLoginButton addTarget:self action:@selector(guestLoginTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _guestLoginButton;
}

- (UILabel *)registerHintLabel {
    if (!_registerHintLabel) {
        _registerHintLabel = [[UILabel alloc] init];
        _registerHintLabel.text = @"尚未拥有帐号？";
        _registerHintLabel.font = [UIFont systemFontOfSize:14];
        _registerHintLabel.textColor = [UIColor tertiaryLabelColor];
    }
    return _registerHintLabel;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [_registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

@end

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
