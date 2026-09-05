# 秘Times DM 人物展示工具

这是一个已发布到 GitHub Pages 的静态单页原型，入口文件为 `index.html`。

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

## 当前数据状态

DM 数据目前仍在 `index.html` 的 `dms` 数组中，适合原型演示，不适合正式运营。替换图片、昵称、标签和作品时，修改该数组即可。

## 后台改造方案（V1）

推荐使用 Supabase：

1. `dm_profiles`：保存昵称、照片 URL、性别、从业年限、带本数量、一句话介绍、适合玩家、上架状态。
2. `dm_tags`：保存能力标签，使用 `dm_id` 关联 DM。
3. `dm_types`：保存剧本类型，使用 `dm_id` 关联 DM。
4. `dm_works`：保存最多 3 部代表作品，使用 `dm_id` 关联 DM。
5. `dm_change_requests`：保存 DM 自主修改后的待审核版本、提交人、审核状态和审核备注。

权限建议：

- 顾客：只读取 `status = published` 的 DM。
- DM：微信登录后只能创建和查看自己的修改申请，不能直接改线上资料。
- 管理员：可以新增、编辑、下架、隐藏 DM，并审核修改申请。

前端接入后，将 `dms` 数组替换成 Supabase 查询；审核通过后更新 `dm_profiles`，前台下次加载自动读取最新资料。照片上传使用 Supabase Storage，数据库只保存图片 URL。

正式接入后台前还需要配置：Supabase 项目、管理员账号、微信登录参数，以及正式环境的环境变量。当前线上版本仍使用 `index.html` 内的演示数据，尚未接入管理员登录或数据库写入。
