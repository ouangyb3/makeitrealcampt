CONFIGURATION="Release"
PROJECT_NAME="libMobileTrackingDevice.a"  # 版本库名称
UNIVERSAL_OUTPUTFOLDER=$(pwd)/build # 通用版本库存放目录
targetName="MobileTrackingDevice"

#通用连接 release 连接 sim连接
universal_path=${UNIVERSAL_OUTPUTFOLDER}/${CONFIGURATION}-universal
iphoneos_path=${UNIVERSAL_OUTPUTFOLDER}/${CONFIGURATION}-iphoneos
iphonesimulator_path=${UNIVERSAL_OUTPUTFOLDER}/${CONFIGURATION}-iphonesimulator


${$targetName:?"mush set targetName"}
xcodebuild -target $targetName clean     # clean project
xcodebuild -target $targetName -sdk iphoneos12.2 # build iphoneos

#build iphonesimulator
xcodebuild -target $targetName -configuration ${CONFIGURATION} -sdk iphonesimulator12.2  -arch x86_64 -arch i386

if [ ! -d "$universal_path" ]; then   #判断文件是否存在 不存在创建 中括号两边要空格
mkdir "$universal_path"
fi

echo
# 合并版本库
lipo -create -output "${universal_path}/${PROJECT_NAME}" "${iphoneos_path}/${PROJECT_NAME}" "${iphonesimulator_path}/${PROJECT_NAME}"

cp -R "${iphoneos_path}/include" "$universal_path/"
# open $universal_path
echo 'build complete'
