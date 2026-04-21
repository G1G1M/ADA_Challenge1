import MultipeerConnectivity // 근거리 기기 간의 통신을 가능하게 해줌(인터넷 연결X, 와이파이 & 블루투스 사용)
import Combine // @Published 사용하기 위해 선언

@MainActor // 모든 프로퍼티와 함수가 자동으로 메인 스레드에서 실행
class MultipeerManager: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    // NSObject: Objective-C 기반 Delegate 프로토콜이 필요로 함
    
    @Published var isConnected: Bool = false        // 연결 상태 변수
    @Published var receivedMessage: String = ""     // 받은 텍스트 저장 변수
    @Published var receivedLearner: LearnerTransfer? = nil // 받은 러너 정보 저장 변수
    
    var myPeerID: MCPeerID      // 기기의 이름표
    var mySession: MCSession    // 기기들이 통신하는 채널 (같은 채널 안에 있는 기기끼리만 통신 가능)
    var advertiser: MCNearbyServiceAdvertiser // 연결을 기다리는 쪽 (광고)
    var browser: MCNearbyServiceBrowser       // 연결을 요청하는 쪽 (탐색)
    
    override init() {
        myPeerID = MCPeerID(displayName: "Ian")  // 이 기기의 이름 설정
        mySession = MCSession(peer: myPeerID)    // 세션 생성
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: "ada-card-swap") // 광고자 생성
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "ada-card-swap") // 탐색자 생성
        
        super.init() // NSObject 초기화
        
        // Delegate 연결 (각 이벤트 발생 시 이 클래스가 처리하도록 등록)
        mySession.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }
    
    // MARK: - 데이터 전송
    
    func sendMessage(_ message: String) { // 텍스트 전송
        if let data = message.data(using: .utf8) {
            try? mySession.send(data, toPeers: mySession.connectedPeers, with: .reliable)
            // try?: 전송 실패해도 nil 반환 후 계속 실행 / .reliable: 데이터 손실 없이 전송 보장
        }
    }
    
    func sendLearner(_ learner: LearnerTransfer) { // 러너 정보 전송
        if let data = try? JSONEncoder().encode(learner) { // LearnerTransfer → JSON Data 변환
            try? mySession.send(data, toPeers: mySession.connectedPeers, with: .reliable)
        }
    }
    
    // MARK: - 광고 & 탐색 시작
    
    func startAdvertising() { // 내 기기를 주변에 알리기 시작
        advertiser.startAdvertisingPeer()
    }
    
    func startBrowsing() { // 주변 기기 탐색 시작
        browser.startBrowsingForPeers()
    }
    
    // MARK: - MCSessionDelegate
    
    // 연결 상태가 바뀔 때 호출 (MultipeerConnectivity가 백그라운드 스레드에서 호출)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Task로 감싸서 @MainActor(메인 스레드)에서 @Published 업데이트
        Task {
            switch state {
            case .connected:    // 연결 성공
                self.isConnected = true
            case .notConnected: // 연결 끊김
                self.isConnected = false
            default:
                break
            }
        }
    }
    
    // 데이터를 받았을 때 호출 (MultipeerConnectivity가 백그라운드 스레드에서 호출)
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Task로 감싸서 @MainActor(메인 스레드)에서 @Published 업데이트
        Task {
            if let learner = try? JSONDecoder().decode(LearnerTransfer.self, from: data) {
                // JSON Data → LearnerTransfer 디코딩 성공 시
                self.receivedLearner = learner
            } else if let message = String(data: data, encoding: .utf8) {
                // 일반 텍스트 디코딩 성공 시
                self.receivedMessage = message
            }
        }
    }
    
    // 아래 3개는 프로토콜 필수 구현 항목 (현재 미사용)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) { }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    
    // 초대 받으면 자동으로 수락
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mySession) // true: 수락 / mySession: 연결할 세션 전달
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    
    // 주변 기기 발견 시 자동으로 초대
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: mySession, withContext: nil, timeout: 10) // 10초 안에 응답 없으면 초대 취소
    }
    
    // 발견했던 기기가 사라졌을 때 (현재 미사용)
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) { }
    
    func stopDiscovery() { // 새로운 연결만 차단, 기존 세션은 유지
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }
}
