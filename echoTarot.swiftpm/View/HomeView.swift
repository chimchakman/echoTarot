//
//  HomeView.swift
//  echoTarot
//
//  Created by Sunghyun Kim on 2/18/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                Image("homeText")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 40)
                    .padding(.top, 70)
                Spacer()
            }
            VStack {
                Spacer()
                Image("table")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 30)
                    .padding(.bottom, 60)
            }
        }
    }
}
