//
//  OnelinerView.swift
//  OnelinerKit
//
//  Created by Marcus Kida on 17.12.17.
//  Copyright © 2017 Marcus Kida. All rights reserved.
//

import ScreenSaver
import AVFoundation

open class OnelinerView: ScreenSaverView {
    private let fetchQueue = DispatchQueue(label: "fetchQueue")
    private let mainQueue = DispatchQueue.main
    
    private var label: NSTextField!
    private var wrapper: NSView!
    
    private var backgroundPlayer: NSView!
    private var videoLayer: AVPlayerLayer?
    private var files: [String] = []
    private var index = 0
    private var fading = false
    
    private var fetching = true
    private var lastFetchDate: Date?
    
    public var backgroundColor = NSColor.black
    public var textColor = NSColor.white
    
    var configureVC: ConfigureViewController = ConfigureViewController()
    
    
    convenience init() {
        self.init(frame: .zero, isPreview: false)
        label = .label(false, bounds: frame)
        wrapper = NSView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        backgroundPlayer = NSView(frame: frame)
        initialize()
    }
    
    override init!(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        wrapper = NSView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        label = .label(isPreview, bounds: frame)
        backgroundPlayer = NSView(frame: frame)
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        label = .label(isPreview, bounds: bounds)
        wrapper = NSView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        backgroundPlayer = NSView(frame: frame)
        initialize()
    }
    
    override open var configureSheet: NSWindow? {
        return configureVC.window
    }
    
    override open var hasConfigureSheet: Bool {
        return true
    }
    
    override open func animateOneFrame() {
        return
    }
    
    override open func draw(_ rect: NSRect) {
        super.draw(rect)
        
        var newFrame = wrapper.frame
        newFrame.origin.y = rect.size.height / 2
        newFrame.size.width = (label.stringValue as NSString).size(withAttributes: [NSAttributedString.Key.font: label.font!]).width + 40
        newFrame.origin.x = (frame.size.width - newFrame.size.width) / 2
        newFrame.size.height = (label.stringValue as NSString).size(withAttributes: [NSAttributedString.Key.font: label.font!]).height + 20
        wrapper.frame = newFrame

        label.frame = CGRect(x: 0, y: 10, width: newFrame.size.width, height: newFrame.size.height - 20)
        label.textColor = textColor
        
        backgroundColor.setFill()
        rect.fill()
        
        backgroundPlayer.frame = frame
        videoLayer?.frame = frame
    }
    
    open func fetchOneline(_ completion: @escaping (String) -> Void) {
        preconditionFailure("`fetchOneline` must be overridden")
    }
    
    private func initializePlayer() {
//        let path = NSHomeDirectory() + "/Movies/LiveDevEx/saver.mp4"
        let folder = NSHomeDirectory() + "/Movies/LiveDevEx/"

        do {
            try files = FileManager.default.contentsOfDirectory(atPath: folder)
            files = files.filter { (each) -> Bool in
                return each.hasSuffix(".mp4")
            }.map({ (each) -> String in
                return folder.appending(each)
            })
        } catch {
            debugPrint(error)
            return
        }
        if files.count == 0 {
            return
        }
        
        let path = files[index]

        if !FileManager.default.fileExists(atPath: path) {
            return
        }

        self.backgroundPlayer.wantsLayer = true
        let url = NSURL.fileURL(withPath: path)
        let player = AVPlayer(url: url)
        player.isMuted = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onVideoReachedEnd(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem)

        videoLayer = AVPlayerLayer(player: player)
        videoLayer?.videoGravity = .resizeAspectFill
        addFadeToPlayer()
        backgroundPlayer.layer?.addSublayer(videoLayer!)
        player.play()
    }
    
    private func initializeFolder() {
        let path = NSHomeDirectory().appending("/Movies/LiveDevEx")
        if FileManager.default.fileExists(atPath: path) {
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: [:])
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    private func initialize() {
        initializeFolder()
        animationTimeInterval = 0.5
        label.drawsBackground = true

        wrapper.wantsLayer = true
        wrapper.layer?.cornerRadius = 10
        wrapper.layer?.backgroundColor = NSColor.init(red:0.16, green:0.16, blue:0.18, alpha:0.8).cgColor
        wrapper.addSubview(label)
        
        initializePlayer()
        addSubview(backgroundPlayer)
        addSubview(wrapper)
        restoreLast()
        scheduleNext()
    }
    
    private func restoreLast() {
        fetching = false
        set(oneliner: UserDefaults.lastOneline)
    }
    
    private func set(oneliner: String?) {
        if let oneliner = oneliner {
            label.stringValue = oneliner
            UserDefaults.lastOneline = oneliner
            setNeedsDisplay(frame)
        }
    }
    
    private func scheduleNext() {
        if fetching {
            return
        }
        mainQueue.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let 🕑 = self?.lastFetchDate else {
                self?.scheduleForFetch()
                return
            }
            guard Date().isFetchDue(since: 🕑) else {
                self?.scheduleNext()
                return
            }
            self?.scheduleForFetch()
        }
    }
    
    private func scheduleForFetch() {
        fetchNext()
    }
    
    private func fetchNext() {
        if fetching {
            return
        }
        fetching = true
        fetchQueue.async { [weak self] in
            self?.fetchOneline { oneline in
                self?.mainQueue.async { [weak self] in
                    self?.fetching = false
                    self?.lastFetchDate = Date()
                    self?.scheduleNext()
                    self?.set(oneliner: oneline)
                }
            }
        }
    }

    @objc func onVideoReachedEnd(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.videoLayer?.player?.currentItem)
        if index == files.count - 1 {
            index = 0
        } else {
            index += 1
        }
        let path = files[index]

        if !FileManager.default.fileExists(atPath: path) {
            guard let item = notification.object as? AVPlayerItem else {
                return
            }
            item.seek(to: CMTime.zero)
        } else {
            let item = AVPlayerItem(url: URL(fileURLWithPath: path))
            videoLayer?.player = AVPlayer(playerItem: item)
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onVideoReachedEnd(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: videoLayer?.player?.currentItem
        )
        addFadeToPlayer()
        videoLayer?.player?.play()
        
    }
    
    private func addFadeToPlayer() {
        if files.count <= 1 {
            return
        }
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.8, preferredTimescale: timeScale)

        videoLayer?.player?.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { [weak self] time in
            let seconds = time.seconds
            let total = self?.videoLayer?.player?.currentItem?.duration.seconds ?? seconds + 1
            if total - seconds  < 1 && !(self?.fading ?? true) {
                self?.fading = true
                CATransaction.begin()
                let fade = CABasicAnimation()
                fade.keyPath = "opacity"
                fade.fromValue = 1
                fade.toValue = 0
                fade.beginTime = CACurrentMediaTime()
                fade.duration = 1
                fade.autoreverses = true
                fade.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                fade.fillMode = .forwards
                
                CATransaction.setCompletionBlock {
                    self?.videoLayer?.removeAllAnimations()
                    self?.fading = false
                }
                self?.videoLayer?.add(fade, forKey: "faded")
                CATransaction.commit()
            }
        })
        
    }
    
    override open func removeFromSuperview() {
        self.videoLayer?.player?.pause()
        NotificationCenter.default.removeObserver(self)
        self.fetching = false
        super.removeFromSuperview()
    }
}
