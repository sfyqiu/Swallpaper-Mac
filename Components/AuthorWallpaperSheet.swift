import SwiftUI
import Kingfisher

// MARK: - 作者壁纸弹出层
struct AuthorWallpaperSheet: View {
    let uploader: Wallpaper.Uploader
    let wallpapers: [Wallpaper]
    let isLoading: Bool
    let onSelectWallpaper: (Wallpaper) -> Void
    let onDismiss: () -> Void
    let onLoadMore: (() -> Void)?

    @State private var isVisible = false
    @State private var contentOffset: CGFloat = 0

    private let cardWidthRatio: CGFloat = 0.44
    private let cardSpacing: CGFloat = 12
    private let cornerRadius: CGFloat = 28

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 半透明背景
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismiss()
                    }
                    .opacity(isVisible ? 1 : 0)

                // 底部弹出卡片
                VStack(spacing: 0) {
                    // 拖拽指示器
                    Capsule()
                        .fill(.white.opacity(0.25))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    // 作者信息头部
                    authorHeader
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    // 分隔线
                    dividerLine
                        .padding(.horizontal, 24)

                    // 壁纸网格标题
                    HStack {
                        Text(t("authorWallpapers"))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16, height: 16)
                        }
                        if !wallpapers.isEmpty {
                            Text("\(wallpapers.count)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                    // 壁纸网格
                    wallpaperGrid
                        .frame(maxHeight: .infinity)
                }
                .frame(maxHeight: 560)
                .frame(maxWidth: min(480, geometry.size.width - 32))
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(Color(hex: "0A0A0C").opacity(0.45))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(.white.opacity(0.1), lineWidth: 0.5)
                        )
                )
                .shadow(color: .black.opacity(0.4), radius: 40, y: -8)
                .offset(y: isVisible ? 0 : 600)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.88, blendDuration: 0)) {
                isVisible = true
            }
        }
    }

    // MARK: - 作者信息头部
    private var authorHeader: some View {
        HStack(spacing: 14) {
            // 作者头像
            authorAvatar
                .frame(width: 48, height: 48)

            // 作者名称和信息
            VStack(alignment: .leading, spacing: 4) {
                Text(uploader.username)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    // 来源标签
                    Text("wallhaven")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.1))
                        )
                }
            }

            Spacer()

            // 关闭按钮
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 作者头像
    @ViewBuilder
    private var authorAvatar: some View {
        let avatarURL = selectBestAvatarURL()

        if let url = avatarURL {
            KFImage(url)
                .placeholder { _ in
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.12), lineWidth: 1)
                )
        } else {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(.white.opacity(0.08))
                )
        }
    }

    // MARK: - 壁纸网格
    private var wallpaperGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if wallpapers.isEmpty && !isLoading {
                emptyState
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: cardSpacing),
                        GridItem(.flexible(), spacing: cardSpacing)
                    ],
                    spacing: cardSpacing
                ) {
                    ForEach(wallpapers) { wallpaper in
                        AuthorWallpaperCard(
                            wallpaper: wallpaper,
                            onTap: {
                                onSelectWallpaper(wallpaper)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // 加载更多触发器
                if let onLoadMore = onLoadMore, !wallpapers.isEmpty {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            onLoadMore()
                        }
                }
            }

            // 底部安全区
            Color.clear
                .frame(height: 12)
        }

    }

    // MARK: - 空状态
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.2))

            Text(t("noWallpapers"))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - 分隔线
    private var dividerLine: some View {
        Rectangle()
            .fill(.white.opacity(0.06))
            .frame(height: 1)
    }

    // MARK: - Helper
    private func selectBestAvatarURL() -> URL? {
        // 优先使用 200px，其次 128px，再次 32px
        let urls = [
            uploader.avatar.px200,
            uploader.avatar.px128,
            uploader.avatar.px32
        ]
        for urlString in urls {
            if let url = URL(string: urlString), !urlString.isEmpty {
                return url
            }
        }
        return nil
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.88, blendDuration: 0)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - 作者壁纸卡片
private struct AuthorWallpaperCard: View {
    let wallpaper: Wallpaper
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // 壁纸封面
                KFImage(wallpaper.thumbURL ?? wallpaper.fullImageURL)
                    .placeholder { _ in
                        Rectangle()
                            .fill(.white.opacity(0.05))
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: cardImageHeight)
                    .clipped()

                // 底部信息
                HStack(spacing: 6) {
                    // 分类标签
                    if !wallpaper.category.isEmpty {
                        Text(wallpaper.categoryDisplayName)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.08))
                            )
                    }

                    Spacer(minLength: 0)

                    // 分辨率
                    if !wallpaper.resolution.isEmpty {
                        Text(wallpaper.resolution)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.35))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(hex: "1A1D24").opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isHovered ? .white.opacity(0.2) : .white.opacity(0.06), lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(isHovered ? 1.02 : 1)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }

    /// 根据当前视图宽度自适应卡片图片高度
    private var cardImageHeight: CGFloat {
        120
    }
}
