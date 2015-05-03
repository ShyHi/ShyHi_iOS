# ShyHi_iOS

<p align="center">
  <img src="/images/shyhi_logo.png"/>
</p>

Location based anonymous messaging application. It's like heroin for your connectivity fix. Get frisky.
###How To Install
* You will need a Mac or a virtual machine of MAC OS X on your Windows machine
* Install Xcode 6.3 https://developer.apple.com/xcode/downloads/
* Set up Git

Cloning from the github repo:
* Find a location on your machine where you would like to house the project
* git clone https://github.com/ShyHi/ShyHi_iOS.git 

###Running Project in Xcode
  * Simply open ShyHi_iOS/ShyHi/ShyHi.xcodeproj
  * CMD + R will run the application, or you can select Product > Run

###Testing
* While in Xcode project, locate ShyHiTests.swift
* The tests are currently commented out to ensure application runs since Xcode 6.3 introduced many bugs for previously working versions
* To turn tests on, add ShyHiTests to target membership of NewChatViewController.swift in its settings (file inspector)
* uncomment code in ShyHiTests.swift
* CMD + U will run tests, or you can select Product > Test

<p align="center">
  <img src="/images/mockup1.png"/>
  <img src="/images/mockup2.png"/>
</p>
