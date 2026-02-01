//
//  NLLoginViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import "NLLoginViewController.h"
#import "NLTabBarController.h"
#import "NLPhoneLoginViewController.h"
#import <Masonry/Masonry.h>
#import "NLGuestLoginService.h"

@interface NLLoginViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *googleButton;
@property (nonatomic, strong) UIButton *appleButton;
@property (nonatomic, strong) UILabel *registerHintLabel;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *guestLoginButton;

@end

@implementation NLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self setupConstraints];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];

    // 状态栏样式
    [self setNeedsStatusBarAppearanceUpdate];

    // Logo
    _logoImageView = [[UIImageView alloc] init];
    _logoImageView.image = [UIImage imageNamed:@"spotify"];
    _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_logoImageView];

    // 标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"登录到 Spotify";
    _titleLabel.font = [UIFont boldSystemFontOfSize:24];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];


    _phoneButton = [self createLoginButtonWithTitle:@"手机号登录"
                                     backgroundColor:[UIColor whiteColor]
                                           textColor:[UIColor blackColor]
                                                 icon:@"phone.fill"];
    [_phoneButton addTarget:self action:@selector(phoneLoginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_phoneButton];

    // 电子邮件按钮
    _emailButton = [self createLoginButtonWithTitle:@"使用电子邮件继续"
                                           backgroundColor:[UIColor systemGreenColor]
                                               textColor:[UIColor blackColor]
                                                     icon:nil];
    [_emailButton addTarget:self action:@selector(emailLoginTapped) forControlEvents:UIControlEventTouchUpInside];

    // Facebook按钮
    _facebookButton = [self createLoginButtonWithTitle:@"使用Facebook帐号继续"
                                          backgroundColor:[UIColor whiteColor]
                                               textColor:[UIColor blackColor]
                                                     icon:@"f.circle.fill"];
    [_facebookButton addTarget:self action:@selector(facebookLoginTapped) forControlEvents:UIControlEventTouchUpInside];

    // Google按钮
    _googleButton = [self createLoginButtonWithTitle:@"使用Google帐号继续"
                                        backgroundColor:[UIColor whiteColor]
                                             textColor:[UIColor blackColor]
                                                   icon:@"g.circle.fill"];
    [_googleButton addTarget:self action:@selector(googleLoginTapped) forControlEvents:UIControlEventTouchUpInside];

    // Apple按钮
    _appleButton = [self createLoginButtonWithTitle:@"使用Apple帐号继续"
                                       backgroundColor:[UIColor whiteColor]
                                            textColor:[UIColor blackColor]
                                                  icon:@"apple.logo"];
    [_appleButton addTarget:self action:@selector(appleLoginTapped) forControlEvents:UIControlEventTouchUpInside];

    // 注册提示
    _registerHintLabel = [[UILabel alloc] init];
    _registerHintLabel.text = @"尚未拥有帐号？";
    _registerHintLabel.font = [UIFont systemFontOfSize:14];
    _registerHintLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:_registerHintLabel];

    // 注册按钮
    _registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [_registerButton setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
    _registerButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [_registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerButton];

    _guestLoginButton = [self createLoginButtonWithTitle:@"游客登录"
                                         backgroundColor:[UIColor whiteColor]
                                               textColor:[UIColor blackColor]
                                                     icon:nil];
    [_guestLoginButton addTarget:self
                         action:@selector(guestLoginTapped)
               forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupConstraints {
    // Logo
    [_logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(120);
        make.width.height.mas_equalTo(80);
    }];

    // 标题
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logoImageView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];

    // 按钮容器
    UIView *buttonsContainer = [[UIView alloc] init];
    [self.view addSubview:buttonsContainer];

    [buttonsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(40);
        make.left.right.equalTo(self.view).inset(20);
    }];

    // 按钮
    NSArray *buttons = @[_emailButton,
                         _phoneButton,
                        _facebookButton,
                        _googleButton,
                        _appleButton,
                        _guestLoginButton];
    UIButton *previousButton = nil;

    for (UIButton *button in buttons) {
        [buttonsContainer addSubview:button];

        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(buttonsContainer);
            make.height.mas_equalTo(50);

            if (previousButton) {
                make.top.equalTo(previousButton.mas_bottom).offset(12);
            } else {
                make.top.equalTo(buttonsContainer);
            }
        }];

        previousButton = button;
    }

    [previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(buttonsContainer);
    }];

    // 注册提示
    [_registerHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
    }];

    // 注册按钮
    [_registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_registerHintLabel);
        make.left.equalTo(_registerHintLabel.mas_right).offset(4);
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

        // 调整标题位置
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    } else {
        // 没有图标，居中显示标题
        button.titleEdgeInsets = UIEdgeInsetsZero;
    }

    return button;
}

- (void)phoneLoginTapped {
    NSLog(@"手机号登录");
    NLPhoneLoginViewController *phoneLoginVC = [[NLPhoneLoginViewController alloc] init];
    [self.navigationController pushViewController:phoneLoginVC animated:YES];
}

#pragma mark - Button Actions

- (void)backButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    // TODO: 跳转到注册页面
}

- (void)guestLoginTapped {
    __weak typeof(self) weakSelf = self;
    [NLGuestLoginService anonymousLoginWithSuccess:^(NSDictionary *response) {
        [weakSelf loginSuccess];
    } failure:^(NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"游客登录失败"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [weakSelf presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)showLoginAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录"
                                                                   message:@"模拟登录成功！"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loginSuccess];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:loginAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loginSuccess {
    // 保存登录状态
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];

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

@end

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
