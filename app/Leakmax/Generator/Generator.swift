//
//  Leakmax
//
//  Created by Ondrej Macoszek on 08/02/2019.
//  Copyright © 2019 com.showmax. All rights reserved.
//

import Foundation

protocol GeneratorDelegate: class {
    func didGenerate(number: Int)
}

class Generator {

    var delegate: GeneratorDelegate // to prevent leak, change this to weak

    init(delegate: GeneratorDelegate) {
        self.delegate = delegate
    }

    func generate() {
        let number = Int.random(in: 0..<100)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.delegate.didGenerate(number: number)
        }
    }
}
