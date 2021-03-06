// Copyright © 2015 Abhishek Banthia

import Cocoa

struct AboutUsConstants {
    static let AboutUsNibIdentifier = "CLAboutWindows"
    static let GitHubURL = "https://github.com/abhishekbanthia/Clocker/?ref=ClockerApp"
    static let PayPalURL = "https://paypal.me/abhishekbanthia1712"
    static let TwitterLink = "https://twitter.com/n0shake/?ref=ClockerApp"
    static let PersonalWebsite = "http://abhishekbanthia.com/?ref=ClockerApp"
    static let AppStoreLink = "macappstore://itunes.apple.com/us/app/clocker/id1056643111?action=write-review"
}

class AboutViewController: ParentViewController {
    @IBOutlet var quickCommentAction: UnderlinedButton!
    @IBOutlet var privateFeedback: UnderlinedButton!
    @IBOutlet var supportClocker: UnderlinedButton!
    @IBOutlet var openSourceButton: UnderlinedButton!
    @IBOutlet var versionField: NSTextField!

    private var themeDidChangeNotification: NSObjectProtocol?
    private lazy var feedbackWindow = AppFeedbackWindowController.shared()

    override func viewDidLoad() {
        super.viewDidLoad()

        privateFeedback.setAccessibilityIdentifier("ClockerPrivateFeedback")

        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "N/A"
        let longVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "N/A"

        versionField.stringValue = "Clocker \(shortVersion) (\(longVersion))"

        setup()

        themeDidChangeNotification = NotificationCenter.default.addObserver(forName: .themeDidChangeNotification, object: nil, queue: OperationQueue.main) { _ in
            self.setup()
        }
    }

    deinit {
        if let themeDidChangeNotif = themeDidChangeNotification {
            NotificationCenter.default.removeObserver(themeDidChangeNotif)
        }
    }

    private func underlineTextForActionButton() {
        let rangesInOrder = [NSRange(location: 3, length: 8),
                             NSRange(location: 7, length: privateFeedback.attributedTitle.length - 7),
                             NSRange(location: 27, length: 33),
                             NSRange(location: 32, length: 30)]

        let buttonsInOrder = [quickCommentAction,
                              privateFeedback,
                              supportClocker,
                              openSourceButton]

        let localizedKeys = ["1. @n0shake on Twitter for quick comments",
                             "2. For Private Feedback",
                             "You can support Clocker by leaving a review on the App Store! :)",
                             "Clocker is Open Source. You can check out the source code here."]

        zip(buttonsInOrder, localizedKeys).forEach { arg in
            let (button, title) = arg
            button?.title = title
        }

        zip(rangesInOrder, buttonsInOrder).forEach { arg in
            let (range, button) = arg
            setUnderline(for: button, range: range)
        }
    }

    private func setUnderline(for button: UnderlinedButton?, range: NSRange) {
        guard let underlinedButton = button else { return }

        let mutableParaghStyle = NSMutableParagraphStyle()
        mutableParaghStyle.alignment = .center

        let originalText = NSMutableAttributedString(string: underlinedButton.title)
        originalText.addAttribute(NSAttributedString.Key.underlineStyle,
                                  value: NSNumber(value: Int8(NSUnderlineStyle.single.rawValue)),
                                  range: range)
        originalText.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: Themer.shared().mainTextColor(),
                                  range: NSRange(location: 0, length: underlinedButton.attributedTitle.string.count))
        originalText.addAttribute(NSAttributedString.Key.font,
                                  value: (button?.font)!,
                                  range: NSRange(location: 0, length: underlinedButton.attributedTitle.string.count))
        originalText.addAttribute(NSAttributedString.Key.paragraphStyle,
                                  value: mutableParaghStyle,
                                  range: NSRange(location: 0, length: underlinedButton.attributedTitle.string.count))
        underlinedButton.attributedTitle = originalText
    }

    @IBAction func openMyTwitter(_: Any) {
        guard let twitterURL = URL(string: AboutUsConstants.TwitterLink),
            let countryCode = Locale.autoupdatingCurrent.regionCode else { return }

        NSWorkspace.shared.open(twitterURL)

        // Log this
        let custom: [String: Any] = ["Country": countryCode]
        Logger.log(object: custom, for: "Opened Twitter")
    }

    @IBAction func viewSource(_: Any) {
        guard let sourceURL = URL(string: AboutUsConstants.AppStoreLink),
            let countryCode = Locale.autoupdatingCurrent.regionCode else { return }

        NSWorkspace.shared.open(sourceURL)

        // Log this
        let custom: [String: Any] = ["Country": countryCode]
        Logger.log(object: custom, for: "Open App Store to Review")
    }

    @IBAction func reportIssue(_: Any) {
        feedbackWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        view.window?.orderOut(nil)

        if let countryCode = Locale.autoupdatingCurrent.regionCode {
            let custom: [String: Any] = ["Country": countryCode]
            Logger.log(object: custom, for: "Report Issue Opened")
        }
    }

    @IBAction func openGitHub(_: Any) {
        guard let githubURL = URL(string: AboutUsConstants.GitHubURL),
            let countryCode = Locale.autoupdatingCurrent.regionCode else { return }

        NSWorkspace.shared.open(githubURL)

        let custom: [String: Any] = ["Country": countryCode]
        Logger.log(object: custom, for: "Opened GitHub")
    }

    @IBOutlet var feedbackLabel: NSTextField!

    private func setup() {
        feedbackLabel.stringValue = "Feedback is always welcome:"
        feedbackLabel.textColor = Themer.shared().mainTextColor()
        versionField.textColor = Themer.shared().mainTextColor()
        underlineTextForActionButton()
    }
}
