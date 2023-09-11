//
//  AltitudeRangeView.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/11/23.
//

import Foundation
import SwiftUI

// N.B. Assumption with padding is that view exists in a specific aspect ratio (maybe enforce this within view)
// From a proportional perspective: top / bottom bars should be 50% of the height. (Encode this)
struct AltitudeRangeView: View {
    @ObservedObject var viewModel: AltitudeRangeViewModel
    
    var body: some View {
        Canvas { context, size in
            let frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            viewModel.drawRangeDisplay(context: &context, rect: frame)
        }
        .border(Color.red)
        .background(.black)
        .foregroundColor(.white)
    }
}

struct AltitudeRangeView_Preview: PreviewProvider {
    struct PreviewView: View {
        @StateObject var viewModel: AltitudeRangeViewModel = AltitudeRangeViewModel()
        
        var body: some View {
            AltitudeRangeView(viewModel: viewModel)
                .frame(width: 200, height: 400)
                .onAppear {
                    viewModel.max = 8238
                }
                .onTapGesture {
                    let a = CGFloat(Int.random(in: 100...1000))
                    let b = CGFloat(Int.random(in: 100...1000))
                    
                    viewModel.max = max(a,b)
                    viewModel.min = min(a,b)
                    viewModel.current = CGFloat(Int.random(in: Int(viewModel.min!)...Int(viewModel.max!)))
                }
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}
