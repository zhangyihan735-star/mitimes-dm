# 秘Times DM 人物展示工具

这是一个已发布到 GitHub Pages 的 DM 展示网站，入口文件为 `index.html`。前台保留原有电影感 UI 与浏览交互，数据层已预留 Supabase 连接和管理员后台。

线上地址：<https://zhangyihan735-star.github.io/mitimes-dm/>

## 已实现

- 首页 DM 随机推荐
- DM 列表与无限式浏览卡片
- 昵称搜索
- 性别 / 剧本类型筛选
- 搜索与筛选互斥
- DM 详情人物名片
- 指定 DM 提示弹窗
- 分享名片提示
- 手机端响应式布局

## 部署

GitHub Pages 当前从 `main` 分支的根目录发布，不需要构建命令和输出目录。后续只要向 `main` 推送新版本，GitHub Pages 会自动重新构建。

如果未来改用 Vercel，仍可以使用 CLI：

```bash
npx vercel --prod
```

## Supabase 配置

1. 在 Supabase 创建项目。
2. 打开 SQL Editor，执行 `supabase/schema.sql`。
3. 在 Authentication > Users 中手动创建一个 Email/Password 管理员账号，并关闭公开注册。
4. 复制 `supabase-config.example.js` 为 `supabase-config.js`，填写 Project URL 和 anon key。
5. 将 `supabase-config.js` 一并提交到 GitHub，再等待 GitHub Pages 自动更新。

anon key 可以出现在前端，真正的安全边界是数据库 RLS；不要把 `service_role` key 放进网站。

## 后台使用

管理员入口：<https://zhangyihan735-star.github.io/mitimes-dm/admin>

登录后可以查看 DM 总人数、上架数量、隐藏数量，并新增、编辑、删除、上架、下架和隐藏 DM。新增或编辑时可以上传照片，标签用中文逗号分隔，剧本类型支持多选，作品每行填写一部。

后台保存后，前台会通过 Supabase 查询和 Realtime 订阅读取最新资料；如果没有配置 Supabase，网站会自动使用 `data/dms.seed.json` 作为演示数据，后台会提示完成配置。

## 数据库结构（V1）

V1 使用一张 `dm_profiles` 表，标签、剧本类型和代表作品以数组字段保存，减少后台复杂度。完整字段和 RLS 策略见 `supabase/schema.sql`。

权限建议：

- 顾客：只读取 `status = published` 的 DM。
- 管理员：可以新增、编辑、下架、隐藏和删除全部 DM。

照片上传使用 Supabase Storage 的 `dm-avatars` bucket，数据库只保存图片 URL。第一版只有管理员账号，不包含 DM 个人登录、微信授权或审核流程。
