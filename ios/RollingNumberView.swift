import SwiftUI

// SwiftUI View that uses `.contentTransition(.numericText())`
struct RollingNumberView: View {
    let number: Int

    var body: some View {
        Text("\(number)")
            .contentTransition(.numericText())
            .font(.system(size: 24, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

// Hosting Controller that wraps SwiftUI in UIKit
class RollingNumberHostingController: UIHostingController<RollingNumberView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: RollingNumberView(number: 0))
    }

    override init(rootView: RollingNumberView) {
        super.init(rootView: rootView)
    }

    // Expose a method to update the number
    func updateNumber(_ newValue: Int) {
        rootView = RollingNumberView(number: newValue)
    }
}

// Objective-C Wrapper for React Native Fabric
@objc class RollingNumberViewWrapper: NSObject {
    @objc static func createInstance() -> UIViewController {
        return RollingNumberHostingController(rootView: RollingNumberView(number: 0))
    }
}
