import MultipeerConnectivity // 근거리 기기 간의 통신을 가능하게 해줌(인터넷 연결X, 와이파이 & 블루투스 사용)
import Combine // @Published 사용하기 위해 선언

class MultipeerManager: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    // NSOject: Delegate가 필요로 함
    @Published var isConnected: Bool = false // 5. 연결 상태 변수
    @Published var receivedMessage: String = "" // 11. 받은 텍스트 저장하는 변수
    @Published var receivedLearner: Learner? = nil // 12. 받은 러너 정보 저장하는 변수
    
    var myPeerID: MCPeerID // 1. 기기의 이름표
    var mySession: MCSession // 2. 기기들이 모여서 대화하는 채널 -> 같은 채널에 있는 기기끼리만 통신 가능
    var advertiser: MCNearbyServiceAdvertiser // 3. 연결을 기다리는 쪽
    var browser: MCNearbyServiceBrowser // 4. 연결을 요청하는 쪽
    
    
    override init() { // 6. init으로 초기화
        myPeerID = MCPeerID(displayName: "Ian")
        mySession = MCSession(peer: myPeerID)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: "ada-card-swap")
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "ada-card-swap")
        
        super.init() // 부모 초기화
        
        mySession.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
    }
    
    func sendMessage(_ message: String) { // 11. 텍스트 보내는 함수
        if let data = message.data(using: .utf8) {
            try? mySession.send(data, toPeers: mySession.connectedPeers, with: .reliable) // try?: send 실패해도 nil로 반환하고 계속 실행
        }
    }
    
    func sendLearner(_ learner: Learner) { // 11. 러너 정보 보내는 함수
        if let data = try? JSONEncoder().encode(learner) {
            try? mySession.send(data, toPeers: mySession.connectedPeers, with: .reliable)
        }
    }
    
    func startAdvertising() { // 7. 기기 광고 시작
        advertiser.startAdvertisingPeer()
    }
    
    func startBrowsing() { // 7.  기기 찾기 시작
        browser.startBrowsingForPeers()
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) { // 8. 연결 상태가 바뀔 때 호출됨
        switch state {
        case .connected: // 연결됐을 때
            DispatchQueue.main.async {
                self.isConnected = true
            }
        case .notConnected: // 연결되지 않았을 때
            DispatchQueue.main.async {
                self.isConnected = false
            }
        default:
            break
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) { // String으로만 디코딩 시도 ->
        if let learner = try? JSONDecoder().decode(Learner.self, from: data) {
            DispatchQueue.main.async {
                self.receivedLearner = learner
            }
        } else if let message = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.receivedMessage = message
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { // 사용하지 않지만 선언은 해둠
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { // 사용하지 않지만 선언은 해둠
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) { // 사용하지 않지만 선언은 해둠
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mySession)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) { // 8. 주변 기기 발견됐을 때 호출
        browser.invitePeer(peerID, to: mySession, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) { // 8. 발견했던 기기가 사라졌을 때
    }
}

