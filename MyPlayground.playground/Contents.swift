import UIKit
import RxSwift
import Foundation
import XCTest
//let disposeBag = DisposeBag()
//var b = [1,2,3]
//let aString = Observable.of(b)
//
//aString.map{value in
//    return value
//    }.subscribe(onNext:{
//        print($0)
//    }).disposed(by: disposeBag)
//
//DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//    b.append(2)
//    print("s")
//}
class xx :XCTestCase{
    let numbers = [1.2, 2.5, 3.1, 4,2,2,2,2,22,2,2,2,2,2,2,2,2,2,2,2,2]
    
    func testt(){
        measure {
            let numberSum = numbers.reduce(0, { x, y in
                
                return x + y
            })
           // print(numberSum)
        }
    }
    func testt2(){
        measure {
            var totalCost:Double = 0
            numbers.forEach{
                totalCost += $0
            }
           //print(totalCost)

        }
    }
   
}
xx.defaultTestSuite.run()




