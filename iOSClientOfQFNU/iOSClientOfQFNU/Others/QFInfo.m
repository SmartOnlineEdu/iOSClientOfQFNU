//
//  QFInfo.m
//  iOSClientOfQFNU
//
//  Created by lyngame on 2017/6/28.
//  Copyright © 2017年 iOSClientOfQFNU. All rights reserved.
//

#import "QFInfo.h"
#import "TFHpple.h"
#import "AFNetworking.h"
#import "BaseRequest.h"
@implementation QFInfo
@synthesize Username;
@synthesize password;
@synthesize token;

;
/**
 单例方法
 可以调用全程，整个程序生命周期调用一个QFInfo的任何东西
 */
+ (QFInfo *)sharedInstance
{
    static QFInfo *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}
//保存用户名密码
- (void)save:(NSString *)user password:(NSString *)passWord token:(NSDictionary *)Token{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setObject:Token forKey:@"token"];
    [ud setObject:user forKey:@"username"];
    [ud setObject:passWord forKey:@"password"];
    [ud synchronize];
}
//调用用户名，没有就是空
-(NSString *)getUser{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *us=@"";
    if([ud objectForKey:@"username"]){
        us=[ud objectForKey:@"username"];
    }
    return us;
}
//调用密码，没有就是空
-(NSString *)getPassword{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *ps=@"";
    if([ud objectForKey:@"password"]){
        ps=[ud objectForKey:@"password"];
    }
    return ps;
}
-(NSDictionary *)getToken{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *tk=nil;
    if([ud objectForKey:@"token"]){
        tk=[ud objectForKey:@"token"];
    }
    return tk;
}
-(void)loginqfnu:(NSString *)username password:(NSString *)password{
    NSLog(@"登录的账号是：%@",username);
    NSString *Lt=[[NSString alloc]init];
    NSString *urlstring=@"http://ids.qfnu.edu.cn/authserver/login?service=http%3A%2F%2F202.194.188.19%2Fcaslogin.jsp";
    NSData *htmlData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:urlstring]];
    TFHpple *xpathParser=[[TFHpple alloc]initWithXMLData:htmlData];
    NSArray *dataArray=[xpathParser searchWithXPathQuery:@"//input"];
    for (TFHppleElement *hppleElement in dataArray){
        if ([[hppleElement objectForKey:@"name"] isEqualToString:@"lt"]) {
            NSLog(@"%@",[hppleElement objectForKey:@"value"]);
            Lt=[[NSString alloc]init];
            Lt=[hppleElement objectForKey:@"value"];
        }
        
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//响应
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSHTTPCookie *cookie = [[cookieJar cookiesForURL:[NSURL URLWithString:@"http://ids.qfnu.edu.cn/authserver/login"]]firstObject];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]] forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setHTTPShouldHandleCookies:YES];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    NSString *domainStr = @"http://ids.qfnu.edu.cn/authserver/login?service=http%3A%2F%2Fmy.qfnu.edu.cn%2Flogin.portal";
    [BaseRequest postLoginWithURL:domainStr lt:Lt user:username password:password callBack:^(NSData *data, NSError *error) {
        [self SaveCookie];
        NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"true:%@",str);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"link_success" object:nil];
        
    }];
}
//获取课程
-(NSDictionary *)getCourse{
    NSUserDefaults *gcou = [NSUserDefaults standardUserDefaults];
    NSDictionary *cou;
    if([gcou objectForKey:@"course"]){
        cou=[gcou objectForKey:@"course"];
    }
    return cou;
    
}
//保存课程
-(void)savaCourse:(NSDictionary *)course{
    NSLog(@"====================保存课程====================");
    NSUserDefaults *cou = [NSUserDefaults standardUserDefaults];
    
    [cou setObject:course forKey:@"course"];
    [cou synchronize];
}

//获取考勤人员
-(NSString *)getclassUser{
    NSUserDefaults *gcu = [NSUserDefaults standardUserDefaults];
    NSString *cu;
    if([gcu objectForKey:@"classUser"]){
        cu=[gcu objectForKey:@"classUser"];
    }
    return cu;
    
}
//保存考勤人员
-(void)classUser:(NSDictionary *)classUser{
    NSLog(@"====================保存考勤人员====================");
    NSUserDefaults *cu = [NSUserDefaults standardUserDefaults];
    [cu setObject:classUser forKey:@"course"];
    [cu synchronize];
}
-(void)SaveCookie
{
    NSLog(@"====================保存cookie====================");
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *tempCookie in cookies) {
        //打印获得的cookie
        NSLog(@"getCookie: %@", tempCookie);
    }
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    //存储归档后的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject: cookiesData forKey: @"cookie"];
}
- (void)setCoookie
{
    NSLog(@"============再取出保存的cookie重新设置cookie===============");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"cookie"]];
    if (cookies) {
        NSLog(@"有cookie");
        //设置cookie
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (id cookie in cookies) {
            [cookieStorage setCookie:(NSHTTPCookie *)cookie];
        }
    }else{
        NSLog(@"无cookie");
    }
    //打印cookie，检测是否成功设置了cookie
    NSArray *cookiesA = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookiesA) {
        NSLog(@"setCookie: %@", cookie);
    }
    NSLog(@"\n");
}
@end
