//
//  AboutView.swift
//  CycleOne
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Header
                VStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)
                        )
                        .shadow(
                            color: Color.themeAccent
                                .opacity(0.15),
                            radius: 12, x: 0, y: 6
                        )

                    Text("CycleOne")
                        .font(.system(
                            .title2, design: .rounded
                        ))
                        .fontWeight(.bold)
                        .foregroundColor(.themeAccent)

                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(
                        "A privacy-first, open-source period "
                            + "tracker for iOS."
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                }
                .padding(.top, 16)

                // Developer Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("Developer")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                    AboutRow(
                        icon: "person.fill",
                        title: "VoxDroid",
                        subtitle: "Developer",
                        color: .themeAccent
                    )

                    Divider().padding(.leading, 56)

                    if let mailURL = URL(
                        string: "mailto:izeno.contact@gmail.com"
                    ) {
                        Link(destination: mailURL) {
                            AboutRow(
                                icon: "envelope.fill",
                                title:
                                "izeno.contact@gmail.com",
                                subtitle: "Email",
                                color: .blue,
                                showChevron: true
                            )
                        }
                    }

                    Divider().padding(.leading, 56)

                    if let ghURL = URL(
                        string:
                        "https://github.com/VoxDroid"
                    ) {
                        Link(destination: ghURL) {
                            AboutRow(
                                icon: "link",
                                title: "github.com/VoxDroid",
                                subtitle: "GitHub",
                                color: .purple,
                                showChevron: true
                            )
                        }
                    }
                }
                .background(
                    RoundedRectangle(
                        cornerRadius: Theme.cornerRadius
                    )
                    .fill(Color(.secondarySystemBackground))
                    .padding(.horizontal, 16)
                )

                // Project Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("Project")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                    if let repoURL = URL(
                        string:
                        "https://github.com/VoxDroid/CycleOne"
                    ) {
                        Link(destination: repoURL) {
                            AboutRow(
                                icon: "chevron.left.forwardslash.chevron.right",
                                title: "Source Code",
                                subtitle: "GPL-3.0 Licensed",
                                color: .green,
                                showChevron: true
                            )
                        }
                    }

                    Divider().padding(.leading, 56)

                    AboutRow(
                        icon: "shield.fill",
                        title: "Privacy",
                        subtitle:
                        "100% local, zero tracking",
                        color: .indigo
                    )

                    Divider().padding(.leading, 56)

                    AboutRow(
                        icon: "swift",
                        title: "Built with Swift",
                        subtitle:
                        "SwiftUI + Core Data",
                        color: .orange
                    )
                }
                .background(
                    RoundedRectangle(
                        cornerRadius: Theme.cornerRadius
                    )
                    .fill(Color(.secondarySystemBackground))
                    .padding(.horizontal, 16)
                )

                // Footer
                VStack(spacing: 4) {
                    Text("CycleOne by VoxDroid")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text(
                        "\u{00A9} 2026 VoxDroid. "
                            + "All rights reserved."
                    )
                    .font(.caption2)
                    .foregroundColor(
                        .secondary.opacity(0.7)
                    )
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AboutRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var showChevron: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(color)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
