# NLSpotify

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://developer.apple.com/ios/)
[![Language](https://img.shields.io/badge/language-Objective--C-orange.svg)](https://developer.apple.com/documentation/objectivec)

`NLSpotify` 是一款功能丰富的 iOS 音乐流媒体应用，其设计灵感来源于 Spotify，并由网易云音乐 API 提供强大的音乐内容支持。本项目旨在提供一个流畅、美观且功能完整的音乐收听体验。

## ✨ 功能特性

*   **发现音乐**: 浏览个性化推荐、新歌速递和热门歌单。
*   **强大搜索**: 快速准确地搜索歌曲、歌手和专辑。
*   **高清播放与歌词同步**: 支持高品质音乐播放，并提供逐行精准同步的歌词显示。
*   **智能缓存与预加载**: 高效的二级缓存（内存+磁盘）与智能预加载机制，实现无缝播放切换，优化加载速度。
*   **离线收听**: 支持歌曲下载，随时随地享受音乐，无需网络连接。
*   **WCDB 本地化存储**: 基于 WCDB 实现高效的本地数据持久化，包括歌曲、歌单和用户偏好设置。
*   **动态评论区**: 评论区支持自适应高度和动态展开/折叠，提升浏览体验。
*   **安全的双 Token 认证**: 采用双 Token 机制确保用户会话安全与持久。
*   **歌单管理**: 创建和管理您的私人歌单，收藏您喜爱的音乐。

## 🛠️ 技术栈

`NLSpotify` 采用现代化的 Objective-C 开发，并整合了多个业界领先的第三方库来提升开发效率和应用性能。

*   **核心框架**: UIKit, Foundation
*   **网络请求**: [AFNetworking](https://github.com/AFNetworking/AFNetworking) - 一个强大而优雅的 iOS 和 macOS 网络库。
*   **响应式编程**: [ReactiveObjC](https://github.com/ReactiveCocoa/ReactiveObjC) - 用于处理异步和事件驱动的编程。
*   **UI 布局**: [Masonry](https://github.com/SnapKit/Masonry) - 一个轻量级的自动布局 DSL，使自动布局代码更简洁。
*   **图片加载**: [SDWebImage](https://github.com/SDWebImage/SDWebImage) - 强大的异步图片下载和缓存库。
*   **数据库**: [WCDB.objc](https://github.com/Tencent/wcdb) - 腾讯开源的高效、完整、易用的移动数据库框架。
*   **音频播放**: [HysteriaPlayer](https://github.com/hust201010701/HysteriaPlayer) - 一个功能强大的 iOS 音频播放器。
*   **UI 组件**: [JXCategoryView](https://github.com/pujiaxin33/JXCategoryView) - 功能强大、易于使用的分类视图/SegmentedControl。
*   **数据模型**: [YYModel](https://github.com/ibireme/YYModel) - 高性能的 iOS/macOS JSON 模型转换框架。
*   **键盘管理**: [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) - 无代码、无需设置的智能键盘管理库。

## 🚀 安装与部署

请确保您已安装最新版本的 Xcode 和 CocoaPods。

1.  **克隆仓库**
    ```bash
    git clone https://github.com/your-username/NLSpotify.git
    cd NLSpotify
    ```

2.  **安装依赖**
    使用 CocoaPods 安装项目所需的所有第三方库。
    ```bash
    pod install
    ```

3.  **打开项目**
    使用 Xcode 打开新生成的 `.xcworkspace` 文件。
    ```bash
    open NLSpotify.xcworkspace
    ```

4.  **编译和运行**
    在 Xcode 中选择您的目标设备或模拟器，然后点击 `Run` (Cmd+R) 按钮。

## 📖 使用教程

应用启动后，您可以：
1.  在 **主页** 浏览推荐的歌单和专辑。
2.  切换到 **搜索** 标签页，输入关键词查找您喜欢的歌曲。
3.  点击任何歌曲进行播放，播放器将在底部显示。点击播放器可进入全屏播放界面查看歌词。
4.  在歌曲或歌单详情页，您可以下载歌曲、添加到您的音乐库或查看评论。
5.  在 **音乐库** 标签页，您可以找到您收藏和下载的所有音乐。

## 🔌 API 文档

本项目的所有音乐数据均来源于 [网易云音乐 API](https://binaryify.github.io/NeteaseCloudMusicApi/)。网络请求的封装逻辑位于 `NLSpotify/Networking/` 目录下，您可以根据需要进行扩展和修改。

核心服务包括：
*   `NLAlbumService`: 获取专辑内容。
*   `NLPlaylistService`: 获取歌单详情。
*   `NLSongService`: 获取歌曲 URL 和详情。
*   `NLCommentService`: 获取评论数据。

## 🤝 贡献指南

我们欢迎任何形式的贡献，无论是报告 bug、提交新功能还是改进现有代码。

1.  Fork 本仓库。
2.  创建您的功能分支 (`git checkout -b feature/AmazingFeature`)。
3.  提交您的更改 (`git commit -m 'Add some AmazingFeature'`)。
4.  推送到分支 (`git push origin feature/AmazingFeature`)。
5.  提交一个 Pull Request。

## 📄 许可证

本项目采用 [MIT License](LICENSE) 许可证。请在您的项目根目录中添加一个 `LICENSE` 文件，并将 MIT 许可证文本粘贴进去。