import CoreLocation // 위치 정보를 다루는 애플 프레임워크
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // CLLocationManagerDelegate: 위치 이벤트(권한 변경, 위치 업데이트 등)를 받는 프로토콜
    
    private let manager = CLLocationManager() // 실제 위치를 가져오는 객체
    
    @Published var lastLocation: CLLocation? = nil // 가장 최근 위치 저장
    
    override init() {
        super.init()
        manager.delegate = self              // 이벤트를 이 클래스가 받도록 등록
        manager.desiredAccuracy = kCLLocationAccuracyBest // 최대한 정확한 위치 요청
        manager.requestWhenInUseAuthorization() // 권한 요청 팝업 띄우기
        manager.startUpdatingLocation()      // 위치 업데이트 시작
    }
    
    // 위치가 업데이트될 때마다 호출됨
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last // 가장 최근 위치를 저장
    }
}
