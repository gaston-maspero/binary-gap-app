import Foundation

protocol OnboardingStateProviding: AnyObject {
    var hasCompletedOnboarding: Bool { get }
    func markOnboardingCompleted()
    func resetOnboarding()
}

final class OnboardingStateProvider: OnboardingStateProviding {

    private enum Keys {
        static let hasCompleted = "com.binaryapp.onboarding.completed"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: Keys.hasCompleted)
    }

    func markOnboardingCompleted() {
        defaults.set(true, forKey: Keys.hasCompleted)
    }

    func resetOnboarding() {
        defaults.removeObject(forKey: Keys.hasCompleted)
    }
}
