//
//  GeneralSettingsController.swift
//  LNSettingsWindowControllerExample
//
//  Created by Léo Natan on 12/5/25.
//

import Cocoa
import LNSettingsWindowController

class GeneralSettingsController: NSViewController, LNSettingsWindowControllerDataSource {
	var settingsIdentifier: String {
		"general"
	}
	
	var settingsTitle: String {
		String(localized: "General")
	}
	
	var settingsToolbarIcon: NSImage {
		NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!
	}
	
}
