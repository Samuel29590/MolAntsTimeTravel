"
The actual implementation of the TMAPheromonesType: MAPheromones, manage all the pheromones of the simulation. Pheromones are stored in two dictionaries, one for exploration's pheromones and one for returning's pheromones. Dictionaries has for key: the position and for value: an association: (an Ant -> an Integer). In this association the ant represent the last ant that visits the pheromone and the integer represent the intensity of the pheromone.

Pheromones are created by ants when they are moving on the ground and if an ant moves on a position where a pheromone already exists the pheromone is only update (intensity set to maximum). And at each step of the simulation each pheromone intensity is decreased by one.

Variables :

-maxIntensity, is an integer representing the intensity maximum of the pheromone.

-pheromonesDict, is a dictionary containing every pheromones of exploration. Key: a point. Value: an association (ant->intensity).

-pheromonesReturnDict, is a dictionary containing every pheromones of return. Key: a point. Value: an association (ant->intensity).
"
Class {
	#name : #MAPheromones,
	#superclass : #Object,
	#traits : 'MolComponentImpl + TMAPheromonesType + TMAPheromoneServices + TMASimulationToGlobalEvents + TimeTravelEvents + TObservable',
	#classTraits : 'MolComponentImpl classTrait + TMAPheromonesType classTrait + TMAPheromoneServices classTrait + TMASimulationToGlobalEvents classTrait + TimeTravelEvents classTrait + TObservable classTrait',
	#instVars : [
		'#maxIntensity => ObservableSlot',
		'#pheromonesDict => ObservableSlot',
		'#pheromonesReturnDict => ObservableSlot'
	],
	#category : #MolAntsTimeTravel
}

{ #category : #accessing }
MAPheromones class >> getMaxIntensity [

	^ 200
]

{ #category : #'life cycle' }
MAPheromones >> componentActivate [

	"Activation of the MAPheromones component."

	self getTMASimulationToGlobalEventsSubscriber subscribe: self.

	"--------------------------Time Travel--------------------------"
	"Subscription to the Time Travel event"
	self getTimeTravelEventsSubscriber subscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAPheromones >> componentInitialize [

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
	
	"Initialization of the MAPheromones component."

	self forServices: TMASimulationServices useProvider: #default.
	
	maxIntensity := 100.
	pheromonesDict := Dictionary new.
	pheromonesReturnDict := Dictionary new.
	
	"--------------------------Time Travel--------------------------"
	self property: #maxIntensity whenChangedDo: [ 
		(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
			self getTimeTravelServicesProvider isRestoring ifFalse: [ 
				self saveForTimeTravel ] ] ].
	self property: #pheromonesDict whenChangedDo: [ 
		(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
			self getTimeTravelServicesProvider isRestoring ifFalse: [ 
				self saveForTimeTravel ] ] ].	
	self property: #pheromonesReturnDict whenChangedDo: [ 
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
MAPheromones >> componentPassivate [

	"Passivating the MAPheromones component."

	self getTMASimulationToGlobalEventsSubscriber unsubscribe: self.
	
	"--------------------------Time Travel--------------------------"
	"Unsubscribe from the Time Travel event"
	self getTimeTravelEventsSubscriber unsubscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAPheromones >> componentRemove [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifFalse: [
			"Component saves its state."
			self saveForTimeTravel.
			"Component notifies its deletion"
			self getTimeTravelServicesProvider deletionOf: self ] ].
	"---------------------------------------------------------------"
	
	"Removing the MAPheromones component."

	maxIntensity := nil.
	pheromonesDict := nil.
	pheromonesReturnDict := nil

]

{ #category : #'events - lifecycle' }
MAPheromones >> doSimulationStep [

	"At each step, all pheromones loose 1 to their intensity. If a pheromone has 0 as intensity it's remove from the dictionaries."

	pheromonesDict keysDo: [ :each | 
		pheromonesDict at: each update: [ :v | v value: v value - 1 ].
		(pheromonesDict at: each) value <= 0 ifTrue: [ 
			pheromonesDict removeKey: each ] ].

	pheromonesReturnDict keysDo: [ :each | 
		pheromonesReturnDict at: each update: [ :v | v - 1 ].
		(pheromonesReturnDict at: each) <= 0 ifTrue: [ 
			pheromonesReturnDict removeKey: each ] ]
]

{ #category : #services }
MAPheromones >> getMaxIntensity [

	^ maxIntensity.
]

{ #category : #services }
MAPheromones >> getPheromonesDict [

	^ pheromonesDict.
]

{ #category : #services }
MAPheromones >> getPheromonesReturnDict [

	^ pheromonesReturnDict
]

{ #category : #'component accessing' }
MAPheromones >> getTMASimulationServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TMASimulationServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TMASimulationServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #'component accessing' }
MAPheromones >> getTMASimulationToGlobalEventsSubscriber [
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
MAPheromones >> getTimeTravelEventsSubscriber [
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
MAPheromones >> getTimeTravelServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TimeTravelServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TimeTravelServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #initialization }
MAPheromones >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]

{ #category : #events }
MAPheromones >> pheromoneNew: aPoint for: anAnt [

	"Adding or updating a pheromone of exploration at a specific point."

	(pheromonesDict includesKey: aPoint)
		ifFalse: [ "The following code permit to not create pheromones in the ant hill. In order to keep the ant hill clear."
			| pointRectangle antHillRectangle |
			pointRectangle := BlBounds
				                  origin: anAnt getPosition - (20 @ 20)
				                  extent: 40 @ 40.

			antHillRectangle := BlBounds
				                    origin:
				                    MASimulationManager simulationAntHillPosition
				                    extent: 0 @ 0.
			(pointRectangle intersects: antHillRectangle) ifFalse: [ 
				pheromonesDict add: aPoint -> (anAnt -> maxIntensity) ] ]
		ifTrue: [ pheromonesDict at: aPoint put: anAnt -> maxIntensity ]
]

{ #category : #events }
MAPheromones >> pheromoneReturnNew: aPoint for: anAnt [

	"Adding or updating a pheromone of return at a specific point."

	(pheromonesReturnDict includesKey: aPoint)
		ifFalse: [ pheromonesReturnDict add: aPoint -> maxIntensity ]
		ifTrue: [ 
			pheromonesReturnDict
				at: aPoint
				update: [ :v | v - v + maxIntensity ] ]
]

{ #category : #events }
MAPheromones >> restoreFrom: aMemento [

	"Restore variables thanks to a memento."

	maxIntensity := aMemento getMaxIntensity.


	aMemento getPheromonesDict
		ifNotNil: [ 
			pheromonesDict := Dictionary new.
			aMemento getPheromonesDict keysAndValuesDo: [ :k :v | 
				
				v key isComponentReference ifTrue:[
				
				pheromonesDict
					at: k
					put:
						(MolUtils
							 instanceOf: v key componentClass
							 named: v key componentName) -> v value
							] ifFalse:[pheromonesDict
					at: k
					put:v key  -> v value]
							
							 ] ]
		ifNil: [ pheromonesDict := nil ].
	aMemento getPheromonesReturnDict
		ifNotNil: [ 
			pheromonesReturnDict := Dictionary new.
			aMemento getPheromonesReturnDict keysAndValuesDo: [ :k :v | 
				pheromonesReturnDict at: k put: v ] ]
		ifNil: [ pheromonesReturnDict := nil ]
]

{ #category : #events }
MAPheromones >> saveForTimeTravel [

		| memento |
	memento := MolPheromonesMemento new.

	self getTimeTravelServicesProvider
		save: (memento save: self)
]

{ #category : #'events - lifecycle' }
MAPheromones >> simulationStepSent: aStep [

	self doSimulationStep.

	"self saveForTimeTravel: aStep"
]
