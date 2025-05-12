//
//  AppDelegate.swift
//  LNSettingsWindowControllerExample
//
//  Created by Léo Natan on 12/5/25.
//

import Cocoa
import LNSettingsWindowController

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	let settingsController = LNSettingsWindowController()

	@IBAction func showSettings(_ sender: Any) {
		settingsController.showSettingsWindow()
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let settingsStoryboard = NSStoryboard(name: "Settings", bundle: nil)
		settingsController.viewControllers = [settingsStoryboard.instantiateInitialController() as! NSViewController & LNSettingsWindowControllerDataSource,
											  SwiftUISettingsViewController()]
	}
}

