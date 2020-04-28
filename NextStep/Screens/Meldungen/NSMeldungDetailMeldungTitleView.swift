///

import UIKit

class NSMeldungDetailMeldungTitleView: NSTitleView {
    // MARK: - API

    public var meldungen: [NSMeldungModel] = [] {
        didSet { update() }
    }

    // MARK: - Initial Views

    private var headers: [NSMeldungDetailMeldungSingleTitleHeader] = []
    private var stackScrollView = NSStackScrollView(axis: .horizontal, spacing: 0)

    private let pageControl = UIPageControl()
    private let overlapInset: CGFloat

    private var startAnimationNotDone = true
    private var updated = false

    // MARK: - Init

    init(overlapInset: CGFloat) {
        self.overlapInset = overlapInset

        super.init(frame: .zero)

        backgroundColor = .ns_blue
        setupStackScrollView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Layout

    private func setupStackScrollView() {
        stackScrollView.scrollView.isScrollEnabled = false

        pageControl.pageIndicatorTintColor = UIColor.ns_text.withAlphaComponent(0.46)
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.alpha = 0.0

        addSubview(stackScrollView)

        addSubview(pageControl)

        pageControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(overlapInset + NSPadding.medium)
        }

        stackScrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.bottom)
        }

        stackScrollView.scrollView.isPagingEnabled = true
        stackScrollView.scrollView.delegate = self
    }

    // MARK: - Protocol

    override func startInitialAnimation() {
        stackScrollView.scrollView.isScrollEnabled = headers.count > 0
        pageControl.alpha = headers.count > 1 ? 1.0 : 0.0

        for h in headers {
            h.startInitialAnimation()
        }
    }

    override func updateConstraintsForAnimation() {
        for h in headers {
            h.updateConstraintsForAnimation()
        }

        startAnimationNotDone = false
    }

    // MARK: - Update

    private func update() {
        for hv in headers {
            hv.removeFromSuperview()
        }

        stackScrollView.removeAllViews()
        headers.removeAll()

        var first = true
        for m in meldungen {
            let v = NSMeldungDetailMeldungSingleTitleHeader(setupOpen: startAnimationNotDone, onceMore: !first)
            v.meldung = m
            v.headerView = self

            stackScrollView.addArrangedView(v)

            v.snp.makeConstraints { make in
                make.width.equalTo(self)
            }

            headers.append(v)

            first = false
        }

        let currentPage: Int = max(0, headers.count - 1)

        pageControl.numberOfPages = headers.count
        pageControl.currentPage = currentPage
        pageControl.alpha = (!startAnimationNotDone && headers.count > 1) ? 1.0 : 0.0

        updated = true
        setNeedsLayout()
        layoutIfNeeded()

        stackScrollView.scrollView.isScrollEnabled = !startAnimationNotDone && headers.count > 1
        stackScrollView.scrollView.alwaysBounceHorizontal = !startAnimationNotDone && headers.count > 1
        stackScrollView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        accessibilityElements = [stackScrollView]
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if let obj = object as? UIScrollView {
            if obj == stackScrollView.scrollView, keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize, newSize.width > 0, self.frame.size.width > 0, updated {
                    stackScrollView.scrollView.setContentOffset(CGPoint(x: CGFloat(pageControl.currentPage) * self.frame.size.width, y: 0), animated: true)
                    updated = false
                }
            }
        }
    }

    deinit {
        self.stackScrollView.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }
}

extension NSMeldungDetailMeldungTitleView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let fraction = (scrollView.contentOffset.x / scrollView.contentSize.width)
        let number = Int(fraction * CGFloat(pageControl.numberOfPages))
        pageControl.currentPage = number
    }
}
