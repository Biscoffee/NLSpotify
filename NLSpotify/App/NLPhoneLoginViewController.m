//
//  NLPhoneLoginViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import "NLPhoneLoginViewController.h"
#import "NLPhoneLoginService.h"
#import "NLGuestLoginService.h"
#import "NLTabBarController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface NLPhoneLoginViewController () <UITextFieldDelegate>

// MARK: - UI Components
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

// Header
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISegmentedControl *loginTypeSegmentedControl;

// Phone Password Login
@property (nonatomic, strong) UIView *phonePasswordView;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) UIButton *loginButton;

// Captcha Login
@property (nonatomic, strong) UIView *captchaView;
@property (nonatomic, strong) UITextField *captchaPhoneTextField;
@property (nonatomic, strong) UIView *captchaInputContainer;
@property (nonatomic, strong) UITextField *captchaTextField;
@property (nonatomic, strong) UIButton *getCaptchaButton;
@property (nonatomic, strong) UIButton *captchaLoginButton;

// Footer
@property (nonatomic, strong) UILabel *termsLabel;
@property (nonatomic, strong) UIButton *termsButton;
@property (nonatomic, strong) UIButton *guestLoginButton;

// MARK: - Data
@property (nonatomic, assign) NSInteger countdownSeconds;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation NLPhoneLoginViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.backButton];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.loginTypeSegmentedControl];
    [self.contentView addSubview:self.phonePasswordView];
    [self.contentView addSubview:self.captchaView];
    [self.contentView addSubview:self.termsLabel];
    [self.contentView addSubview:self.termsButton];
    [self.contentView addSubview:self.guestLoginButton];
    [self.view addSubview:self.loadingIndicator];

    [self setupConstraints];
    [self setupGestures];
    [self switchToPasswordLogin:YES];
}

- (void)dealloc {
    [self stopCountdownTimer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault; // 随深色/浅色模式自适应
}

- (UITextField *)createTextFieldWithPlaceholder:(NSString *)placeholder isSecure:(BOOL)isSecure {
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.textColor = [UIColor labelColor];
    textField.font = [UIFont systemFontOfSize:16];
    textField.backgroundColor = [UIColor tertiarySystemFillColor];
    textField.layer.cornerRadius = 8;
    textField.clipsToBounds = YES;
    textField.delegate = self;
    textField.secureTextEntry = isSecure;

    // Add padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;

    if (isSecure) {
        UIButton *secureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [secureButton setImage:[UIImage systemImageNamed:@"eye"] forState:UIControlStateNormal];
        [secureButton setImage:[UIImage systemImageNamed:@"eye.slash"] forState:UIControlStateSelected];
        [secureButton setTintColor:[UIColor lightGrayColor]];
        secureButton.frame = CGRectMake(0, 0, 40, 40);
        [secureButton addTarget:self action:@selector(togglePasswordVisibility:) forControlEvents:UIControlEventTouchUpInside];

        textField.rightView = secureButton;
        textField.rightViewMode = UITextFieldViewModeAlways;
    }

    return textField;
}

#pragma mark - Constraints
- (void)setupConstraints {
    [self setupScrollViewConstraints];
    [self setupHeaderConstraints];
    [self setupLoginTypeConstraints];
    [self setupPhonePasswordViewConstraints];
    [self setupCaptchaViewConstraints];
    [self setupFooterConstraints];
    [self setupLoadingIndicatorConstraints];
}

- (void)setupScrollViewConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
}

- (void)setupHeaderConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.equalTo(self.contentView).offset(16);
        make.width.height.mas_equalTo(24);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(20);
        make.left.equalTo(self.contentView).offset(20);
    }];
}

- (void)setupLoginTypeConstraints {
    [self.loginTypeSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(30);
        make.left.right.equalTo(self.contentView).inset(20);
        make.height.mas_equalTo(40);
    }];
}

- (void)setupPhonePasswordViewConstraints {
    [self.phonePasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginTypeSegmentedControl.mas_bottom).offset(20);
        make.left.right.equalTo(self.contentView).inset(20);
    }];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phonePasswordView);
        make.left.right.equalTo(self.phonePasswordView);
        make.height.mas_equalTo(50);
    }];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneTextField.mas_bottom).offset(12);
        make.left.right.equalTo(self.phonePasswordView);
        make.height.mas_equalTo(50);
    }];
    [self.forgotPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(8);
        make.right.equalTo(self.phonePasswordView);
    }];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forgotPasswordButton.mas_bottom).offset(20);
        make.left.right.equalTo(self.phonePasswordView);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.phonePasswordView);
    }];
}

- (void)setupCaptchaViewConstraints {
    [self.captchaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginTypeSegmentedControl.mas_bottom).offset(20);
        make.left.right.equalTo(self.contentView).inset(20);
    }];
    [self.captchaPhoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.captchaView);
        make.left.right.equalTo(self.captchaView);
        make.height.mas_equalTo(50);
    }];
    [self.captchaInputContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.captchaPhoneTextField.mas_bottom).offset(12);
        make.left.right.equalTo(self.captchaView);
        make.height.mas_equalTo(50);
    }];
    [self.captchaTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.captchaInputContainer);
        make.right.equalTo(self.getCaptchaButton.mas_left).offset(-8);
    }];
    [self.getCaptchaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.captchaInputContainer);
        make.width.mas_equalTo(100);
    }];
    [self.captchaLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.captchaInputContainer.mas_bottom).offset(20);
        make.left.right.equalTo(self.captchaView);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.captchaView);
    }];
}

- (void)setupFooterConstraints {
    [self.termsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phonePasswordView.mas_bottom).offset(40);
        make.centerX.equalTo(self.contentView).offset(-40);
    }];
    [self.termsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.termsLabel);
        make.left.equalTo(self.termsLabel.mas_right).offset(2);
    }];
    [self.guestLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.termsLabel.mas_bottom).offset(16);
        make.centerX.equalTo(self.contentView);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.guestLoginButton.mas_bottom).offset(30);
    }];
}

- (void)setupLoadingIndicatorConstraints {
    [self.loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

#pragma mark - Gestures
- (void)setupGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Login Type Switching
- (void)loginTypeChanged:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self switchToPasswordLogin:YES];
    } else {
        [self switchToCaptchaLogin:YES];
    }
}

- (void)switchToPasswordLogin:(BOOL)animated {
    CGFloat duration = animated ? 0.3 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.phonePasswordView.alpha = 1;
        self.captchaView.alpha = 0;
    }];
}

- (void)switchToCaptchaLogin:(BOOL)animated {
    CGFloat duration = animated ? 0.3 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.phonePasswordView.alpha = 0;
        self.captchaView.alpha = 1;
    }];
}

#pragma mark - Button Actions
- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)forgotPasswordTapped {
    [self showAlertWithTitle:@"功能提示" message:@"忘记密码功能暂未开放"];
}

- (void)termsButtonTapped {
    [self showAlertWithTitle:@"用户协议" message:@"请查阅相关用户协议文档"];
}

- (void)togglePasswordVisibility:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.passwordTextField.secureTextEntry = !sender.selected;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Password Login
- (void)passwordLoginTapped {
    NSString *phone = self.phoneTextField.text;
    NSString *password = self.passwordTextField.text;

    if (![self validatePhone:phone]) return;
    if (![self validatePassword:password]) return;

    [self showLoading];

    __weak typeof(self) weakSelf = self;
    [NLPhoneLoginService loginWithPhone:phone password:password success:^(NSDictionary *response) {
        [weakSelf hideLoading];
        [weakSelf handleLoginSuccess:response];
    } failure:^(NSError *error) {
        [weakSelf hideLoading];
        [weakSelf handleLoginError:error];
    }];
}

#pragma mark - Captcha Login
- (void)getCaptchaTapped {
    NSString *phone = self.captchaPhoneTextField.text;

    if (![self validatePhone:phone]) return;

    [self startCountdown];

    __weak typeof(self) weakSelf = self;
    [NLPhoneLoginService sendCaptchaWithPhone:phone success:^(NSDictionary *response) {
        [weakSelf showAlertWithTitle:@"提示" message:@"验证码已发送"];
    } failure:^(NSError *error) {
        [weakSelf stopCountdownTimer];
        [weakSelf resetCaptchaButton];
        [weakSelf handleLoginError:error];
    }];
}

- (void)captchaLoginTapped {
    NSString *phone = self.captchaPhoneTextField.text;
    NSString *captcha = self.captchaTextField.text;

    if (![self validatePhone:phone]) return;
    if (![self validateCaptcha:captcha]) return;

    [self showLoading];

    __weak typeof(self) weakSelf = self;
    [NLPhoneLoginService loginWithPhone:phone captcha:captcha success:^(NSDictionary *response) {
        [weakSelf hideLoading];
        [weakSelf handleLoginSuccess:response];
    } failure:^(NSError *error) {
        [weakSelf hideLoading];
        [weakSelf handleLoginError:error];
    }];
}

#pragma mark - Guest Login
- (void)guestLoginTapped {
    [self showLoading];

    __weak typeof(self) weakSelf = self;
    [NLGuestLoginService anonymousLoginWithSuccess:^(NSDictionary *response) {
        [weakSelf hideLoading];
        [weakSelf handleGuestLoginSuccess:response];
    } failure:^(NSError *error) {
        [weakSelf hideLoading];
        [weakSelf handleLoginError:error];
    }];
}

- (void)handleGuestLoginSuccess:(NSDictionary *)response {
    NSLog(@"游客登录成功: %@", response);

    // 保存游客登录信息
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGuest"];
    [[NSUserDefaults standardUserDefaults] setObject:response[@"account"] forKey:@"userAccount"];
    [[NSUserDefaults standardUserDefaults] setObject:response[@"profile"] forKey:@"userProfile"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self switchToMainPage];
}

#pragma mark - Login Handling
- (void)handleLoginSuccess:(NSDictionary *)response {
    NSLog(@"登录成功: %@", response);

    // 保存用户信息
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isGuest"];
    [[NSUserDefaults standardUserDefaults] setObject:response[@"account"] forKey:@"userAccount"];
    [[NSUserDefaults standardUserDefaults] setObject:response[@"profile"] forKey:@"userProfile"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self switchToMainPage];
}

- (void)handleLoginError:(NSError *)error {
    NSString *errorMessage = [self getErrorMessageFromError:error];
    [self showAlertWithTitle:@"登录失败" message:errorMessage];
}

- (void)switchToMainPage {
    NLTabBarController *tabBarController = [[NLTabBarController alloc] init];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;

    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [window.layer addAnimation:transition forKey:kCATransition];
    window.rootViewController = tabBarController;
}

#pragma mark - Countdown Timer
- (void)startCountdown {
    self.countdownSeconds = 60;
    self.getCaptchaButton.enabled = NO;
    [self updateCaptchaButtonTitle];

    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateCountdown)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)updateCountdown {
    self.countdownSeconds--;

    if (self.countdownSeconds <= 0) {
        [self stopCountdownTimer];
        [self resetCaptchaButton];
    } else {
        [self updateCaptchaButtonTitle];
    }
}

- (void)updateCaptchaButtonTitle {
    NSString *title = [NSString stringWithFormat:@"%zds后重发", self.countdownSeconds];
    [self.getCaptchaButton setTitle:title forState:UIControlStateNormal];
}

- (void)resetCaptchaButton {
    self.getCaptchaButton.enabled = YES;
    [self.getCaptchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
}

- (void)stopCountdownTimer {
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
}

#pragma mark - Validation
- (BOOL)validatePhone:(NSString *)phone {
    if (phone.length == 0) {
        [self showAlertWithTitle:@"提示" message:@"请输入手机号"];
        return NO;
    }

    if (![self isValidPhoneNumber:phone]) {
        [self showAlertWithTitle:@"提示" message:@"请输入正确的手机号"];
        return NO;
    }

    return YES;
}

- (BOOL)validatePassword:(NSString *)password {
    if (password.length == 0) {
        [self showAlertWithTitle:@"提示" message:@"请输入密码"];
        return NO;
    }

    if (password.length < 6) {
        [self showAlertWithTitle:@"提示" message:@"密码长度至少6位"];
        return NO;
    }

    return YES;
}

- (BOOL)validateCaptcha:(NSString *)captcha {
    if (captcha.length == 0) {
        [self showAlertWithTitle:@"提示" message:@"请输入验证码"];
        return NO;
    }

    if (captcha.length != 6) {
        [self showAlertWithTitle:@"提示" message:@"验证码应为6位数字"];
        return NO;
    }

    return YES;
}

- (BOOL)isValidPhoneNumber:(NSString *)phone {
    NSString *phoneRegex = @"^1[3-9]\\d{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

#pragma mark - UI Helpers
- (void)showLoading {
    [self.loadingIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
}

- (void)hideLoading {
    [self.loadingIndicator stopAnimating];
    self.view.userInteractionEnabled = YES;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)getErrorMessageFromError:(NSError *)error {
    if ([error.domain isEqualToString:@"NLPhoneLoginService"]) {
        return error.localizedDescription;
    } else {
        return @"网络连接失败，请检查网络后重试";
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.phoneTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
        [self passwordLoginTapped];
    }
    return YES;
}

#pragma mark - Getters

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
        [_backButton setTintColor:[UIColor labelColor]];
        [_backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"手机号登录";
        _titleLabel.font = [UIFont boldSystemFontOfSize:24];
        _titleLabel.textColor = [UIColor labelColor];
    }
    return _titleLabel;
}

- (UISegmentedControl *)loginTypeSegmentedControl {
    if (!_loginTypeSegmentedControl) {
        _loginTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"密码登录", @"验证码登录"]];
        _loginTypeSegmentedControl.selectedSegmentIndex = 0;
        _loginTypeSegmentedControl.tintColor = [UIColor systemGreenColor];
        [_loginTypeSegmentedControl addTarget:self action:@selector(loginTypeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _loginTypeSegmentedControl;
}

- (UIView *)phonePasswordView {
    if (!_phonePasswordView) {
        _phonePasswordView = [[UIView alloc] init];
        _phoneTextField = [self createTextFieldWithPlaceholder:@"手机号" isSecure:NO];
        _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
        _phoneTextField.returnKeyType = UIReturnKeyNext;
        [_phonePasswordView addSubview:_phoneTextField];

        _passwordTextField = [self createTextFieldWithPlaceholder:@"密码" isSecure:YES];
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        [_phonePasswordView addSubview:_passwordTextField];

        _forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_forgotPasswordButton setTitle:@"忘记密码？" forState:UIControlStateNormal];
        [_forgotPasswordButton setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
        _forgotPasswordButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordTapped) forControlEvents:UIControlEventTouchUpInside];
        [_phonePasswordView addSubview:_forgotPasswordButton];

        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.backgroundColor = [UIColor systemGreenColor];
        _loginButton.layer.cornerRadius = 25;
        _loginButton.clipsToBounds = YES;
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_loginButton addTarget:self action:@selector(passwordLoginTapped) forControlEvents:UIControlEventTouchUpInside];
        [_phonePasswordView addSubview:_loginButton];
    }
    return _phonePasswordView;
}

- (UIView *)captchaView {
    if (!_captchaView) {
        _captchaView = [[UIView alloc] init];
        _captchaView.alpha = 0;

        _captchaPhoneTextField = [self createTextFieldWithPlaceholder:@"手机号" isSecure:NO];
        _captchaPhoneTextField.keyboardType = UIKeyboardTypePhonePad;
        [_captchaView addSubview:_captchaPhoneTextField];

        _captchaInputContainer = [[UIView alloc] init];
        [_captchaView addSubview:_captchaInputContainer];

        _captchaTextField = [self createTextFieldWithPlaceholder:@"验证码" isSecure:NO];
        _captchaTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_captchaInputContainer addSubview:_captchaTextField];

        _getCaptchaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _getCaptchaButton.backgroundColor = [UIColor clearColor];
        _getCaptchaButton.layer.cornerRadius = 4;
        _getCaptchaButton.layer.borderWidth = 1;
        _getCaptchaButton.layer.borderColor = [UIColor systemGreenColor].CGColor;
        [_getCaptchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getCaptchaButton setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
        _getCaptchaButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_getCaptchaButton addTarget:self action:@selector(getCaptchaTapped) forControlEvents:UIControlEventTouchUpInside];
        [_captchaInputContainer addSubview:_getCaptchaButton];

        _captchaLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _captchaLoginButton.backgroundColor = [UIColor systemGreenColor];
        _captchaLoginButton.layer.cornerRadius = 25;
        _captchaLoginButton.clipsToBounds = YES;
        [_captchaLoginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_captchaLoginButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
        _captchaLoginButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_captchaLoginButton addTarget:self action:@selector(captchaLoginTapped) forControlEvents:UIControlEventTouchUpInside];
        [_captchaView addSubview:_captchaLoginButton];
    }
    return _captchaView;
}

- (UILabel *)termsLabel {
    if (!_termsLabel) {
        _termsLabel = [[UILabel alloc] init];
        _termsLabel.text = @"登录即表示您同意";
        _termsLabel.font = [UIFont systemFontOfSize:12];
        _termsLabel.textColor = [UIColor tertiaryLabelColor];
    }
    return _termsLabel;
}

- (UIButton *)termsButton {
    if (!_termsButton) {
        _termsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_termsButton setTitle:@"《用户协议》" forState:UIControlStateNormal];
        [_termsButton setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
        _termsButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_termsButton addTarget:self action:@selector(termsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _termsButton;
}

- (UIButton *)guestLoginButton {
    if (!_guestLoginButton) {
        _guestLoginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_guestLoginButton setTitle:@"游客登录" forState:UIControlStateNormal];
        [_guestLoginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _guestLoginButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_guestLoginButton addTarget:self action:@selector(guestLoginTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _guestLoginButton;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingIndicator.hidesWhenStopped = YES;
        _loadingIndicator.color = [UIColor systemGreenColor];
    }
    return _loadingIndicator;
}

@end
