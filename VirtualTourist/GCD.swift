//
//  GCD.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation

// MARK: - Perform UI Updates On Main

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
	DispatchQueue.main.async {
		updates()
	}
}
