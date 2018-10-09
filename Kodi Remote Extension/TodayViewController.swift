//
//  TodayViewController.swift
//  Kodi Remote Extension
//
//  Created by Sylvain Roux on 2018-10-07.
//  Copyright © 2018 Sylvain Roux. All rights reserved.
//

import Cocoa
import NotificationCenter
import SocketRocket


class TodayViewController: NSViewController, NCWidgetProviding, SRWebSocketDelegate {
    var socket: SRWebSocket?
    var hostAddress: String? = "192.168.0.102"
    var hostPort: String? = "9090"
    var hostUsername: String? = ""
    var hostPassword: String? = ""
    var switchingItemInPlaylist = false
    var currentItemPositionInPlaylist: Int = -1
    var playerId = PlayerId.none
    var applicationVolume: Float = 0.0 { didSet { self.volumeSlider?.floatValue = self.applicationVolume } }
    var lastRequestDate: Date?
    var lastRequestString: String?
    var isHeartbeating: Bool = false
    var playerItemCurrentTime = PlayerItemTime(hours: 0, minutes: 0, seconds: 0)
    var playerItemTotalTime = PlayerItemTime(hours: 0, minutes: 0, seconds: 0)
    var playerItemCurrentTimePercentage: Int = 0
    var playerSpeed: Int = 0
    var isPlayerOn: Bool = false
    var isPlaying: Bool = false
    var playlistItems = [PlaylistItem]()
    
    @IBOutlet var volumeSlider: NSSlider?
    
    override var nibName: NSNib.Name? { return NSNib.Name("TodayViewController") }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.noData)
    }
    
    override func viewDidLoad() {
        self.connectToKodi()
    }
    
    func connectToKodi() {
        if self.socket != nil, self.socket!.readyState == SRReadyState.OPEN {
            self.socket!.close()
        }
        let shared = UserDefaults.standard
        if self.hostAddress == nil {
            self.hostAddress = shared.object(forKey: "host") as? String
        }
        if self.hostPort == nil {
            self.hostPort = shared.object(forKey: "hostPort") as? String
        }
        if self.hostUsername == nil {
            self.hostUsername = shared.object(forKey: "username") as? String
        }
        if self.hostPassword == nil {
            self.hostPassword = shared.object(forKey: "password") as? String
        }
        var stringURL: String
        if (self.hostUsername == "") {
            stringURL = "ws://\(self.hostAddress ?? ""):\(self.hostPort ?? "")/jsonrpc"
        } else {
            stringURL = "ws://\(self.hostUsername ?? ""):\(self.hostPassword ?? "")@\(self.hostAddress ?? ""):\(self.hostPort ?? "")/jsonrpc"
        }
        if let anURL = URL(string: stringURL) {
            self.socket = SRWebSocket(urlRequest: URLRequest(url: anURL))
        }
        socket!.delegate = self
        print("Socket event : Atempting to connect to host at \(self.hostAddress ?? "MISSING ADDRESS"):\(self.hostPort ?? "MISSING PORT")")
        self.socket!.open()
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print("Connected to Kodi")
        self.playerHeartbeat()
    }

    func webSocket(_ webSocket: SRWebSocket?, didReceiveMessage message: Any!) {
        print(message)
        
        if let anEncoding = (message as! String).data(using: String.Encoding.utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: anEncoding, options: []) as! [String: Any] {
            var data = [String: Any]()
            if let params = (jsonObject["params"] as? [String: Any]) {
                if var dataParsing = params["data"] as? [String: Any]? {
                    data = dataParsing!
                }
            }
            
            if let requestId = jsonObject["id"] as! Int? {
                switch requestId {
//                    case 1:
//                        handlePlayerGetPropertiesPercentageSpeed(data)
//                    case 2:
//                        handleApplicationVolume(data)
//                    case 3:
//                        handlePlaylistGetItems(data)
//                    case 4:
//                        handlePlayerGetItem(data)
//                    case 5:
//                        handlePlayerGetActivePlayers(data)
//                    case 6:
//                        handlePlayerGetPropertiesPlaylistPosition(data)
                    default:
                        break
                }
            }
            else if let requestMethod = jsonObject["method"] as! String? {
                switch requestMethod {
                case "Application.OnVolumeChanged":
//                    handleApplicationVolume(data)
                    break
                default: break
                }
            }
        }
    }
}


// MARK: Response handlers
extension TodayViewController {
//    func handleApplicationVolume(_ params: [String: Any]?) {
//        //Response to Application.GetProperties
//        self.applicationVolume = params!["volume"] as! Float? ?? 0.0
//    }
//    func handlePlayerGetPropertiesPercentageSpeed(_ params: [String: Any]?) {
//        //Response to Player.GetProperties Percentage Speed
//        let time = params!["time"] as! [String: Any]
//        let totalTime = params!["totaltime"] as! [String: Any]
//        self.playerItemCurrentTime.hours = time["hours"] as! Int
//        self.playerItemCurrentTime.minutes = time["minutes"] as! Int
//        self.playerItemCurrentTime.seconds = time["seconds"] as! Int
//        self.playerItemTotalTime.hours = totalTime["hours"] as! Int
//        self.playerItemTotalTime.minutes = totalTime["minutes"] as! Int
//        self.playerItemTotalTime.seconds = totalTime["seconds"] as! Int
//        self.playerItemCurrentTimePercentage = params!["percentage"] as! Int
//        self.playerSpeed = params!["speed"] as! Int
//    }
//    func handlePlayerGetPropertiesPlaylistPosition(_ params: [String: Any]?) {
//        self.currentItemPositionInPlaylist = params!["position"] as! Int
//        self.requestPlayerGetItem()
//    }
//    func handlePlayerGetItem(_ params: [String: Any]?) {
//        let item = params!["item"] as? [String: Any]
//        let itemLabel = item!["label"] as? String
////        setTitle(itemLabel, forItemAtIndex: currentItemPositionInPlaylist)
////        playlistItems = playlistItems
//    }
//    func handlePlayerGetActivePlayers(_ params: [String: Any]?) {
//        //Stop heartbeat if no active players
//        if params?.count == 0 {
//            self.playerId = .none
//            self.isPlayerOn = false
//        } else {
//            let oldPlayerId = self.playerId
//            self.playerId = PlayerId(rawValue: params?["playerid"] as! Int) ?? .none
//            self.isPlayerOn = true
//            if self.playerId != oldPlayerId {
//                self.requestPlaylistGetItems()
//            }
//        }
//    }
//    func handlePlayer(onPlay params: [String: Any]?) {
//        self.isPlayerOn = true
//        self.isPlaying = true
//        switchingItemInPlaylist = false
//        requestPlayerGetItem()
//    }
//    func handlePlayerOnPause() {
//        self.isPlaying = false
//    }
//    func handlePlayer(onStop params: [String: Any]?) {
//        self.isPlayerOn = false
//        self.isPlaying = false
//        self.currentItemPositionInPlaylist = -1
//    }
//    func handlePlaylistGetItems(_ params: [String: Any]?) {
//        var itemIndex: Int = -1
//        for jsonPlaylistItem: [AnyHashable : Any] in params!["items"] as! [Any] as? [[AnyHashable : Any]] ?? [] {
//            itemIndex += 1
//            let itemLabel = jsonPlaylistItem["label"] as? String
//            //If the item is not already in the playlist
//            if self.playlistItems.count > itemIndex {
////                setTitle(itemLabel, forItemAt: itemIndex)
//            } else {
////                addItem(withTitle: itemLabel ?? "")
//            }
//        }
//        //Update object
////        self.playlistItems = playlistItems
//        self.requestPlayerGetPropertiesPlaylistPosition()
//    }
//    func handlePlaylistOnClear() {
//        print("handlePlaylistOnClear")
//    }
//    func handlePlaylist(onAdd params: [String: Any]?) {
//        let item = (params!["data"] as! [String: Any])["item"] as! [String: Any]
//        let itemTitle = item["title"] as? String
////        addItem(withTitle: itemTitle ?? "")
//    }
//    func handleInput(onInputRequested params: [String: Any]?) {
//        //UI update
////        self.keyboardBehaviour = TEXT_INPUT
////        ui_enableNavigationControls(false)
////        xib_textView.hidden = false
////        view.window.makeFirstResponder(xib_inputTextToKodiTextField)
////        xib_playerView.hidden = true
//    }
//    func handleInputOnInputFinished() {
////        //UI update
////        self.keyboardBehaviour = COMMAND
////        ui_enableNavigationControls(true)
////        view.window.makeFirstResponder(view)
////        xib_textView.hidden = true
////        xib_playerView.hidden = false
//    }
//    func handleGUIOnScreenSaverDeactivated() {
////        if self.lastRequestDate && Date().timeIntervalSince(self.lastRequestDate) < 2 && !self.lastRequestString.contains("Player.Open") && !self.lastRequestString.contains("Playlist.Add") {
////            requestLastRequest()
////        }
//    }
}

// MARK: Requests to Kodi
extension TodayViewController {
    func remoteRequest(_ request: String?) {
        if self.socket != nil {
            if self.socket!.readyState == SRReadyState.CLOSED {
                self.connectToKodi()
            } else if self.socket!.readyState == SRReadyState.OPEN {
                self.lastRequestDate = Date()
                self.lastRequestString = request ?? ""
                self.socket!.send(request)
            }
        }
    }

    func sendInputDown() {
        //Input.Down
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.Down\"}"
        self.remoteRequest(request)
    }
    func sendInputLeft() {
        //Input.Left
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.Left\"}"
        self.remoteRequest(request)
    }
    func sendInputRight() {
        //Input.Right
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.Right\"}"
        self.remoteRequest(request)
    }
    func sendInputUp() {
        //Input.Up
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.Up\"}"
        self.remoteRequest(request)
    }
    func sendInputSelect() {
        //Input.Select
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.Select\"}"
        self.remoteRequest(request)
    }
    func sendInputExecuteActionBack() {
        //Input.ExecuteAction back
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.ExecuteAction\",\"params\":{\"action\":\"back\"}}"
        self.remoteRequest(request)
    }
    func sendInputExecuteActionContextMenu() {
        //Input.ExecuteAction contextmenu
        //Input.ShowOSD
        var request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.ExecuteAction\",\"params\":{\"action\":\"contextmenu\"},\"id\":0}"
        self.remoteRequest(request)
        request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.ShowOSD\"}"
        self.remoteRequest(request)
    }
    func sendInputInfo() {
        //Input.Info
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.Info\"}"
        self.remoteRequest(request)
    }
    func sendInputHome() {
        //Input.Home
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.Home\"}"
        remoteRequest(request)
    }
    func sendInputExecuteActionPause() {
        //Input.ExecuteAction pause
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.ExecuteAction\",\"params\":{\"action\":\"pause\"}}"
        self.remoteRequest(request)
    }
    func sendInputExecuteActionStop() {
        //Input.ExecuteAction stop
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.ExecuteAction\",\"params\":{\"action\":\"stop\"}}"
        self.remoteRequest(request)
    }
    func sendApplicationSetVolume(_ volume: Int) {
        //Application.SetVolume
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Application.SetVolume\",\"params\":{\"volume\":%i}}", volume)
        self.remoteRequest(request)
    }
    func sendApplicationSetVolumeIncrement() {
        //Application.SetVolume applicationVolume+5
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Application.SetVolume\",\"params\":{\"volume\":%i}}", Int(applicationVolume) + 5)
        self.remoteRequest(request)
    }
    func sendApplicationSetVolumeDecrement() {
        //Application.SetVolume self.applicationVolume-5
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Application.SetVolume\",\"params\":{\"volume\":%i}}", Int(applicationVolume) - 5)
        self.remoteRequest(request)
    }
    func sendPlayerOpenVideo() {
        //Player.Open
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Player.Open\",\"params\":{\"item\":{\"playlistid\":1}}}"
        self.remoteRequest(request)
    }
    func sendPlaylistAddVideoStreamLink(_ link: String?) {
        //Playlist.Add
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Playlist.Add\",\"params\":{\"playlistid\":1, \"item\":{\"file\":\"\(link ?? "")\"}}}"
        self.remoteRequest(request)
    }
    func sendPlaylistClearVideo() {
        //Playlist.Clear
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Playlist.Clear\",\"params\":{\"playlistid\":1}}"
        self.remoteRequest(request)
    }
    func sendPlayerSeek(_ percentage: Int) {
        //Player.Seek
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Player.Seek\",\"params\":{\"playerid\":%ld,\"value\":%i}}", self.playerId.rawValue, percentage)
        self.remoteRequest(request)
    }
    func sendPlayerSeekForward() {
        //Player.Seek
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Player.Seek\",\"params\":{\"playerid\":%ld,\"value\":\"smallforward\"}}", self.playerId.rawValue)
        self.remoteRequest(request)
    }
    func sendPlayerSeekBackward() {
        //Player.Seek
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Player.Seek\",\"params\":{\"playerid\":%ld,\"value\":\"smallbackward\"}}", self.playerId.rawValue)
        self.remoteRequest(request)
    }
    func sendPlayerSetSpeed(_ speed: Int) {
        //Player.SetSpeed
        var lc_speed: Int
        if speed == 0 {
            lc_speed = 0
        } else {
            lc_speed = Int(truncating: NSDecimalNumber(decimal: (pow(2, abs(speed))))) * (speed / abs(speed)) //[1]=2 [2]=4 [3]=8 [4]=16 [5]=32
        }
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Player.SetSpeed\",\"params\":{\"playerid\":%ld,\"speed\":%i}}", self.playerId.rawValue, lc_speed)
        self.remoteRequest(request)
    }
    func sendPlayerGoToPrevious() {
        //Player.GoTo
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Player.GoTo\",\"params\":{\"playerid\":%ld,\"to\":\"previous\"}}", self.playerId.rawValue)
        self.remoteRequest(request)
    }
    func sendPlayerGoToNext() {
        //Player.GoTo
        if switchingItemInPlaylist {
            return
        }
        switchingItemInPlaylist = true
        currentItemPositionInPlaylist += 1
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Player.GoTo\",\"params\":{\"playerid\":%ld,\"to\":\"next\"}}", self.playerId.rawValue)
        self.remoteRequest(request)
    }
    func sendPlayerGo(to playlistItemId: Int) {
        //Player.GoTo
        if switchingItemInPlaylist {
            return
        }
        switchingItemInPlaylist = true
        if currentItemPositionInPlaylist == playlistItemId {
            switchingItemInPlaylist = false
            return
        }
        currentItemPositionInPlaylist = playlistItemId
        let request = String(format: "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Player.GoTo\",\"params\":{\"playerid\":%ld,\"to\":%d}}", self.playerId.rawValue, Int(currentItemPositionInPlaylist))
        self.remoteRequest(request)
    }
    func sendSystemReboot() {
        //System.Reboot
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"System.Reboot\"}"
        self.remoteRequest(request)
    }
    func sendVideoLibraryScan() {
        //VideoLibrary.Scan
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"VideoLibrary.Scan\"}"
        self.remoteRequest(request)
    }
    func sendInputSendText(_ string: String?, andSubmit submit: Bool) {
        //Input.SendText
        var done: String
        let safeString = string?.replacingOccurrences(of: "\"", with: "\\\"")
        if submit {
            done = "true"
        } else {
            done = "false"
        }
        let request = "{\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"Input.SendText\",\"params\":{\"text\":\"\(safeString ?? "")\",\"done\":\(done)}}"
        self.remoteRequest(request)
    }
    func requestApplicationVolume() {
        //Application.GetProperties
        let request = "{\"id\":2,\"jsonrpc\":\"2.0\",\"method\":\"Application.GetProperties\",\"params\":{\"properties\":[\"volume\"]}}"
        self.remoteRequest(request)
    }
    func requestPlayerGetPropertiesPercentageSpeed() {
        //Player.GetProperties
        if self.playerId == .none {
            return
        }
        let request = String(format: "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"Player.GetProperties\",\"params\":{\"playerid\":%ld,\"properties\":[\"time\",\"totaltime\",\"percentage\",\"speed\"]}}", self.playerId.rawValue)
        self.remoteRequest(request)
    }
    func requestPlayerGetPropertiesPlaylistPosition() {
        //Player.GetProperties
        if self.playerId == .none {
            return
        }
        let request = String(format: "{\"id\":6,\"jsonrpc\":\"2.0\",\"method\":\"Player.GetProperties\",\"params\":{\"playerid\":%ld,\"properties\":[\"position\"]}}", self.playerId.rawValue)
        self.remoteRequest(request)
    }
    func requestPlayerGetItem() {
        //Player.GetItem
        let request = String(format: "{\"id\":4,\"jsonrpc\":\"2.0\",\"method\":\"Player.GetItem\",\"params\":{\"playerid\":%ld}}", self.playerId.rawValue)
        self.remoteRequest(request)
    }
    func requestPlaylistGetItems() {
        //Playlist.GetItems
        let request = String(format: "{\"id\":3,\"jsonrpc\":\"2.0\",\"method\":\"Playlist.GetItems\",\"params\":{\"playlistid\":%ld}}", self.playerId.rawValue)
        self.remoteRequest(request)
    }
    func requestPlayerGetActivePlayers() {
        //Player.GetActivePlayers
        let request = "{\"id\":5,\"jsonrpc\":\"2.0\",\"method\":\"Player.GetActivePlayers\"}"
        self.remoteRequest(request)
    }
}

// MARK: Application Inputs
extension TodayViewController {
    @IBAction func up(sender: NSButton) { self.sendInputUp() }
    @IBAction func down(sender: NSButton) { self.sendInputDown() }
    @IBAction func left(sender: NSButton) { self.sendInputLeft() }
    @IBAction func right(sender: NSButton) { self.sendInputRight() }
    @IBAction func select(sender: NSButton) { self.sendInputSelect() }
    @IBAction func home(sender: NSButton) { self.sendInputHome() }
    @IBAction func back(sender: NSButton) { self.sendInputExecuteActionBack() }
    @IBAction func info(sender: NSButton) { self.sendInputInfo() }
    @IBAction func menu(sender: NSButton) { self.sendInputExecuteActionContextMenu() }
    @IBAction func stop(sender: NSButton) { self.sendInputExecuteActionStop() }
    @IBAction func next(sender: NSButton) { self.sendPlayerGoToNext() }
    @IBAction func togglePause(sender: NSButton) { self.sendInputExecuteActionPause() }
    @IBAction func volume(slider: NSSlider) { self.sendApplicationSetVolume(Int(slider.intValue)) }
    @IBAction func speed(slider: NSSlider) {
        let event: NSEvent? = NSApplication.shared.currentEvent
        if event?.type == .leftMouseUp {
            slider.doubleValue = 0.0
        }
        self.sendPlayerSetSpeed(Int(slider.intValue))
    }
    @IBAction func progress(slider: NSSlider) { self.sendPlayerSetSpeed(Int(slider.intValue)) }
    
    @objc func playerHeartbeat() {
        requestPlayerGetPropertiesPercentageSpeed()
        requestPlayerGetActivePlayers()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.playerHeartbeat), userInfo: nil, repeats: false)
    }
}


// MARK: UI Updates
extension TodayViewController {
}


enum PlayerId: Int {
    case none = -1
    case audio = 0
    case video = 1
}

struct PlayerItemTime {
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    init(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
}
class PlaylistItem: NSObject {
    //* Title of the item
    private var _title = ""
    var title: String {
        get {
            var title: String? = nil
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                title = _title
            }
            return title!
        }
        set(title) {
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                if _title == "" {
                    _title = ""
                }
                if !(title == "") {
                    _title = title ?? ""
                }
            }
        }
    }
    init(title: String) {
        //if super.init()
        self._title = title
    }
}
