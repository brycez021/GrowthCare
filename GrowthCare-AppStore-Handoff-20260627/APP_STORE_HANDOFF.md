# GrowthCare Apple Store Handoff

交接日期：2026-07-03

## 工程位置

请打开：

`ios/GrowthCare/GrowthCare.xcodeproj`

推荐使用 Xcode 17 或更新版本。当前工程最低 iOS 版本为 `iOS 16.0`，Bundle Identifier 为 `com.growthcare.app`。

## 上传前需要伙伴配置

1. 在 Xcode 中选择 `GrowthCare` target。
2. 打开 `Signing & Capabilities`。
3. 选择自己的 Apple Developer Team。
4. 确认 Bundle Identifier 是否要继续使用 `com.growthcare.app`，如需换成团队自己的域名，在这里修改。
5. 连接 App Store Connect 后执行 `Product > Archive`，再通过 Organizer 上传。

## 当前初始数据规则

- 新用户首次打开只有一个默认孩子：`孩子1`。
- 默认生日为首次打开当天。
- 默认没有预约记录、已接种记录、成长记录。
- 用户需要自己修改孩子姓名和出生日期，或继续添加孩子。
- 如果修改孩子出生日期后存在已过推荐月龄的针次，App 会在预约首页弹出确认已接种疫苗的勾选弹窗。

## 本轮交付前更新

- App 状态已改为本地文件保存：预约记录、孩子信息、成长记录、提醒设置、家长信息等退出重进后会保留。
- AppIcon 已使用 `软件LOGO` 生成正式 iOS 图标，当前图标为 `1024 x 1024`、无透明通道 PNG。
- 主页面宽度适配已补强：预约首页、预约确认弹窗、疫苗卡片、接种时间表和成长曲线按真实屏幕宽度收缩，避免 TestFlight 真机宽度溢出。
- 诊所相关可见功能已从当前上架范围移除：预约流程不再选择接种门诊，修改计划不再显示接种门诊，我的页不再显示诊所分区。
- 共享功能已从我的页移除。
- 我的页入口文案已改为“修改家长信息”，家长头像可通过系统照片选择器更换。
- 家长信息页底部已加入隐私说明：`App不收集任何用户个人数据，所有数据仅存储在本地设备`。
- 疫苗数据已按接种时间表重分组：彩色块对应规划免费疫苗并默认显示在首页，白色块/非规划疫苗进入“添加预约疫苗”列表。

## 已验证项目

- Swift 源码构建通过。
- 资源目录参与构建通过。
- AppIcon `1024 x 1024` 已处理为无透明通道 PNG，满足 App Store 图标要求。
- 本地通知提醒已接入，首次使用时会请求系统通知权限。

## 构建验证命令

已在本机运行并通过：

```sh
xcodebuild -project GrowthCare.xcodeproj \
  -scheme GrowthCare \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ../../work/AppStoreHandoffDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

说明：这里关闭签名只是为了代码和资源验证。正式上架必须由伙伴使用自己的 Apple Developer Team 重新签名并 Archive。

## 交付包内容

- `ios/`：完整 Xcode 工程与源码、资源。
- `docs/`：实现与转写说明。
- `AppIconSource/`：原始 `软件LOGO` 图标源文件备份。
- `README.md`、`AGENTS.md`、`contributing_ai.md`：项目说明与协作记录。
- `APP_STORE_HANDOFF.md`：本文件。

未包含：

- `work/` 构建产物。
- `reference/` HTML 原型。
- DerivedData。
