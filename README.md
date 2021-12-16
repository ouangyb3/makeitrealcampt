## MMA iOS SDK 部署指南

### 步骤1：添加 MMA iOS SDK 到工程中

1. 将SDK发布文件中，release目录下的**MobileTracking.h** 、**libMobileTracking.a**、**sdkconfig.xml** 三个文件拷贝到项目工程中，将 **sdkconfig.xml** 上传到 web 服务器，使其可以通过 web 方式访问，假设其地址为 **http://xxxxxx.com/sdkconfig.xml**（其后会用到）。
2. 在项目工程 App 的 Target Build Settings 中的 **Other Linker Flags** 选项里添加 **-lxml2** **-all_load** 或 **-lxml2** **-force_load** 静态库的绝对路径
3. 添加SDK需要的Framework
在需要添加SDK的项目的 Xcode 开发环境中选择 TARGETS-->Build Phases-->Link Binary With Libraries--> + 添加以下framework框架:
```
    CoreLocation.framework
    libxml2.2.tbd
	 AdSupport.framework
	 CoreTelephony.framework
	 SystemConfiguration.framework
	 
```


### 步骤2:配置文件sdkconfig.xml的使用方法
在使用的文件中引用 **#import "MobileTracking.h"**.

使用说明:

#### 1、初始化方法

在进行监测之前，必须进行初始化，通过以上的代码进行初始化操作

```
[MobileTracking sharedInstance]

```

#### 2、配置远程配置文件地址方法

SDK 会自动下载远程的配置文件，使用最新的配置文件进行参数的组装。

```
[[MobileTracking sharedInstance] configFromUrl:@“http://xxxxxx.com/sdkconfig.xml”];
```

#### 3、曝光的监测

通过调用以下的代码进行曝光的监测，

 * 第一个参数为第三方公司的监测地址
 * 第二个参数为当前广告视图对象（**可视化广告监测为必传字段，普通广告监测默认缺省。**）
 * 第三个参数为当前视频广告的播放类型（**视频可视化广告监测为可选字段，1-自动播放，2-手动播放，0-无法识别。**）

普通广告监测

```
[[MobileTracking sharedInstance] view:@"http://example.com/xxxxxx”];

```
可见性广告监测

```
[[MobileTracking sharedInstance] view:@"http://example.com/xxxxxx” ad:adview];

```

视频可见性广告监测

```
[[MobileTracking sharedInstance] viewVideo:@"http://example.com/xxxxxx” ad:adview];

```
```
[[MobileTracking sharedInstance] viewVideo:@"http://example.com/xxxxxx” ad:adview videoPlayType:type];

```
可见性广告JS监测

```
[[MobileTracking sharedInstance] jsView:@"http://example.com/xxxxxx” ad:adview];

```

视频可见性广告JS监测

```
[[MobileTracking sharedInstance] jsViewVideo:@"http://example.com/xxxxxx” ad:adview];

```
可见性广告监测停止，广告播放结束时调用

```
[[MobileTracking sharedInstance] stop:@"http://example.com/xxxxxx”];

```

#### 4、点击监测
通过调用以下的代码进行点击的监测，参数为第三方公司的监测地址

```
[[MobileTracking sharedInstance] click:@"http://example.com/xxxxxx"];
```

#### 5、进入后台时调用
主要用于保存当前监测数据，不被丢失。建议放在AppDelegate的applicationDidEnterBackground方法中

```
[[MobileTracking sharedInstance] didEnterBackground];
```


#### 6、回到前台时调用
重新读取缓存数据，主要用于保证当前监测数据，及时上报,建议放在AppDelegate的applicationWillEnterForeground方法中

```
[[MobileTracking sharedInstance] didEnterForeground];
```


#### 7、应用结束时调用
主要用于保存当前监测数据，不被丢失。

```
[[MobileTracking sharedInstance] willTerminate];
```

#### 7、开启调试日志
建议在测试时候打开

```
[[MobileTracking sharedInstance] enableLog:YES];
```

### 步骤3：验证和调试

SDK 的测试有两个方面：

1. 参数是否齐全，URL 拼接方式是否正确
2. 请求次数和第三方监测平台是否能对应上

请联系第三方监测平台完成测试

