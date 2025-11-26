// import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var securityView: UIView? // لطبقة الحماية عند التسجيل
    private var privacyOverlay: UIView? // لطبقة الحماية في الـ App Switcher
    private var secureOverlayField: UITextField? // الحل الإضافي لمنع لقطات الشاشة لـ iOS 13+

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        // Setup screenshot and recording prevention
        setupSecurityMeasures()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // يجب حذف المراقبين عند إنهاء التطبيق
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

// --- قسم الإعدادات ---

    private func setupSecurityMeasures() {
        // إنشاء الـ View الأمني أولاً (طبقة سوداء عند التسجيل)
        createSecurityView()
        
        // *الحل الأقوى لمنع لقطات الشاشة (Screen Shot): إضافة حقل نص آمن شفّاف*
        addSecureOverlayField()

        // مراقبة دورة حياة التطبيق
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // مراقبة لقطات الشاشة (سلوك التنبيه/التفاعل)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenshotTaken),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )

        // مراقبة تسجيل الشاشة (سلوك المنع الفوري)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )

        // التحقق عند بدء تشغيل التطبيق
        if UIScreen.main.isCaptured {
            showSecurityOverlay()
        }
    }
    
    // الحل الإضافي لمنع لقطات الشاشة باستخدام حقل نص آمن
    private func addSecureOverlayField() {
        guard let window = self.window, secureOverlayField == nil else { return }
        
        secureOverlayField = UITextField()
        secureOverlayField?.isSecureTextEntry = true // السر هنا: هذه الخاصية تمنع لقطة الشاشة
        window.addSubview(secureOverlayField!)
        
        // يجب أن يكون الحقل فوق كل المحتوى ولكنه غير مرئي
        secureOverlayField?.isUserInteractionEnabled = false
        secureOverlayField?.alpha = 0.0 // لجعله شفافًا
        secureOverlayField?.translatesAutoresizingMaskIntoConstraints = false
        
        // جعله يغطي كامل الشاشة
        NSLayoutConstraint.activate([
            secureOverlayField!.topAnchor.constraint(equalTo: window.topAnchor),
            secureOverlayField!.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            secureOverlayField!.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            secureOverlayField!.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ])
        
        // جعله 'يركز' لكي تعمل خاصية الأمان
        secureOverlayField?.becomeFirstResponder()
    }

    private func createSecurityView() {
        guard let window = self.window else { return }

        securityView = UIView(frame: window.bounds)
        securityView?.backgroundColor = UIColor.black
        securityView?.alpha = 0.0

        // ... (باقي كود إنشاء الرسالة التحذيرية داخل securityView لم يتغير) ...

        // Add warning message (الرسالة التحذيرية)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let iconLabel = UILabel()
        iconLabel.text = "🔒"
        iconLabel.font = UIFont.systemFont(ofSize: 50)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Content Protected"
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let messageLabel = UILabel()
        messageLabel.text = "Screen recording detected.\nContent is hidden for security."
        messageLabel.textColor = UIColor.lightGray
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        securityView?.addSubview(containerView)

        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: securityView!.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: securityView!.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: securityView!.widthAnchor, multiplier: 0.8),

            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    

// --- قسم دورة حياة التطبيق والحماية ---

    @objc private func appWillResignActive() {
        // إضافة طبقة حماية لـ App Switcher عند الخروج المؤقت
        addPrivacyOverlay()
        
        // *التحسين:* إزالة تركيز حقل الأمان مؤقتاً عند الخروج لتجنب مشاكل في iOS 17+
        secureOverlayField?.resignFirstResponder()
    }

    @objc private func appDidBecomeActive() {
        // إزالة طبقة حماية App Switcher
        removePrivacyOverlay()
        
        // إعادة تركيز حقل الأمان عند العودة
        secureOverlayField?.becomeFirstResponder()
        
        // تأكد من حالة التسجيل عند العودة للتطبيق
        if UIScreen.main.isCaptured {
            showSecurityOverlay()
        }
    }

    @objc private func screenshotTaken() {
        print("📱 Screenshot detected! Showing Alert.")

        // *ملاحظة:* إضافة الـ secureOverlayField سيجعل لقطة الشاشة سوداء بالكامل 
        // أو تحوي الحقل الآمن فقط في معظم الحالات. 
        // التنبيه لا يزال مفيداً لتسجيل محاولة الاختراق.
        DispatchQueue.main.async {
            self.showScreenshotAlert()
        }
    }

    @objc private func screenCaptureChanged() {
        DispatchQueue.main.async {
            if UIScreen.main.isCaptured {
                print("🎥 Screen recording started! Hiding content.")
                self.showSecurityOverlay()
            } else {
                print("🎥 Screen recording stopped! Showing content.")
                self.hideSecurityOverlay()
            }
        }
    }

// --- قسم الـ View Managment ---

    private func showSecurityOverlay() {
        guard let window = self.window, let securityView = self.securityView else { return }

        if securityView.superview == nil {
            securityView.frame = window.bounds
            // تأكد من أن طبقة الأمان فوق حقل الأمان الشفاف إن وجد
            if let secureField = secureOverlayField {
                window.insertSubview(securityView, belowSubview: secureField)
            } else {
                window.addSubview(securityView)
            }
            securityView.alpha = 0.0
        }

        // إخفاء الـ Flutter content بعرض الطبقة السوداء
        UIView.animate(withDuration: 0.3) {
            securityView.alpha = 1.0
        }
    }

    private func hideSecurityOverlay() {
        guard let securityView = self.securityView else { return }

        UIView.animate(withDuration: 0.3, animations: {
            securityView.alpha = 0.0
        }) { _ in
            // إزالة الـ View الأمني فقط إذا توقف التسجيل
            securityView.removeFromSuperview()
        }
    }

    // (دوال addPrivacyOverlay و removePrivacyOverlay و showScreenshotAlert لم تتغير)
    
    private func addPrivacyOverlay() {
        guard let window = self.window, privacyOverlay == nil else { return }

        privacyOverlay = UIView(frame: window.bounds)
        privacyOverlay?.backgroundColor = UIColor.white

        // Add app logo/name for a professional look
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let logoLabel = UILabel()
        logoLabel.text = "👨‍⚕️"
        logoLabel.font = UIFont.systemFont(ofSize: 60)
        logoLabel.textAlignment = .center

        let appNameLabel = UILabel()
        appNameLabel.text = "Anmka Mr Doctor"
        appNameLabel.textAlignment = .center
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        appNameLabel.textColor = UIColor.black

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Medical Application"
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.gray

        stackView.addArrangedSubview(logoLabel)
        stackView.addArrangedSubview(appNameLabel)
        stackView.addArrangedSubview(subtitleLabel)

        privacyOverlay?.addSubview(stackView)
        window.addSubview(privacyOverlay!)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: privacyOverlay!.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: privacyOverlay!.centerYAnchor)
        ])
    }

    private func removePrivacyOverlay() {
        privacyOverlay?.removeFromSuperview()
        privacyOverlay = nil
    }

    private func showScreenshotAlert() {
        guard let window = self.window,
              let rootViewController = window.rootViewController else { return }

        let alert = UIAlertController(
            title: "⚠️ Security Alert",
            message: "Screenshots are not permitted in this application for security and privacy reasons.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Understood", style: .default) { _ in
            print("User acknowledged screenshot warning")
        })

        // Present alert only if no other alert is showing
        if rootViewController.presentedViewController == nil {
            rootViewController.present(alert, animated: true)
        }
    }
}