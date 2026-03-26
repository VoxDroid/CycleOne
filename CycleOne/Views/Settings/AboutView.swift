//
//  AboutView.swift
//  CycleOne
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        List {
            // App Header Section
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(
                                color: Color.themeAccent.opacity(0.15),
                                radius: 10, x: 0, y: 5
                            )

                        VStack(spacing: 4) {
                            Text("CycleOne")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.themeAccent)

                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text("A privacy-first, open-source period tracker for iOS.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            // Developer Section
            Section("Developer") {
                SettingsRow(
                    icon: "person.fill",
                    title: "VoxDroid",
                    subtitle: "Lead Developer",
                    color: .themeAccent
                )

                if let mailURL = URL(string: "mailto:izeno.contact@gmail.com") {
                    Link(destination: mailURL) {
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "izeno.contact@gmail.com",
                            subtitle: "Direct Support",
                            color: .blue,
                            showChevron: true
                        )
                    }
                }

                if let ghURL = URL(string: "https://github.com/VoxDroid") {
                    Link(destination: ghURL) {
                        SettingsRow(
                            icon: "link",
                            title: "github.com/VoxDroid",
                            subtitle: "Follow on GitHub",
                            color: .purple,
                            showChevron: true
                        )
                    }
                }
            }

            // Project Section
            Section("Project") {
                if let repoURL = URL(string: "https://github.com/VoxDroid/CycleOne") {
                    Link(destination: repoURL) {
                        SettingsRow(
                            icon: "chevron.left.forwardslash.chevron.right",
                            title: "Source Code",
                            subtitle: "GPL-3.0 Licensed",
                            color: .green,
                            showChevron: true
                        )
                    }
                }

                SettingsRow(
                    icon: "shield.fill",
                    title: "Privacy Commitment",
                    subtitle: "100% local, zero tracking",
                    color: .indigo
                )

                SettingsRow(
                    icon: "swift",
                    title: "Built with Swift",
                    subtitle: "SwiftUI + Core Data",
                    color: .orange
                )
            }

            // Footer Section
            Section {
                VStack(spacing: 6) {
                    Text("CycleOne by VoxDroid")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Text("\u{00A9} 2026 VoxDroid. All rights reserved.")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
