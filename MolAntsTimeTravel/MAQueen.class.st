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

	self getTMATimeTravelEventsSubscriber subscribe: self
]

{ #category : #'life cycle' }
MAQueen >> componentInitialize [

	"Initialization of the MAQueen component."

	roleName := #queen.

	self forServices: TMATimeTravelServices useProvider: #TimeTravel.

	self forServices: TMASimulationServices useProvider: #default.

 "queen notify the creation"
	(MolUtils instanceOf: MATimeTravel named: #TimeTravel) ifNotNil: [ 
	self getTMATimeTravelServicesProvider isRestoring ifFalse: [
		self getTMATimeTravelServicesProvider
			creationOf: self
			at: self getTMASimulationServicesProvider getStep ]]
]

{ #category : #'life cycle' }
MAQueen >> componentPassivate [

	self getTMATimeTravelEventsSubscriber unsubscribe: self
]

{ #category : #'life cycle' }
MAQueen >> componentRemove [

	"Queen notify its remove"

	(MolUtils instanceOf: MATimeTravel named: #TimeTravel) ifNotNil: [ self getTMATimeTravelServicesProvider isRestoring ifFalse: [ 
		self getTMATimeTravelServicesProvider
			removeOf: self
			at: self getTMASimulationServicesProvider getStep ]]

	
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
MAQueen >> saveForTimeTravel: aStep [

	| memento |
	memento := MAQueenMemento  new.

	self getTMATimeTravelServicesProvider
		save: (memento save: self)
		at: aStep
]