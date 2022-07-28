"
The actual implementation of the TMARoleeType: MARole, describe the role of one stage. The role provides the behavior of an ant at each step. Actually roles are implemented by MAQueen, MAFighter or MAWorker that are subclass of MARole. In each different implementation there is one method: doSimulationStepFor: that manage the action of the ant and one method: moveFrom: that manage the position of the ant at each step.
"
Class {
	#name : #MARole,
	#superclass : #Object,
	#traits : 'MolComponentImpl + TMARoleType + TMARoleServices + TimeTravelEvents + TObservable',
	#classTraits : 'MolComponentImpl classTrait + TMARoleType classTrait + TMARoleServices classTrait + TimeTravelEvents classTrait + TObservable classTrait',
	#category : #MolAntsTimeTravel
}

{ #category : #accessing }
MARole >> getRoleName [

	^ roleName.
]

{ #category : #'component accessing' }
MARole >> getTMARoleEventsNotifier [
	^self eventsNotifiers at: TMARoleEvents ifAbsent: [^MolNotFoundEventsNotifier new interface: TMARoleEvents name: nil].
]

{ #category : #'component accessing' }
MARole >> getTMASimulationServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TMASimulationServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TMASimulationServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #'component accessing' }
MARole >> getTimeTravelEventsSubscriber [
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
MARole >> getTimeTravelServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TimeTravelServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TimeTravelServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #initialization }
MARole >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]

{ #category : #role }
MARole >> moveFrom: anAnt [
]

{ #category : #events }
MARole >> restoreFrom: aMemento [
]
