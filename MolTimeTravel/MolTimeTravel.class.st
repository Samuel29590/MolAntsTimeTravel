Class {
	#name : #MolTimeTravel,
	#superclass : #Object,
	#traits : 'MolComponentImpl + TimeTravelType + TimeTravelServices',
	#classTraits : 'MolComponentImpl classTrait + TimeTravelType classTrait + TimeTravelServices classTrait',
	#instVars : [
		'history',
		'currentStep',
		'lastStep',
		'isSaving',
		'isRestoring',
		'isReplaying',
		'isPlayingBackward',
		'replaySpeed',
		'timeTravelLoop',
		'timeTravelPanel',
		'timeTravelView'
	],
	#category : #MolTimeTravel
}

{ #category : #'life cycle' }
MolTimeTravel >> componentInitialize [

	"here write the code corresponding to component initialisation phase"

	isSaving := true.
	isRestoring := false.
	isReplaying := false.
	isPlayingBackward := false.
	timeTravelLoop := nil.
	lastStep := 2.
	currentStep := 2.
	replaySpeed := 0.
	history := OrderedCollection new.
	history add: MolComponentStep new.
	history add: MolComponentStep new.

	timeTravelView := MolTimeTravelView new
		setTimeTravel: self;
		start
]

{ #category : #'life cycle' }
MolTimeTravel >> componentRemove [

	timeTravelView stop.

	history := nil.
	lastStep := nil.
	currentStep := nil.
	replaySpeed := nil.
	isSaving := nil.
	isRestoring := nil.
	isReplaying := nil.
	isPlayingBackward := nil.
	timeTravelLoop := nil.
	timeTravelPanel := nil
]

{ #category : #services }
MolTimeTravel >> creationOf: aComponent [

	| aComponentMemento |
	aComponentMemento := MolComponentCreationMemento new save: aComponent.

	(history at: currentStep) isANewStep ifFalse: [ self nextStep ].

	(history at: currentStep) saveCreationOrDeletionOf: aComponentMemento.

	self saveTheApplication
]

{ #category : #accessing }
MolTimeTravel >> currentStep [

	^ currentStep
]

{ #category : #services }
MolTimeTravel >> deletionOf: aComponent [

	| aComponentMemento |
	aComponentMemento := MolComponentDeletionMemento new save: aComponent.

	(history at: currentStep) isANewStep ifFalse: [ self nextStep ].
	
	(history at: currentStep) saveCreationOrDeletionOf: aComponentMemento.

	self saveTheApplication
]

{ #category : #'component accessing' }
MolTimeTravel >> getTimeTravelEventsNotifier [
	^self eventsNotifiers at: TimeTravelEvents ifAbsent: [^MolNotFoundEventsNotifier new interface: TimeTravelEvents name: nil].
]

{ #category : #accessing }
MolTimeTravel >> history [

	^ history
]

{ #category : #testing }
MolTimeTravel >> isOnTheFirstStep [

	^ currentStep = 1
]

{ #category : #testing }
MolTimeTravel >> isOnTheLastStep [

	^ currentStep = lastStep 
]

{ #category : #accessing }
MolTimeTravel >> isPlayingBackward [

	^ isPlayingBackward
]

{ #category : #accessing }
MolTimeTravel >> isReplaying [

	^ isReplaying
]

{ #category : #services }
MolTimeTravel >> isRestoring [

	^ isRestoring
]

{ #category : #accessing }
MolTimeTravel >> isSaving [

	^ isSaving
]

{ #category : #accessing }
MolTimeTravel >> lastStep [

	^ lastStep
]

{ #category : #services }
MolTimeTravel >> nextStep [

	currentStep := currentStep + 1.
	lastStep := lastStep + 1.
	history add: MolComponentStep new
]

{ #category : #'life cycle' }
MolTimeTravel >> playBackward [

	isRestoring ifFalse: [ ^ self ].
	isReplaying ifTrue: [ ^ self ].

	isPlayingBackward
		ifTrue: [ 
			isPlayingBackward := false.
			timeTravelLoop ifNil: [ ^ self ].
			timeTravelLoop terminate.
			timeTravelLoop := nil ]
		ifFalse: [ 
			isPlayingBackward := true.
			timeTravelLoop := [ 
			                  [ currentStep > 1 ] whileTrue: [ 
				                  self restoreOneStepBefore.
				                  replaySpeed = 0 ifFalse: [ 
					                  (Delay forMilliseconds: replaySpeed) wait ] ].
			                  isPlayingBackward := false.
			                  timeTravelLoop ifNil: [ ^ self ].
			                  timeTravelLoop terminate.
			                  timeTravelLoop := nil ] newProcess priority:
				                  Processor userBackgroundPriority.
			timeTravelLoop name: 'Molecule TimeTravelLoop Process'.
			timeTravelLoop resume ]
]

{ #category : #'life cycle' }
MolTimeTravel >> replay [

	isRestoring ifFalse: [ ^ self ].
	isPlayingBackward ifTrue: [ ^ self ].

	isReplaying
		ifTrue: [ 
			isReplaying := false.
			timeTravelLoop ifNil: [ ^ self ].
			timeTravelLoop terminate.
			timeTravelLoop := nil ]
		ifFalse: [ 
			isReplaying := true.
			timeTravelLoop := [ 
			                  [ currentStep < lastStep ] whileTrue: [ 
				                  self restoreOneStepAfter.replaySpeed = 0 ifFalse: [ 
					                  (Delay forMilliseconds: replaySpeed) wait ] ].
			                  isReplaying := false.
			                  timeTravelLoop ifNil: [ ^ self ].
			                  timeTravelLoop terminate.
			                  timeTravelLoop := nil ] newProcess priority:
				                  Processor userBackgroundPriority.
			timeTravelLoop name: 'Molecule TimeTravelLoop Process'.
			timeTravelLoop resume ]
]

{ #category : #accessing }
MolTimeTravel >> replaySpeed [

	^ replaySpeed
]

{ #category : #accessing }
MolTimeTravel >> replaySpeed: anInteger [

	replaySpeed := anInteger.
]

{ #category : #'life cycle' }
MolTimeTravel >> restoreAtStep: aStep [

	| componentsLifeCycles mementos events |
	isRestoring ifFalse: [ ^ self ].

	currentStep < 1 | (currentStep > lastStep) ifTrue: [ ^ self ].

	"Undo"
	aStep < currentStep ifTrue: [ "Remove or create components"
		componentsLifeCycles := (history at: (aStep + 1)) creationsAndDeletions.
		componentsLifeCycles do: [ :componentLifeCycle | 
			componentLifeCycle undo ].

		"Restoration of the state of components"
		mementos := (history at: aStep) mementos.
		mementos do: [ :memento | memento undo ].

		"events undo"
		events := (history at: aStep) events.
		events do: [ :event | event undo ] ].

	"Redo"
	currentStep < aStep ifTrue: [ "Remove or create components"
		componentsLifeCycles := (history at: aStep) creationsAndDeletions.
		componentsLifeCycles do: [ :componentLifeCycle | 
			componentLifeCycle redo ].

		"Restoration of the state of components"
		mementos := (history at: aStep) mementos.
		mementos do: [ :memento | memento redo ].

		"Replay the events"
		events := (history at: aStep) events.
		events do: [ :event | event redo ] ]
]

{ #category : #'life cycle' }
MolTimeTravel >> restoreOneStepAfter [
 currentStep < lastStep  ifTrue: [ 
	self restoreAtStep: currentStep + 1.
	currentStep := currentStep + 1]
]

{ #category : #'life cycle' }
MolTimeTravel >> restoreOneStepBefore [
 currentStep > 1 ifTrue: [ 
	self restoreAtStep: currentStep - 1.
	currentStep := currentStep - 1]
]

{ #category : #services }
MolTimeTravel >> save: aComponentMemento [

	((history at: currentStep) stepAlreadyContains: aComponentMemento) ifTrue:[self nextStep ].
	
	(history at: currentStep) save: aComponentMemento.
]

{ #category : #services }
MolTimeTravel >> saveEvent: aMethodName performBy: aComponent withParameters: someParameters [

	| aComponentMemento |
	aComponentMemento := MolComponentEventMemento new
		                     saveEvent: aMethodName
		                     performBy: aComponent
		                     withParameters: someParameters.

	(history at: currentStep) isANewStep ifFalse: [ self nextStep ].

	(history at: currentStep) saveEvent: aComponentMemento.

	aComponent saveForTimeTravel.
]

{ #category : #services }
MolTimeTravel >> saveTheApplication [

	self getTimeTravelEventsNotifier saveForTimeTravel.

	self nextStep.
]

{ #category : #'life cycle' }
MolTimeTravel >> startTimeTravel [

	isRestoring ifFalse: [ 
		isSaving := false.
		isRestoring := true.
		self getTimeTravelEventsNotifier startTimeTravel ]
]

{ #category : #'life cycle' }
MolTimeTravel >> stopTimeTravel [

	isRestoring ifTrue: [ 
		isPlayingBackward ifFalse: [ 
			isReplaying ifFalse: [ 
				isReplaying := true.
				[ currentStep < lastStep ] whileTrue: [ 
					self restoreOneStepAfter  ].
				isReplaying := false.
				isSaving := true.
				isRestoring := false.
				self getTimeTravelEventsNotifier stopTimeTravel ] ] ]
]

{ #category : #accessing }
MolTimeTravel >> timeTravelLoop [

	^ timeTravelLoop
]

{ #category : #accessing }
MolTimeTravel >> timeTravelPanel [

	^ timeTravelPanel
]
