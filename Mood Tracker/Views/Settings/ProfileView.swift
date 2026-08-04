//
//  ProfileView.swift
//  Mood Tracker
//

import SwiftUI

enum Gender: String, CaseIterable, Identifiable {
    case female = "Female"
    case male = "Male"
    case nonBinary = "Non-binary"
    case preferNotToSay = "Prefer not to say"

    var id: String { rawValue }
}

struct ProfileView: View {
    @AppStorage("profileFirstName") private var firstName: String = ""
    @AppStorage("profileLastName") private var lastName: String = ""
    @AppStorage("profileGender") private var genderRaw: String = Gender.preferNotToSay.rawValue

    var body: some View {
        Form {
            Section("Name") {
                TextField("First name", text: $firstName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                TextField("Last name", text: $lastName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }

            Section("Gender") {
                Picker("Gender", selection: $genderRaw) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender.rawValue)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
