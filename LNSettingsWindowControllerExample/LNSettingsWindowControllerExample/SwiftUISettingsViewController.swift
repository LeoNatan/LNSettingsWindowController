//
//  SwiftUISettingsViewController.swift
//  LNSettingsWindowControllerExample
//
//  Created by Léo Natan on 12/5/25.
//

import SwiftUI
import LNSettingsWindowController

struct SwiftUISettingsView: View {
	@State var pickerSelection: String = "Option 1"
	@State var toggle1Value: Bool = true
	@State var toggle2Value: Bool = true
	@State var toggle3Value: Bool = true
	
    var body: some View {
		Form {
			Section {
				Picker("Settings", selection: $pickerSelection) {
					Text("Option 1").tag("Option 1")
					Text("Option 2").tag("Option 2")
					Text("Option 3").tag("Option 3")
				}
			}
			Section {
				Toggle("Toggle 1", isOn: $toggle1Value)
				Toggle("Toggle 2", isOn: $toggle2Value)
				Toggle("Toggle 3", isOn: $toggle3Value)
			}
			Section {
				HStack {
					Spacer()
					Button("Button 1") {
						
					}
					
					Button("Button 2") {
						
					}
					
					Button("Button 3") {
						
					}
				}
			}
		}
		.toggleStyle(.switch)
		.formStyle(.grouped)
		.frame(width: 400)
    }
}

class SwiftUISettingsViewController: NSHostingController<SwiftUISettingsView>, LNSettingsWindowControllerDataSource {
	var settingsTitle: String {
		"SwiftUI"
	}
	
	var settingsIdentifier: String {
		"swiftui"
	}
	
	var settingsToolbarIcon: NSImage {
		NSImage(systemSymbolName: "swift", accessibilityDescription: nil)!
	}
	
	required init() {
		super.init(rootView: SwiftUISettingsView())
		sizingOptions = [.preferredContentSize]
	}
	
	@MainActor @preconcurrency required dynamic init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

#Preview {
    SwiftUISettingsViewController()
}
