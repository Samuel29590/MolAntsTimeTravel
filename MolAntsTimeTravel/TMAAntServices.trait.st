"
This service is provided by the ant implementation isn't used by another component. However, it permits to describe methods that the ant implementation need to provide.
"
Trait {
	#name : #TMAAntServices,
	#instVars : [
		'#stage => ObservableSlot'
	],
	#traits : 'MolComponentServices + TObservable',
	#classTraits : 'MolComponentServices classTrait + TObservable classTrait',
	#category : #MolAntsTimeTravel
}

{ #category : #services }
TMAAntServices >> getRole [

	
]

{ #category : #services }
TMAAntServices >> getRoleName [
]

{ #category : #services }
TMAAntServices >> getStage [
]

{ #category : #services }
TMAAntServices >> getStageName [

	
]

{ #category : #initialization }
TMAAntServices >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]
