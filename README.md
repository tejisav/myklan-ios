# myKlan

A platform to manage families.

## About

myKlan is an iOS and android based family utility application which will help the families stay closer and connected in today’s busy life. Modern families are busier and often torn between work and family. myKlan is a family’s shared dashboard which helps to keep households organized by providing tools to manage everyday family life in one central location that can be accessed and updated by anyone in the family. myKlan brings all your family activities, tasks and data together in a single place. It will help the families by informing the whereabouts of every member, alarming when someone goes outside the preset distance, setting tasks for daily activities and storing important information.

This is the iOS App developed using :-
- Xcode 10.3
- Swift 5
- Alamofire
- SwiftyJSON
- GoogleSignIn
- SwiftKeychainWrapper

## Configuration

- First you need to setup the backend. So go to https://github.com/tejisav/myklan-backend/ and read the instructions to setup
- After successfully setting up backend make sure you replace all the API URL which is currently https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/ with your new one.
- You also need to integrate Google OAuth Client ID using this guide https://developers.google.com/identity/sign-in/ios/start-integrating#get_an_oauth_client_id and also make sure to replace the client id in AppDelegate.swift, currently it is 354641100294-vuv9ou3p73kalgb2jba06mgjnaptsuv2.apps.googleusercontent.com

Note: Currently API and OAuth Client ID used in the project are functional but if they are not follow the above steps to configure.

## Requirements
- Developer account and iOS device for push notifications.

## Website
Visit https://myklan.ca/ for more information
