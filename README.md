## Admaster iOS SDK 部署指南

### 步骤1：添加 Admaster iOS SDK 到工程中

1. 将SDK发布文件中，release目录下的**MobileTracking.h** 、**libMobileTracking.a**、**sdkconfig.xml** 三个文件拷贝到项目工程中，将 **sdkconfig.xml** 上传到 web 服务器，使其可以通过 web 方式访问，假设其地址为 **http://xxxxxx.com/sdkconfig.xml**（其后会用到）。
2. 在项目工程 App 的 Target Build Settings 中的 **Other Linker Flags** 选项里添加 **-lxml2** **-all_load** 或 **-lxml2** **-force_load** 静态库的绝对路径

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

普通广告监测

```
[[MobileTracking sharedInstance] view:@"http://vxyz.admaster.com.cn/v/a17298,b81949763,c3194,i0,m201”];

```
可见性广告监测

```
[[MobileTracking sharedInstance] view:@"http://vxyz.admaster.com.cn/v/a17298,b81949763,c3194,i0,m201” ad:adview];

```

视频可见性广告监测

```
[[MobileTracking sharedInstance] viewVideo:@"http://vxyz.admaster.com.cn/v/a17298,b81949763,c3194,i0,m201” ad:adview];

```
可见性广告JS监测

```
[[MobileTracking sharedInstance] jsView:@"http://vxyz.admaster.com.cn/v/a17298,b81949763,c3194,i0,m201” ad:adview];

```

视频可见性广告JS监测

```
[[MobileTracking sharedInstance] jsViewVideo:@"http://vxyz.admaster.com.cn/v/a17298,b81949763,c3194,i0,m201” ad:adview];

```

#### 4、点击监测
通过调用以下的代码进行点击的监测，参数为第三方公司的监测地址

```
[[MobileTracking sharedInstance] click:@"http://vxyz.admaster.com.cn/v/a17298,b81949763,c3194,i0,m201"];
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

针对第一点，使用 Admaster SDK 测试平台进行测试和验证，登入 http://developer.admaster.com.cn/, 根据页面上的提示进行调用， 页面会实时显示出服务器接收到的信息，如果和本地的设备相关信息一致，则表示测试通过。

针对第二点，建议使用第三方监测系统的正式环境进行测试，主要对比媒体自身广告系统监测数据和第三方监测数据数量上的差异。


