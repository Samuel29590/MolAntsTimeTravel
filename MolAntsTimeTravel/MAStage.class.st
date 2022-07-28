"
The actual implementation of the TMAStageType: MAStage, describe the stage of one ant. The stage manages the life cycle of an ant, it determines when an ant is an egg, an adult or when the ant is dead. It also sends to the role the order to do the simulation step and to move.

Variables :

-eggStateDurationInMs, is an integer to determine the duration in ms of the egg state of the ant.

-adultStateDurationInMs, is an integer to determine the duration in ms of the adult state of the ant.
"
Class {
	#name : #MAStage,
	#superclass : #Object,
	#traits : 'MolComponentImpl + TMAStageType + TMAStageServices + TimeTravelEvents + TObservable',
	#classTraits : 'MolComponentImpl classTrait + TMAStageType classTrait + TMAStageServices classTrait + TimeTravelEvents classTrait + TObservable classTrait',
	#instVars : [
		'#eggStateDurationInMs => ObservableSlot',
		'#adultStateDurationInMs => ObservableSlot'
	],
	#category : #MolAntsTimeTravel
}

{ #category : #'life cycle' }
MAStage >> componentActivate [

	"--------------------------Time Travel--------------------------"
	"Subscription to the Time Travel event"
	self getTimeTravelEventsSubscriber subscribe: self.
	"---------------------------------------------------------------"

	
]

{ #category : #'life cycle' }
MAStage >> componentInitialize [

	"--------------------------Time Travel--------------------------"

	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ "Connection to the TimeTravel service."
		self forServices: TimeTravelServices useProvider: #default.
		"Subscription to the Time Travel event"
		self getTimeTravelEventsSubscriber subscribe: self.
		self getTimeTravelServicesProvider isRestoring ifFalse: [ "Component notifies its creation" 
			self getTimeTravelServicesProvider creationOf: self ] ].
	"---------------------------------------------------------------"

	"Initialization of the MAStage component."

	self forServices: TMASimulationServices useProvider: #default.

	self
		forServices: TMARoleServices
		useProvider: (#role , self componentName asSymbol) asSymbol.

	eggStateDurationInMs := (Random new next * 5000) rounded + 1000.
	adultStateDurationInMs := (Random new next * 10000) rounded + 10000.
	self initializeRole.

	"--------------------------Time Travel--------------------------"
	self property: #eggStateDurationInMs whenChangedDo: [ 
		(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
			self getTimeTravelServicesProvider isRestoring ifFalse: [ 
				self saveForTimeTravel ] ] ].
	self property: #adultStateDurationInMs whenChangedDo: [ 
		(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
			self getTimeTravelServicesProvider isRestoring ifFalse: [ 
				self saveForTimeTravel ] ] ].
	self property: #stageName whenChangedDo: [ 
		(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
			self getTimeTravelServicesProvider isRestoring ifFalse: [ 
				self saveForTimeTravel ] ] ].
	self property: #role whenChangedDo: [ 
		(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
			self getTimeTravelServicesProvider isRestoring ifFalse: [ 
				self saveForTimeTravel ] ] ].
	"---------------------------------------------------------------"

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ "---------------------------------------------------------------"
		self getTimeTravelServicesProvider isRestoring ifFalse: [ "Component saves its state." 
			self saveForTimeTravel ] ]
]

{ #category : #'life cycle' }
MAStage >> componentPassivate [

	"--------------------------Time Travel--------------------------"
	"Unsubscribe from the Time Travel event"
	self getTimeTravelEventsSubscriber unsubscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAStage >> componentRemove [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifFalse: [
			"Component saves its state."
			self saveForTimeTravel.
			"Component notifies its deletion"
			self getTimeTravelServicesProvider deletionOf: self ] ].
	"---------------------------------------------------------------"

	"Removing of the MAStage component."

	eggStateDurationInMs := nil.
	adultStateDurationInMs := nil.
	stageName := nil.
	role := nil
]

{ #category : #private }
MAStage >> computeStageFor: anAnt [

	"Checking if an egg hatch."

	self getStageName = #egg ifTrue: [ 
		anAnt getAgeInMs > eggStateDurationInMs ifTrue: [ "If the egg hatch, adding the role as a producer of TMARoleService associate to this MAStage."
			stageName := #adult.
			self
				forServices: TMARoleServices
				useProvider: (#role , self componentName asSymbol) asSymbol ].
		^ self ].

	"Checking if an adult is dead."

	self getStageName = #adult ifTrue: [ 
		anAnt getAgeInMs > adultStateDurationInMs ifTrue: [ "If the adult is dead, notify the MASimulationManager."
			stageName := #dead.
			self getTMAStageEventsNotifier stageChanged: stageName for: anAnt ].
		^ self ]
]

{ #category : #private }
MAStage >> doSimulationStepFor: anAnt [


	self computeStageFor: anAnt.
	self getStageName = #adult ifTrue: [ 
		self getRole doSimulationStepFor: anAnt ].

]

{ #category : #accessing }
MAStage >> getAdultStateDurationInMs [

	^ adultStateDurationInMs
]

{ #category : #accessing }
MAStage >> getEggStateDurationInMs [

	^ eggStateDurationInMs
]

{ #category : #role }
MAStage >> getRole [

	^ role
]

{ #category : #role }
MAStage >> getRoleName [

	^ role getRoleName
]

{ #category : #'component accessing' }
MAStage >> getTMARoleServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TMARoleServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TMARoleServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #'component accessing' }
MAStage >> getTMASimulationServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TMASimulationServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TMASimulationServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #'component accessing' }
MAStage >> getTMAStageEventsNotifier [
	^self eventsNotifiers at: TMAStageEvents ifAbsent: [^MolNotFoundEventsNotifier new interface: TMAStageEvents name: nil].
]

{ #category : #'component accessing' }
MAStage >> getTimeTravelEventsSubscriber [
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
MAStage >> getTimeTravelServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TimeTravelServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TimeTravelServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #initialization }
MAStage >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]

{ #category : #initialization }
MAStage >> initializeRole [

	"Initialization of the role of an ant."

	| x |
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifTrue: [ ^ self ] ].


	"The first ant is always a queen."
	componentName = #stageAnt1 ifTrue: [ 
		role := MAQueen start:
			        (#role , self componentName asSymbol) asSymbol.
		^ self ].

	x := Random new nextIntegerBetween: 1 and: 100.
	x = 1 ifTrue: [ 
		role := MAQueen start:
			        (#role , self componentName asSymbol) asSymbol.
		^ self ].
	x < 26 ifTrue: [ 
		role := MAFighter start:
			        (#role , self componentName asSymbol) asSymbol.
		^ self ].
	x <= 100 ifTrue: [ 
		role := MAWorker start:
			        (#role , self componentName asSymbol) asSymbol.
		^ self ]
]

{ #category : #testing }
MAStage >> isAlive [
	^ stageName ~= #dead.
]

{ #category : #role }
MAStage >> moveFrom: anAnt [

	"Perform the moving action of the role."

	self getStageName ~= #adult ifTrue: [ ^ anAnt getPosition ].

	^ self getTMARoleServicesProvider moveFrom: anAnt.

]

{ #category : #events }
MAStage >> restoreFrom: aMemento [

	"Restore variables thanks to a memento."

	eggStateDurationInMs := aMemento getEggStateDurationInMs.
	adultStateDurationInMs := aMemento getAdultStateDurationInMs.
	stageName := aMemento getStageName.
	aMemento getRole ifNil: [ role := nil ] ifNotNil: [ 
	role := (MolUtils instanceOf: aMemento getRole componentClass named: aMemento getRole componentName)]
]

{ #category : #events }
MAStage >> saveForTimeTravel [

		| memento |
	memento := MolStageMemento new.

	self getTimeTravelServicesProvider
		save: (memento save: self)
]
