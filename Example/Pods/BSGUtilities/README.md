# BSGUtilities

[![CI Status](http://img.shields.io/travis/Bootstragram/BSGUtilities.svg?style=flat)](https://travis-ci.org/Bootstragram/BSGUtilities)
[![Version](https://img.shields.io/cocoapods/v/BSGUtilities.svg?style=flat)](http://cocoadocs.org/docsets/BSGUtilities)
[![License](https://img.shields.io/cocoapods/l/BSGUtilities.svg?style=flat)](http://cocoadocs.org/docsets/BSGUtilities)
[![Platform](https://img.shields.io/cocoapods/p/BSGUtilities.svg?style=flat)](http://cocoadocs.org/docsets/BSGUtilities)

## Reminders

Validate the pod:

    pod lib lint # from the **root**

Publish the pod to the repo:

    pod repo push bootstragram-public-pod-repo BSGUtilities.podspec

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BSGUtilities is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "BSGUtilities"

## Author

Bootstragram, contact@bootstragram.com

## License

BSGUtilities is available under the MIT license. See the LICENSE file for more info.

## How-Tos

### How to use the Core Data debug views?

The easisest way to install the Core Data debug views is via the Storyboard.

Create 3 table view controllers, with the following class names, table view cell identifier and segue identifiers:

1. `BSGEntitiesTableViewController` should use cells with *Right Detail* style, `BSGEntitiesViewControllerCell`
   cell identifier and *Disclosure Indicator* accessory using a `BSGManagedObjectsTableViewController` segue.
2. `BSGManagedObjectsTableViewController` should use cells with *Right Detail* style, `BSGManagedObjectsViewControllerCell`
   cell identifier and *Disclosure Indicator* accessory using a `BSGManagedObjectDetailTableViewController` segue.
3. `BSGManagedObjectDetailTableViewController` should use cells with *Left Detail* style, `BSGManagedObjectDetailViewControllerCell`
   cell identifier
