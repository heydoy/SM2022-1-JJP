//
//  ViewController.swift
//  CVD19
//
//  Created by Doy Kim on 2022/03/20.
//

import UIKit
import Charts
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var newCaseLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCVDOverview(completionHandler: { [weak self] result in
            // 순환참조를 방지하기 위해 [weak self] capturelist를 정의해줌
            guard let self = self else { return } // 일시적으로 self가 strong reference로 만들게 하는 작업
            switch result {
            case let .success(result) :
                //debugPrint("success \(result)")
                self.configureStackView(koreaCVDOverview: result.korea)
                let covidOverviewList = self.makeCovidOverViewList(cityCVDOverview: result)
                self.configureChartView(covidOverViewList: covidOverviewList)
                
            case let .failure(error) :
                debugPrint("error \(error)")
            }
        })
    }
    
    func makeCovidOverViewList( cityCVDOverview: CityCVDOverview ) -> [CVDOverView] {
        // JSON 응답이 배열이 아니라 하나의 객체로 오기 때문에
        return [
            cityCVDOverview.seoul,
            cityCVDOverview.busan,
            cityCVDOverview.daegu,
            cityCVDOverview.incheon,
            cityCVDOverview.gwangju,
            cityCVDOverview.daejeon,
            cityCVDOverview.ulsan,
            cityCVDOverview.sejong,
            cityCVDOverview.gyeonggi,
            cityCVDOverview.chungbuk,
            cityCVDOverview.chungnam,
            cityCVDOverview.gyeongbuk,
            cityCVDOverview.gyeongnam,
            cityCVDOverview.jeju
        ]
    }
    
    // 파이차트 세팅해주는 메서드
    func configureChartView(covidOverViewList: [CVDOverView]) {
        // 상세화면으로 연결되도록
        self.pieChartView.delegate = self
        // 전달받은 배열을 파이차트 데이터 엔트리 객체로 맵핑시켜주는 코드
        let entries = covidOverViewList.compactMap { [weak self] overview -> PieChartDataEntry? in
            guard let self = self else { return nil }
            // 신규확진자가 차트의 갑,
            return PieChartDataEntry(
                value: self.removeFormatString(string: overview.newCase),
                label: overview.countryName,
                data: overview ) // data에 overview를 넣어서 상세데이터를 넣어줌.
        }
        let dataSet = PieChartDataSet(entries: entries, label: "코로나19 발생현황") // 데이터 묶어주기
        // 차트 스타일링
        dataSet.sliceSpace = 1
        dataSet.entryLabelColor = .black
        dataSet.valueTextColor = .black
        dataSet.xValuePosition = .outsideSlice // 항목이름 바깥쪽에
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.3
        dataSet.colors = ChartColorTemplates.vordiplom() + ChartColorTemplates.joyful() +
        ChartColorTemplates.liberty() + ChartColorTemplates.pastel() + ChartColorTemplates.material()
        // 데이터 차트뷰에 세팅
        self.pieChartView.data = PieChartData(dataSet: dataSet)
        // 파이차트 회전
        self.pieChartView.spin(duration: 0.3, fromAngle: self.pieChartView.rotationAngle, toAngle: self.pieChartView.rotationAngle + 80)
    }
    
    // 숫자가 세자리마자 콤마가 있는 String형이므로 이걸 Double로 바꿔주는 메서드
    func removeFormatString(string: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)?.doubleValue ?? 0
    }
    
    
    
    // 레이블 값 세팅.
    func configureStackView( koreaCVDOverview: CVDOverView ){
        self.totalCaseLabel.text = "\(koreaCVDOverview.totalCase) 명"
        self.newCaseLabel.text = "\(koreaCVDOverview.newCase) 명"
    }
    
    
    func fetchCVDOverview(
        completionHandler: @escaping (Result<CityCVDOverview, Error>) -> Void
    ) {
        // 메소드 파라미터를 completionHandler 클로저를 전달받게 정의함. API가 요청에 성공, 실패하였을 때 응답받은 데이터를 전달함. Result에서 첫번째 제너릭은 요청에 성공했을 때, 두번째 제너릭은 요청에 실패했을 때 Error객체, Void로 반환값이 없음을 명시해줌.
        // 여기의 completionHandler를 escaping closure로 선언할 것. 클로저가 함수로 Escape. 함수의 인자로 클로저가 전달되지만 함수가 반환된 후에도 실행되는 것을 의미
        // 즉 함수의 인자가 함수밖을 탈출하여 실행된다는 뜻. 비동기 작업을 하는 경우 컴플리션 핸들러로 escaping closure를 많이 사용.
        
        // 시도별발생동향 요청하는 주소 Url
        let url = "https://api.corona-19.kr/korea/country/new/"
        // 딕셔너리를 대입해줄 상수 param (발급받은 API키, 보안을 위해서 배포 시에는 키를 따로 관리해야한다. 현재는 실습이므로 인코드 삽입)
        let param = [
            // API 키, 보안을 위해 삭제 후 깃 업로드
            "serviceKey": ""
        ]
        
        // GET 방식 요청. 딕셔너리 형태로 파라미터에 전달하면 알아서 query parameter를 url 뒤에 추가해준다.
        AF.request(url, method: .get, parameters: param)
        // Request 메소드를 이용하여 api를 호출하였으면 응답이터를 받을 수 있는 메소드를 체이닝 해주어야함. completion 핸들러 클로저를 정의해주면 응답데이터가 클로저 파라미터로 전달됨.
            .responseData(completionHandler: { response in
                switch response.result {
                    // 열거형이므로 switch문으로 작성
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(CityCVDOverview.self, from: data)
                        // fetchCVDOverview() 메서드에 있는 completionHandler를 호출해줄 것
                        completionHandler(.success(result))
                    } catch {
                        // 만약 JSON 객체가 CityCVDOverview 형태로 맵핑되는 것이 실패할 경우 catch구문이 실행됨
                        completionHandler(.failure(error))
                    }
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            })
        
    }
}

// 차트항목을 선택하였을 때
extension ViewController : ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let covidDetailViewController =  self.storyboard?.instantiateViewController(identifier:  "CVD19DetailViewController") as CVD19DetailViewController? else { return }
        
        guard let covidOverview = entry.data as? CVDOverView else { return }
        covidDetailViewController.covidOverview = covidOverview
        self.navigationController?.pushViewController(covidDetailViewController, animated: true)
    }
}
