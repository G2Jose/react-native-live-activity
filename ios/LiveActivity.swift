import Foundation
import ActivityKit

@objc(LiveActivity)
class LiveActivity: NSObject {
  
  func isIphone() -> Bool {
    if #available(iOS 14.0, *) {
      return !ProcessInfo.processInfo.isiOSAppOnMac
    } else {
      return false
    }
  }
  
  @objc(startActivity:withResolver:withRejecter:)
  func startActivity(data: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
    if #available(iOS 16.1, *), isIphone() {
      var activity: Activity<MyActivityAttributes>?
      let initialContentState = MyActivityAttributes
        .ContentState(data: data)
      let activityAttributes = MyActivityAttributes()
      
      do {
        activity = try Activity
          .request(attributes: activityAttributes, contentState: initialContentState)
        
        resolve((String(describing: activity?.id)))
      } catch (let error) {
        reject("Error requesting Live Activity \(error.localizedDescription).", "", error)
      }
    } else {
      resolve(nil)
    }
  }
  
  @objc(listAllActivities:withRejecter:)
  func listAllActivities(resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    if #available(iOS 16.1, *), isIphone() {
      
      var activities = Activity<MyActivityAttributes>.activities
      activities.sort { $0.id > $1.id }
      
      return resolve(activities.map{["id": $0.id, "data": $0.contentState.data ]})
      
      
    } else {
      resolve([])
    }
  }
  
  @objc(endActivity:withResolver:withRejecter:)
  func endActivity(id: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    if #available(iOS 16.1, *), isIphone() {
      Task {
        await Activity<MyActivityAttributes>.activities.filter {$0.id == id}.first?.end(dismissalPolicy: .immediate)
      }
    }
  }
  
  @objc(updateActivity:withData:withResolver:withRejecter:)
  func updateActivity(id: String, data: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    if #available(iOS 16.1, *), isIphone() {
      Task {
        let updatedStatus = MyActivityAttributes
          .ContentState(data: data)
        let activities = Activity<MyActivityAttributes>.activities
        let activity = activities.filter {$0.id == id}.first
        await activity?.update(using: updatedStatus)
      }
    } 
  }
}
