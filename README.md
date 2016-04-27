

![alt text](https://github.com/TeamYYZ/DineApp/blob/master/dine_logo.png "Dine")

Dine is a location based platform aiming to help you find lunch buddy and plan meals more easily.

Created as Codepath group project 2016 Spring iOS course at TAMU.

Video demo here: https://youtu.be/tjud1xvSTw4


# YYZ group Members
- You Wu
- Yi Huang
- Senyang Zhuang

# User Stories

## Short description of our app
- Get a lunch buddy in minutes with the “Dine” app
- Planning a meal? See your friends’ location and know when will everyone show up
- can’t decide where to go? Vote for it

## Required (core) user stories
- User can sign in using social media account / or create new Dine account

- User can browse nearby dine requests by map view or list view(categorised by restaurant name/ distance)

- User can choose to join a request, and send out the arrival time and meet-up location, the direction to the chosen restuarant is also shown

- User can create a request(time and restaurant) and post it

- User can create party group(restaurant, location, scheduled time will be visible to all group members), group members would get notifications from group owner in case there’s any changes. Groups can either be public or private, so that owner has control over who gets to see the request.

- Group owner can see group members’ location if the user allows it

- In user profile, there's a friend list and can add friends by searching their username


## Optional (nice to have) user stories
- Chat room for party group
- In user profile, there's a block list, such that every dining request I initiated will not be visible to him/her, and I will receive a notification if he/she enters the dining group that I am currently in.
- Group owner can start a voting on restaurant candidates, group members can vote
- Private messaging system
- User credibility system(if a user accept a request and never shows up, the credibility will decrease)
- The user can know how much money each needs to pay and tips as well


## Wireframe

![Alt text](/dine.png?raw=true "Wireframe")


## Data Schema
| Table name | Column name ||||||||
| ---------- | ----------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| User |	UID	username(screen name) |	first name |	last name	| password |	email |	dob	| gender	| profile description | friends array |
| Activity |	AID	| request poster username	| request time |	yelp business id |	description	| GID |		
| Group |	GID |owner(UID) | group members (UID array) |	chatroom table | members table		
| GroupMember |	UID	| current location |
| Invitation | IID | sender |	receivers(UID) | AID |			
| GroupChat | UID | time | message |

## Walkthrough
<img src='http://i.imgur.com/6VUvNaX.gif' title='Video Walkthrough' width='310' alt='Video Walkthrough' />

## Improvement
### High-performance UITableView

Our Chat view achieves around 60 FPS when populated more than 400 cells by using cached cell height and pre-computing cell height.

[![UITableView Video Demo](http://img.youtube.com/vi/6e5v3LYwCFs/0.jpg)](http://www.youtube.com/watch?v=6e5v3LYwCFs "Demo")

