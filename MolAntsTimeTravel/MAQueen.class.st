"
I'm the actual implementation of the queen role.
"
Class {
	#name : #MAQueen,
	#superclass : #MARole,
	#category : #MolAntsTimeTravel
}

{ #category : #'life cycle' }
MAQueen >> componentActivate [

	"--------------------------Time Travel--------------------------"
	"Subscription to the Time Travel event"
	self getTimeTravelEventsSubscriber subscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAQueen >> componentInitialize [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		"Connection to the TimeTravel service."
		self forServices: TimeTravelServices useProvider: #default.
		"Subscription to the Time Travel event"
		self getTimeTravelEventsSubscriber subscribe: self.
		self getTimeTravelServicesProvider isRestoring ifFalse: [
			"Component notifies its creation" 
			self getTimeTravelServicesProvider creationOf: self ] ].
	"---------------------------------------------------------------"
	
	"Initialization of the MAQueen component."

	self forServices: TMASimulationServices useProvider: #default.
	
	roleName := #queen.
	
	"--------------------------Time Travel--------------------------"
	self property: #roleName whenChangedDo: [ 
		(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
			self getTimeTravelServicesProvider isRestoring ifFalse: [ 
				self saveForTimeTravel ] ] ].
	"---------------------------------------------------------------"

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifFalse: [
			"Component saves its state."
			self saveForTimeTravel ] ].
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAQueen >> componentPassivate [
	
	"--------------------------Time Travel--------------------------"
	"Unsubscribe from the Time Travel event"
	self getTimeTravelEventsSubscriber unsubscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAQueen >> componentRemove [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifFalse: [
			"Component saves its state."
			self saveForTimeTravel.
			"Component notifies its deletion"
			self getTimeTravelServicesProvider deletionOf: self ] ].
	"---------------------------------------------------------------"
]

{ #category : #role }
MAQueen >> doSimulationStepFor: anAnt [

	"A queen as 25% of chance to laid at each step."

	(Random new nextIntegerBetween: 1 and: 4) = 1 ifTrue: [ 
		self getTMARoleEventsNotifier queenLaid ]
]

{ #category : #role }
MAQueen >> moveFrom: anAnt [

	"A queen don't move."

		^ anAnt getPosition.

]

{ #category : #events }
MAQueen >> restoreFrom: aMemento [

	
]

{ #category : #role }
MAQueen >> saveForTimeTravel [

	| memento |
	memento := MolQueenMemento new.

	self getTimeTravelServicesProvider
		save: (memento save: self)
]
