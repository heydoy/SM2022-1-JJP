//
//  CityCVDOverview.swift
//  CVD19
//
//  Created by Doy Kim on 2022/03/20.
//

import Foundation
// API 응답형태인 JSON에서 시도명 키를 가진 객체 프로퍼티와 동일하게 구조체를 선언하기

struct CityCVDOverview: Codable {
    let korea: CVDOverView
    let seoul: CVDOverView
    let busan: CVDOverView
    let daegu: CVDOverView
    let incheon: CVDOverView
    let gwangju: CVDOverView
    let daejeon: CVDOverView
    let ulsan: CVDOverView
    let sejong: CVDOverView
    let gyeonggi: CVDOverView
    let gangwon: CVDOverView
    let chungbuk: CVDOverView
    let chungnam: CVDOverView
    let jeonbuk: CVDOverView
    let jeonnam: CVDOverView
    let gyeongbuk: CVDOverView
    let gyeongnam: CVDOverView
    let jeju: CVDOverView
    // 검역지역 데이터는 사용하지 않을 것이므로 선언하지 않음
}

struct CVDOverView: Codable {
    let countryName: String
    let newCase: String
    let totalCase: String
    let recovered: String
    let death: String
    let percentage: String
    let newCcase: String
    let newFcase: String
}

