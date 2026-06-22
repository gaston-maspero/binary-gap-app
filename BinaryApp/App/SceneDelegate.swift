import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let container = (UIApplication.shared.delegate as? AppDelegate)?.dependencies
            ?? DependencyContainer()

        let window = UIWindow(windowScene: windowScene)
        let rootController = container.homeBuilder.build()
        window.rootViewController = UINavigationController(rootViewController: rootController)
        window.makeKeyAndVisible()
        self.window = window

        presentOnboardingIfNeeded(container: container, from: rootController)
    }

    private func presentOnboardingIfNeeded(
        container: DependencyContainer,
        from rootController: UIViewController
    ) {
        guard !container.onboardingState.hasCompletedOnboarding else { return }
        DispatchQueue.main.async {
            let onboarding = container.onboardingBuilder.build()
            onboarding.modalPresentationStyle = .fullScreen
            rootController.present(onboarding, animated: false)
        }
    }
}
