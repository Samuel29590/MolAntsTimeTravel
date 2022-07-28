"
This service is provided by the role implementation and used by the stage. It describes methods that the role needs to implement because the stage implementation needs it to work correctly.

Variables :

-roleName, is a symbol used to know the role of an ant: queen, fighter or worker.
"
Trait {
	#name : #TMARoleServices,
	#instVars : [
		'#roleName => ObservableSlot'
	],
	#traits : 'MolComponentServices + TObservable',
	#classTraits : 'MolComponentServices classTrait + TObservable classTrait',
	#category : #MolAntsTimeTravel
}

{ #category : #role }
TMARoleServices >> doSimulationStepFor: anAnt [
]

{ #category : #accessing }
TMARoleServices >> getRoleName [
]

{ #category : #initialization }
TMARoleServices >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]

{ #category : #role }
TMARoleServices >> moveFrom: anAnt [
]
