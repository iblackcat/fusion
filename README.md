# fusion

Real-Time Monocular 3d Reconstruction on iOS.

iOS上的实时单目三维重建

## Introduction

编译条件：xcode 9以上，iOS 11以上。

## Usage

* 打开APP，先扫描附近使ARKit初始化
* 对准要扫描的物体，点击'preview'按钮，会在相机前方位置出现扫描范围的红色立方块，可以重复放置
* 屏幕上下滑动可以调整红色立方块的大小
* 确定立方块位置后，点击'start'按钮，开始重建
* 缓慢移动相机位置，过一小段时间开始出现重建模型，受限于输入图像的分辨率，需要距离被扫物体尽量近拍摄
* 拍摄结束，点击'stop'按钮，停止重建，查看效果

## API


### ViewController

ViewController是整个项目的Controller

* `sceneView`: 屏幕右上角，ARKit的View，负责ARKit的生命周期以及每帧获取Image和Camera Pose
* `ImageView`: 屏幕左上角，彩色图像的View，负责显示每帧重建后投影得到的彩色图像
* `DepthView`: 屏幕左下角，深度图像的View，负责显示每帧重建后投影得到的深度图像
* `WeightView`: 屏幕右下角，权重图像的View，负责显示每帧重建后投影得到的权重图像
* `glView`: 用来管理OpenGL的context，没有实际显示出来
* `cubeNode`: SCNNode，用于显示重建范围的cube
* `cubePose`: 保存每一帧的cube对于相机的pose


### FusionBrain

FusionBrain是项目的最外层Model，负责调用各部分算法

```swift
func newFrame(image: UIImage, pose: CameraPose) -> (UIImage?, UIImage?, UIImage?)
```

重建时每一帧调用，完成fusion全部过程并返回投影得到的彩色、深度、权重图像

```swift
func FusionDone() -> (UIImage?, UIImage?, UIImage?)
```

重建后每一帧调用，展示模型

* `framePool`: 关键帧池，用于立体匹配前的关键帧选取
* `d_max`: 立体匹配参数，最大视差
* `rot_y`: 重建后展示模型时每次旋转的角度
* `Cube`: 单例，保存重建模型范围的Pose和Scale，以及模型八个顶点的局部坐标


### CameraPose

管理相机位姿的类


### FramePool

用于保存关键帧

```swift
func addFrame(newframe: Frame)
```

新加入一帧，如果超过最大帧数则覆盖最旧的一帧

```swift
func keyframeSelection(frame: Frame) -> Frame?
```

关键帧选择算法

* `MAX_FRAME_NUM`: 设置关键帧池的大小


### ImageRectification

图像矫正

```swift
static func getRectifiedPose(p1: CameraPose, p2: CameraPose) -> (p1_rec: CameraPose?, p2_rec: CameraPose?)
```

图像预矫正，关键帧选取算法调用

```swift
func imageRectification(frame1: Frame, frame2: Frame) -> (Frame?, Frame?, Float?)
```

图像矫正算法


### StereoMatching

立体匹配

```swift
init()
```

初始化，可以选择两种块匹配函数：`stereo_matching_ZNCC`,`stereo_matching_SSD`

```swift
func disparityEstimation(tex1: GLuint!, tex2: GLuint!) -> (GLuint?, GLuint?)
```

视差估计，输入矫正后的两张图像，输出两张图像对应的视差图，包括子像素精度优化

```swift
func depthEstimation(tex1: GLuint!, tex2: GLuint!, baseline: Float) -> GLuint?
```

深度估计，输入两张视差图，输出第一张的深度图，包括左右一致性检测


### TSDFModel

TSDF模型

```swift
func model_updating(tex_color: GLuint!, tex_depth: GLuint!, pose: CameraPose!)
```

模型更新模块，输入同一视角拍摄的彩色图像与计算的深度图像，以及视角的Camera Pose，进行模型更新。
由于TSDF模型中使用的坐标系与ARKit是相反的（ARKit的坐标系是手机Camera到起始位姿的变换，TSDF模型是起始位姿到当前手机Camera位姿的变换），
所以需要inverse一下。

```swift
func ray_tracing(pose: CameraPose!, tag: Bool = true)
```

模型投影模块，输入一个相机位姿，输出三张投影图

```swift
func swapModelTextures()
```

TSDF模型用fbo保存，模型更新时需要使用两个fbo做缓存，一个作为输入另一个作为输出，每次更新后需要交换一下


### GPU相关

每个图像用纹理来保存（包括TSDF模型），输出纹理时包含两个三角形的图元，图元的vbo和ebo内容都是固定的。
每个算法的GPU实现在/shader文件夹下的各个shader文件里，其中vertex shader是固定的。

#### myGLProgram

对GL program的封装，包括配置shader以及shader的编译等

#### myGLRTT

OpenGL Render To Texture

#### myGLRenderer

每个opengl程序相关联的program、rtt、各种buffer，以及与buffer之间交换数据

#### myGLKView 

创建OpenGL context，swift对OpenGL的各种设置
