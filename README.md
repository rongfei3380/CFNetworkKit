# CFNetworkKit
网络相关的库，以AFNetworkKit 为基础。

# 引用时注意
因为 spec.dependency 'CFFoundation' ，依赖了私有库。 因此，项目需要此库时。需要在主项目的Podfile文件中添加 source。

source 'https://github.com/rongfei3380/Specs.git'