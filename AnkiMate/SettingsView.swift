//
//  SettingsView.swift
//  AnkiMate
//
//  Created by Sunrizz on 8/11/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text(UIDevice.current.systemName)
                    Spacer()
                    Text(UIDevice.current.systemVersion)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
