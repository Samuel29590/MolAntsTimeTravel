"
The actual implementation of the TMAInsectsType: MAInsect, describe one insect. It means that if there are 50 insects on the simulation, there are also 50 instances of MAInsects. This implementation is very simple, insect only move on the ground randomly (waiting to be eaten...) at each step of the simulation.

Variables :

-position, is a point.

-ageInMs, is an integer.
"
Class {
	#name : #MAInsect,
	#superclass : #Object,
	#traits : 'MolComponentImpl + TMAInsectsType + TMASimulationToGlobalEvents + TimeTravelEvents + TObservable',
	#classTraits : 'MolComponentImpl classTrait + TMAInsectsType classTrait + TMASimulationToGlobalEvents classTrait + TimeTravelEvents classTrait + TObservable classTrait',
	#instVars : [
		'#position => ObservableSlot',
		'#ageInMs => ObservableSlot'
	],
	#category : #MolAntsTimeTravel
}

{ #category : #'life cycle' }
MAInsect >> componentActivate [

	"Activation of the MAInsect component."

	self getTMASimulationToGlobalEventsSubscriber subscribe: self.

	"--------------------------Time Travel--------------------------"
	"Subscription to the Time Travel event"
	self getTimeTravelEventsSubscriber subscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAInsect >> componentInitialize [

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
	
	"Initialization of the MAInsect component."

	self forServices: TMASimulationServices useProvider: #default.
	
	ageInMs := 0.
	position := ((Random new nextIntegerBetween: 1 and: MASimulationManager simulationWidth) @ (Random new nextIntegerBetween: 1 and: MASimulationManager simulationHeight)).
	
	"--------------------------Time Travel--------------------------"
	self property: #ageInMs whenChangedDo: [ 
		(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
			self getTimeTravelServicesProvider isRestoring ifFalse: [ 
				self saveForTimeTravel ] ] ].
	self property: #position whenChangedDo: [ 
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
MAInsect >> componentPassivate [

	"Passivating the MAInsect component."

	self getTMASimulationToGlobalEventsSubscriber unsubscribe: self.
	
	"--------------------------Time Travel--------------------------"
	"Unsubscribe from the Time Travel event"
	self getTimeTravelEventsSubscriber unsubscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAInsect >> componentRemove [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifFalse: [
			"Component saves its state."
			self saveForTimeTravel.
			"Component notifies its deletion"
			self getTimeTravelServicesProvider deletionOf: self ] ].
	"---------------------------------------------------------------"
	
	"Removing the MAInsect component."

	position := nil.
	ageInMs := nil
]

{ #category : #'life cycle' }
MAInsect >> doSimulationStep [

	"At each step an insect just move randomly, waiting to be eaten ..."

		ageInMs := ageInMs + MASimulationManager simulationStepDurationInMs.
		self position: position
			+
			((Random new next * 2 - 1) rounded
			 @ (Random new next * 2 - 1) rounded) 
]

{ #category : #accessing }
MAInsect >> getAgeInMs [

	^ ageInMs
]

{ #category : #'life cycle' }
MAInsect >> getPosition [

	^ position
]

{ #category : #'component accessing' }
MAInsect >> getTMAInsectEventsNotifier [
	^self eventsNotifiers at: TMAInsectEvents ifAbsent: [^MolNotFoundEventsNotifier new interface: TMAInsectEvents name: nil].
]

{ #category : #'component accessing' }
MAInsect >> getTMASimulationServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TMASimulationServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TMASimulationServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #'component accessing' }
MAInsect >> getTMASimulationToGlobalEventsSubscriber [
	| eventsSymbol eventsSubscriber itf |
	itf := TMASimulationToGlobalEvents.
	eventsSymbol := self eventsSubscribers at: itf ifAbsent: [^MolNotFoundEventsSubscriber new interface: itf name: nil].
	eventsSymbol isCollection
	 	ifTrue: 
			[eventsSubscriber := MolComponentManager default locatorServices 
						searchEventsSubscriberFor: TMASimulationToGlobalEvents named: eventsSymbol ]. 
	^eventsSubscriber
]

{ #category : #'component accessing' }
MAInsect >> getTimeTravelEventsSubscriber [
	| eventsSymbol eventsSubscriber itf |
	itf := TimeTravelEvents.
	eventsSymbol := self eventsSubscribers at: itf ifAbsent: [^MolNotFoundEventsSubscriber new interface: itf name: nil].
	eventsSymbol isCollection
	 	ifTrue: 
			[eventsSubscriber := MolComponentManager default locatorServices 
						searchEventsSubscriberFor: TimeTravelEvents named: eventsSymbol ]. 
	^eventsSubscriber
]

{ #category : #'component accessing' }
MAInsect >> getTimeTravelServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TimeTravelServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TimeTravelServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #initialization }
MAInsect >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]

{ #category : #'life cycle' }
MAInsect >> position: aPoint [

	| oldPos |
	position ~= aPoint ifFalse: [ ^ self ].
	oldPos := position.
	position := aPoint.

	position x < 0 ifTrue: [ position := 0 @ position y ].
	position y < 0 ifTrue: [ position := position x @ 0 ].
	position x >= MASimulationManager simulationWidth ifTrue: [ 
		position := MASimulationManager simulationHeight @ position y ].
	position y >= MASimulationManager simulationHeight ifTrue: [ 
		position := position x @ MASimulationManager simulationWidth ].

	self getTMAInsectEventsNotifier 
		positionChangedFor: self
		oldPos: oldPos
		newPos: position
]

{ #category : #events }
MAInsect >> restoreFrom: aMemento [

	"Restore variables thanks to a memento."

	position := aMemento getPosition.
	ageInMs := aMemento getAgeInMs
]

{ #category : #events }
MAInsect >> saveForTimeTravel [

	| memento |
	memento := MolInsectMemento new.

	self getTimeTravelServicesProvider
		save: (memento save: self)
]

{ #category : #'events - lifecycle' }
MAInsect >> simulationStepSent: aStep [

	self doSimulationStep.
]
