# 🔧 Manual GitHub Release Guide - Quy Trình Thủ Công

## 📋 Tổng Quan Quy Trình:

```
1. Build App → 2. Commit Code → 3. Push GitHub → 4. Tạo Tag → 5. Tạo Release → 6. Upload File → 7. Publish
```

## 🚀 Bước 1: Build App Thủ Công

Mở **Command Prompt** hoặc **PowerShell**:

```bash
# Bước 1.1: Dọn dẹp project
flutter clean

# Bước 1.2: Cập nhật dependencies
flutter pub get

# Bước 1.3: Build App Bundle (Release)
flutter build appbundle --release

# hoặc Build với obfuscation (tối ưu hơn)
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
```

**Kết quả:**
```
✅ Build thành công
📂 File: build\app\outputs\bundle\release\edusync-release.aab
📏 Size: ~8-12MB
```

---

## 📝 Bước 2: Commit & Push Code

### 2.1 Check thay đổi:
```bash
git status
```

### 2.2 Add tất cả files:
```bash
git add .
```

### 2.3 Commit code:
```bash
git commit -m "Release v1.0.0"
```

**Commit message format:**
```
Release v1.0.0

- New features
- Bug fixes
- Performance improvements
```

### 2.4 Push lên GitHub:
```bash
git push origin main
```

---

## 🏷️  Bước 3: Tạo Git Tag

### 3.1 Tạo tag version:
```bash
git tag v1.0.0
```

**Tag format gợi ý:**
```
v1.0.0      - Initial release
v1.0.1      - Bug fix
v1.1.0      - New feature
v2.0.0      - Major update
v1.0.0-beta - Beta version
v1.0.0-alpha - Alpha version
```

### 3.2 Push tag lên GitHub:
```bash
git push origin v1.0.0
```

Hoặc push tất cả tags:
```bash
git push origin --tags
```

### 3.3 Kiểm tra tags đã tạo:
```bash
git tag -l
```

---

## 🌐 Bước 4: Tạo Release trên GitHub Web

### 4.1 Mở GitHub repository:
```
https://github.com/username/edusync
```

### 4.2 Tìm và click vào "Releases"
- Ở menu bên phải → Click "Releases"
- Hoặc đi trực tiếp: `https://github.com/username/edusync/releases`

### 4.3 Click "Create a new release"
- Nút màu xanh ở góc phải → "Draft a new release"

---

## 📋 Bước 5: Điền Release Information

### 5.1 Choose a tag:
```
📌 Select tag: v1.0.0
```
- Click vào dropdown → Chọn tag đã tạo
- Hoặc nhập tag mới: `v1.0.0`

### 5.2 Release title:
```
📌 Title: EduSync v1.0.0
```

### 5.3 Release notes:
```
📌 Description:

🎉 EduSync v1.0.0 - Initial Release

✨ Features:
- User authentication with email/password
- Class management system
- Real-time notifications
- Schedule integration

🐛 Bug Fixes:
- Fixed login timeout issues
- Improved app stability

📱 Technical:
- App size: 10MB (optimized 80%)
- Supports Android 5.0+
- Compatible with Google Play

🔗 Download edusync-release.aab below
```

### 5.4 Set release type:
```
☐ Set as a pre-release   (chọn nếu beta/alpha)
☑️ Set as the latest release (khuyến nghị)
```

---

## 📤 Bước 6: Upload File .aab

### 6.1 Tìm file build:
```
File location: build\app\outputs\bundle\release\edusync-release.aab
```

### 6.2 Upload file:
- Trong GitHub Release page → Kéo thả file `.aab`
- Hoặc click "Attach binary files" → Chọn file
- Đợi upload hoàn thành (~1-2 phút)

### 6.3 Verify upload:
```
✅ File uploaded: edusync-release.aab (8.2 MB)
```

---

## ✅ Bước 7: Publish Release

### 7.1 Review release:
- Kiểm tra tag, title, description
- Kiểm tra file đã upload
- Preview release

### 7.2 Click "Publish release"
- Nút màu xanh → "Publish release"

### 7.3 Release published!
```
🎉 Release created successfully!
🔗 Link: https://github.com/username/edusync/releases/tag/v1.0.0
```

---

## 📱 Bước 8: Test Download

### 8.1 Tải về và test:
```
Direct download:
https://github.com/username/edusync/releases/download/v1.0.0/edusync-release.aab
```

### 8.2 Share link:
```
Release page:
https://github.com/username/edusync/releases/v1.0.0
```

---

## 🔄 Quy Trình Đầy Đủ (All-in-One)

```bash
# === PHẦN 1: BUILD ===
echo "🔧 Building app..."
flutter clean
flutter pub get
flutter build appbundle --release

# === PHẦN 2: GIT OPERATIONS ===
echo "📝 Committing changes..."
git add .
git commit -m "Release v1.0.0"

echo "🚀 Pushing to GitHub..."
git push origin main

echo "🏷️  Creating tag..."
git tag v1.0.0
git push origin v1.0.0

# === PHẦN 3: GITHUB WEB ===
echo "🌐 Create release manually at:"
echo "https://github.com/username/edusync/releases/new?tag=v1.0.0"
echo ""
echo "📤 Upload: build\app\outputs\bundle\release\edusync-release.aab"
```

---

## 📋 Checklist Trước Khi Release:

### Code Quality:
- [ ] Test all features
- [ ] Fix critical bugs
- [ ] Update documentation
- [ ] Check app size (dưới 20MB)

### Git & Version:
- [ ] Commit all changes
- [ ] Create meaningful tag
- [ ] Push code & tags
- [ ] Verify on GitHub

### Release Info:
- [ ] Choose correct tag
- [ ] Write release title
- [ ] Add release notes
- [ ] Set release type (pre-release/latest)

### File Upload:
- [ ] Build .aab file
- [ ] Upload correct file
- [ ] Verify file size
- [ ] Test download link

---

## 🎯 Best Practices:

### 1. Version Consistency:
```
Git tag: v1.0.0
Release title: EduSync v1.0.0
File name: edusync-release.aab
```

### 2. Release Notes Format:
```markdown
🎉 EduSync v{VERSION}

✨ New Features:
- Feature 1
- Feature 2

🐛 Bug Fixes:
- Fix 1
- Fix 2

📱 Technical:
- Size: {XX}MB
- Requirements: Android {X.X}+
```

### 3. Testing Before Release:
```
Alpha → Beta → RC (Release Candidate) → Stable
```

---

## 🆘 Common Issues:

### Issue 1: Tag chưa được push
```bash
# Fix: Push tag manually
git push origin v1.0.0
```

### Issue 2: File không upload được
```
# Fix: Kiểm tra file size (limit 2GB)
# Chọn file .aab, không phải file khác
```

### Issue 3: Release URL 404
```
# Fix: Kiểm tra repo visibility
# Settings → Features → Visibility
```

---

## 🔗 Quick Reference Links:

### Tạo Release Direct:
```
https://github.com/username/edusync/releases/new
```

### Tạo Release với Tag:
```
https://github.com/username/edusync/releases/new?tag=v1.0.0
```

### Releases List:
```
https://github.com/username/edusync/releases
```

### Latest Release:
```
https://github.com/username/edusync/releases/latest
```

---

## 📊 Workflow Summary:

```
Local Development → Build → Git Commit → Push → Tag → GitHub Release → Upload → Publish → Share
```

**Time Estimate:** 10-15 phút cho lần đầu, 5-7 phút cho các lần sau.

---

**🎯 Done!** Bạn đã hoàn thành quy trình manual release hoàn toàn.