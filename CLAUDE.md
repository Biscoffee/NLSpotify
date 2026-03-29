# CLAUDE.md - NLSpotify

## 项目概述

NLSpotify 是一个仿 Spotify 风格的 iOS 音乐流媒体应用，使用网易云音乐 API 作为后端数据源。支持在线播放、离线下载、歌词同步、歌单管理、搜索、评论等功能。

- **语言:** 100% Objective-C（WCDB 部分使用 .mm 文件做 C++ 桥接）
- **最低部署版本:** iOS 13.0+
- **架构模式:** MVC + ViewModel 混合架构
- **UI 方案:** 纯代码 UIKit + Masonry 布局（无 SwiftUI / 无 Storyboard）

## 项目结构

```
NLSpotify/
├── App/                                    # 应用生命周期
│   ├── AppDelegate                         # 应用委托
│   ├── SceneDelegate                       # 场景代理（iOS 13+ 多窗口）
│   ├── NLTabBarController                  # 主 TabBar（首页/音乐库/广播/搜索）
│   └── NLLoginViewController              # 登录页面
│
├── Modules/                                # 功能模块
│   ├── 主页面/                             # 首页推荐
│   │   ├── Controller/NLHomeViewController
│   │   ├── ViewModel/NLHomeViewModel, NLSectionViewModel
│   │   ├── Cell/NLHomeSectionCell, NLHomeSectionHeaderView, NLPlaylistCell, NLSingerAlbumCell
│   │   ├── Model/NLRecommendAlbumListModel, NLSingerAlbumListModel
│   │   └── 抽屉视图/NLDrawerViewController, NLDrawerView, NLDrawerModels
│   │
│   ├── 搜索页面/                           # 搜索与发现
│   │   ├── Controller/NLSearchViewController
│   │   ├── View/NLSearchResultView, NLSearchSuggestionView, NLSearchAdBannerView
│   │   ├── View/NLDiscoveryCardCell, NLCategoryCell
│   │   ├── Model/NLCategoryModel, NLDiscoveryCardModel
│   │   └── 该品类精选歌单/NLPlayListsViewController, NLPlaylistCollectionCell, NLPlayListModel
│   │
│   ├── 歌单详情页/                         # 歌单详情
│   │   ├── Controller/NLSongListViewController, NLAddToPlaylistSheetViewController
│   │   ├── View/NLSongListCell, NLSongListHeaderView
│   │   └── Model/NLListCellModel, NLHeaderModel
│   │
│   ├── 播放器/                             # 核心音频模块
│   │   ├── NLPlayerManager                 # 播放器单例（ReactiveObjC 信号驱动）
│   │   ├── 播放器页面/NLMusicPlayerViewController, NLMusicPlayerView
│   │   ├── 播放器页面/NLLyricLine, NLExpandableTouchSlider
│   │   ├── TabBar上方小播放器/NLMusicPlayerAccessoryViewController, NLMusicPlayerAccessoryView
│   │   ├── 缓存/NLCacheManager(.mm), NLResourceLoader  # AVAssetResourceLoader 断点续传
│   │   └── 下载管理/NLDownloadManager
│   │
│   ├── 评论区/                             # 评论功能
│   │   ├── NLCommentListViewController, NLCommentCell
│   │   ├── NLCommentModel
│   │   └── TextFoldHelper/NLCommentTextFolder
│   │
│   ├── 音乐库/                             # 本地音乐库
│   │   ├── 音乐库首页/NLMusicViewController, NLMusicLibraryListViewController
│   │   ├── 创建的歌单/NLUserPlayListDetailViewController, NLCreatePlayListSheetViewController
│   │   ├── 创建的歌单/NLLikedSongsPickerViewController
│   │   └── 播放历史/NLRecentPlayViewController
│   │
│   ├── Advertise/NLAdvertiseViewController # 广播模块
│   ├── Create/NLCreateViewController      # 歌单创建
│   │
│   └── WCDB/                               # 本地数据库层
│       ├── NLDataBaseManager(.mm)          # 数据库管理单例
│       ├── 上层仓库/                        # Repository 模式
│       │   ├── NLSongRepository(.mm)
│       │   ├── NLPlayListRepository(.mm)
│       │   ├── NLAlbumRepository(.mm)
│       │   ├── NLDownloadRepository(.mm)
│       │   └── NLSearchRepository(.mm)
│       └── ORM模型/                         # 数据库实体（三文件约定）
│           ├── 歌曲/NLSong, NLSong+WCDB, NLAudioCacheInfo, NLAudioCacheInfo+WCDB
│           ├── 歌单/NLPlayList, NLPlayList+WCDB, NLPlayListSongRelation, NLPlayListSongRelation+WCDB
│           ├── 专辑/NLAlbum, NLAlbum+WCDB
│           ├── 下载/NLDownloadItem, NLDownloadItem+WCDB
│           └── 搜索记录/NLSearchRecord, NLSearchRecord+WCDB
│
├── Networking/                             # 网络层
│   └── 网易云API/
│       ├── NetWorkManager                  # AFNetworking 封装
│       ├── Login && 双Token/               # 认证
│       │   ├── NLAuthManager               # Token 刷新管理（401/301 重试队列）
│       │   ├── NLAuthService               # Token 获取/刷新 API
│       │   └── NLGuestLoginService         # 游客登录
│       ├── 搜索/NLSearchSuggestService     # 搜索建议
│       ├── 歌单详情/NLPlaylistService, NLSongListService
│       ├── 评论/NLCommentService
│       ├── 音乐播放Url/NLSongService
│       ├── 专辑/NLAlbumService
│       ├── 为你推荐/NLRecommendAlbumListService, NLChineseSongListService
│       └── JJAlbum/NLSingerAlbumListService
│
├── Assets.xcassets/                        # 图片和颜色资源
└── Resources/                              # 应用截图等静态资源
```

## 核心依赖（CocoaPods）

| 库 | 用途 |
|---|---|
| AFNetworking | HTTP 网络请求 |
| YYModel | JSON ↔ Model 序列化 |
| Masonry | AutoLayout 约束 DSL |
| SDWebImage | 异步图片加载与缓存 |
| WCDB.objc | 本地 SQLite 数据库（腾讯 WCDB） |
| HysteriaPlayer | 音频播放引擎 |
| JXCategoryView | 分段控制器/标签页 |
| ReactiveObjC | 响应式编程（信号/流） |
| SocketRocket | WebSocket 通信 |
| IQKeyboardManager | 键盘自动管理 |
| LookinServer | UI 调试工具（仅 Debug） |

## 关键设计模式

- **单例模式:** NLPlayerManager、NLDataBaseManager、NetWorkManager、NLCacheManager、NLAuthManager
- **Service 层:** 每个 API 端点对应一个 Service 类（NLSongService、NLPlaylistService 等）
- **Repository 模式:** WCDB 仓库类封装数据库 CRUD（NLSongRepository、NLPlayListRepository 等）
- **响应式编程:** ReactiveObjC 用于播放状态信号传递（playbackStateSignal、songSignal、progressSignal）
- **双 Token 认证:** 检测 401/301 → 队列等待 → 刷新 Token → 重试请求，失败发送 NLForceLogoutNotification
- **WCDB ORM 三文件约定:** 每个实体由 `Model.h`（接口）+ `Model.mm`（WCDB_IMPLEMENTATION 绑定）+ `Model+WCDB.h`（ORM 宏声明）组成

## 构建与运行

```bash
# 安装依赖
pod install

# 使用 workspace 打开项目
open NLSpotify.xcworkspace
```

始终使用 `.xcworkspace` 而非 `.xcodeproj` 打开项目。

## 开发约定

- 中文命名用于模块目录（主页面、搜索页面、播放器等），类名使用 `NL` 前缀英文命名
- Model 类使用 YYModel 协议进行 JSON 映射
- WCDB ORM 模型在 `.mm` 文件中定义 `WCDB_IMPLEMENTATION` 绑定
- 网络请求通过 NetWorkManager 单例发起，Service 类封装具体接口
- UI 全部使用 Masonry 约束布局，不使用 Storyboard 进行界面构建
- 播放器相关状态通过 ReactiveObjC 信号驱动
- Tab 结构：首页 → 音乐库 → 广播 → 搜索（UISearchTab）
- 新增 WCDB 实体时遵循三文件约定：`.h` + `.mm` + `+WCDB.h`
- 新增 API 接口时在 `Networking/网易云API/` 下对应目录创建独立 Service 类

## API 配置

- **Base URL:** 网易云音乐 API 代理（腾讯云函数）
- **超时时间:** 20 秒
- **请求格式:** AFHTTPRequestSerializer
- **响应格式:** AFJSONResponseSerializer
- **后台音频:** Info.plist 中已启用 `audio` 后台模式

## 缓存架构

- **内存缓存:** SDWebImage 图片缓存
- **磁盘缓存:** 自定义 NLCacheManager（.mm），基于 AVAssetResourceLoader 实现流式缓存
- **缓存流程:** 播放时 .tmp 文件 → 完成后重命名为 .mp3 → WCDB 记录元数据（NLAudioCacheInfo）
- **LRU 清理:** 超出 maxSize 时自动清理最久未使用的缓存
- **下载管理:** NLDownloadManager 处理离线下载，NLDownloadRepository 持久化下载状态
