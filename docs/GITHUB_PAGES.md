# GitHub Pages 发布说明

隐私政策页面文件：

- `docs/index.html` — 主页面（App Store 填这个 URL）
- `docs/user-agreement.html` — 用户协议（可选）

## 一键发布（终端）

在项目根目录执行（将 `你的GitHub用户名` 换成你的账号）：

```bash
cd ~/Projects/地震预警

git init
git add docs/ .gitignore
git commit -m "Add privacy policy for GitHub Pages"

# 在 GitHub 网页新建空仓库：zhenxun-privacy（不要勾选 README）
git branch -M main
git remote add origin https://github.com/你的GitHub用户名/zhenxun-privacy.git
git push -u origin main
```

## 开启 GitHub Pages

1. 打开 https://github.com/你的GitHub用户名/zhenxun-privacy/settings/pages
2. **Build and deployment** → Source 选 **Deploy from a branch**
3. Branch 选 **main**，文件夹选 **/docs**
4. 点 **Save**，等待 1～3 分钟

## 隐私政策 URL（填入 App Store Connect）

```
https://你的GitHub用户名.github.io/zhenxun-privacy/
```

注意末尾要有 `/`，或直接使用：

```
https://你的GitHub用户名.github.io/zhenxun-privacy/index.html
```

## 验证

浏览器打开上述 URL，应能看到「震讯 隐私政策」页面。

## 更新政策

修改 `docs/index.html` 或 `docs/隐私政策-网页版.md` 后：

```bash
git add docs/
git commit -m "Update privacy policy"
git push
```

Pages 会在几分钟内自动更新。
