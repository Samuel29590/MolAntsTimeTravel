"
The actual implementation of the TMAGroundType: MAGround is the implementation of the system's view. It permits to draw all the entities of the system on a canvas and to keep the information panel up-to-date. It also permits to have a functional interface with buttons to start, pause and stop the system and also buttons to change the refresh rate.

Variables :

-mySpace, containing the BlSpace object.

-refreshing, is an integer used to know the actual refresh rate of the view.

-stepView, is a BlTextElement used to print the actual step on the view.

-nbInsectsView, is a BlTextElement used to print the actual number of insects on the view.

-nbDeliveredView, is a BlTextElement used to print the actual number of insects delivered on the view.

-nbPheromonesView, is a BlTextElement used to print the actual number of pheromones on the view.

-nbEggsView, is a BlTextElement used to print the actual number of eggs on the view.

-nbAntView, is a BlTextElement used to print the actual number of ants on the view.
"
Class {
	#name : #MAGround,
	#superclass : #BlElement,
	#traits : 'MolComponentImpl + TMAGroundType + TMASimulationToGlobalEvents + TMATimeTravelEvents',
	#classTraits : 'MolComponentImpl classTrait + TMAGroundType classTrait + TMASimulationToGlobalEvents classTrait + TMATimeTravelEvents classTrait',
	#instVars : [
		'viewLoop',
		'mySpace',
		'refreshing',
		'stepView',
		'nbInsectsView',
		'nbDeliveredView',
		'nbPheromonesView',
		'nbEggsView',
		'nbAntsView',
		'nbFeedingPointView',
		'buttonReplay',
		'buttonPlay',
		'buttonPause'
	],
	#category : #MolAntsTimeTravel
}

{ #category : #'life cycle' }
MAGround >> componentActivate [

	"Activation of the MAGround component."

	self getTMASimulationToGlobalEventsSubscriber subscribe: self
	
.self getTMATimeTravelEventsSubscriber subscribe: self.
]

{ #category : #'life cycle' }
MAGround >> componentInitialize [

	"Initialization of the MAGround component."

	self forServices: TMATimeTravelServices useProvider: #TimeTravel.

	self forServices: TMASimulationServices useProvider: #default.

	refreshing := 1.
	mySpace := self openInNewSpace extent:
		           MASimulationManager simulationWidth
		           @ (MASimulationManager simulationHeight + 300).
	mySpace title: 'MolAnts Simulation'.
	self createInfoPanel.
	self startViewLoop
]

{ #category : #'life cycle' }
MAGround >> componentPassivate [

	"Passivating the MAGround component."

	self getTMASimulationToGlobalEventsSubscriber unsubscribe: self
.
	self getTMATimeTravelEventsSubscriber unsubscribe: self
]

{ #category : #'life cycle' }
MAGround >> componentRemove [

	"Removing the MAGround component."

	self stopViewLoop.
	mySpace ifNotNil: [ mySpace close ].
	mySpace := nil.
	
refreshing:= nil.
 stepView:= nil.
 nbInsectsView:= nil.
 nbDeliveredView:= nil.
 nbPheromonesView:= nil.
 nbEggsView:= nil.
 nbAntsView:= nil.
 nbFeedingPointView:= nil.
 buttonReplay:= nil.
 buttonPlay:= nil.
 buttonPause:= nil.
]

{ #category : #initialization }
MAGround >> createInfoPanel [

	"Initialize the info panel of the view. It initialize each item of the panel (buttons, texts ...)."

	| infoPanel button labelText label |
	infoPanel := BlElement new.
	infoPanel background: Color lightGray.
	infoPanel relocate: 0 @ MASimulationManager simulationHeight.
	infoPanel size: MASimulationManager simulationWidth @ 300.
	infoPanel constraintsDo: [ :c | 
		c maxHeight: 300.
		c maxWidth: MASimulationManager simulationWidth ].
	mySpace addChild: infoPanel.



	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding Pause button"
	buttonPause := BlElement new
		               background: Color orange;
		               geometry:
			               (BlRoundedRectangleGeometry cornerRadius: 2);
		               padding: (BlInsets
				                top: 8
				                right: 16
				                bottom: 8
				                left: 16);
		               layout: BlLinearLayout horizontal;
		               effect: (BlGaussianShadowEffect
				                color: (Color black alpha: 0.3)
				                width: 1
				                offset: 0 @ 2);
		               constraintsDo: [ :c | 
			               c horizontal fitContent.
			               c vertical fitContent ];
		               relocate:
			               MASimulationManager simulationWidth / 10 @ 10;
		               addEventHandler: (BlEventHandler
				                on: BlClickEvent
				                do: [ :anEvent | 
					                buttonPause isVisible ifTrue: [ 
							                self isRunning ifTrue: [ 
									                (MolUtils
										                 instanceOf: MATimeTravel
										                 named: #TimeTravel)
										                ifNotNil: [ 
											                self getTMATimeTravelServicesProvider
												                isRestoring ifFalse: [ 
													                MASimulationManager pauseSimulation ] ]
										                ifNil: [ 
											                MASimulationManager pauseSimulation ] ] ].
					                anEvent consumed: true ]).
	labelText := 'Pause' asRopedText
		             foreground: Color black;
		             fontSize: 16;
		             fontName: 'Helvetica';
		             thin.
	label := BlTextElement new.
	label text: labelText.
	buttonPause addChild: label.
	infoPanel addChild: buttonPause.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding Play button"
	buttonPlay := BlElement new
		              background: Color green;
		              geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		              padding: (BlInsets
				               top: 8
				               right: 16
				               bottom: 8
				               left: 16);
		              layout: BlLinearLayout horizontal;
		              effect: (BlGaussianShadowEffect
				               color: (Color black alpha: 0.3)
				               width: 1
				               offset: 0 @ 2);
		              constraintsDo: [ :c | 
			              c horizontal fitContent.
			              c vertical fitContent ];
		              relocate:
			              MASimulationManager simulationWidth / 10 * 4.5 @ 10;
		              addEventHandler: (BlEventHandler
				               on: BlClickEvent
				               do: [ :anEvent | 
					               buttonPlay isVisible ifTrue: [ 
							               self isRunning ifFalse: [ 
	(MolUtils instanceOf: MATimeTravel named: #TimeTravel) ifNotNil: [ 
									               self getTMATimeTravelServicesProvider
										               isRestoring ifFalse: [ 
											               MASimulationManager playSimulation ]]ifNil:[MASimulationManager playSimulation ] ] ].
					               anEvent consumed: true ]).
	labelText := 'Play' asRopedText
		             foreground: Color black;
		             fontSize: 16;
		             fontName: 'Helvetica';
		             thin.
	label := BlTextElement new.
	label text: labelText.
	buttonPlay addChild: label.
	infoPanel addChild: buttonPlay.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding Stop button"
	button := BlElement new
		          background: Color red;
		          geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		          padding: (BlInsets
				           top: 8
				           right: 16
				           bottom: 8
				           left: 16);
		          layout: BlLinearLayout horizontal;
		          effect: (BlGaussianShadowEffect
				           color: (Color black alpha: 0.3)
				           width: 1
				           offset: 0 @ 2);
		          constraintsDo: [ :c | 
			          c horizontal fitContent.
			          c vertical fitContent ];
		          relocate:
			          MASimulationManager simulationWidth / 10 * 8 @ 10;
		          addEventHandler: (BlEventHandler
				           on: BlClickEvent
				           do: [ :anEvent | 
					           button isVisible ifTrue: [ 
							           MASimulationManager stopSimulation ].
					           anEvent consumed: true ]).
	labelText := 'Stop' asRopedText
		             foreground: Color black;
		             fontSize: 16;
		             fontName: 'Helvetica';
		             thin.
	label := BlTextElement new.
	label text: labelText.
	button addChild: label.
	infoPanel addChild: button.


	"Adding the text for refreshing."
	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 @ 55;
			  background: Color transparent) text:
			 'Refreshing the view every ' asRopedText).

	"Adding the 1 button"
	button := BlElement new.
	button background: Color gray.
	button size: 25 @ 20.
	button relocate: MASimulationManager simulationWidth / 10 + 200 @ 50.
	button addChild:
		((BlTextElement new relocate: 10 @ 5) text: '1' asRopedText).
	button addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button isVisible ifTrue: [ self setRefreshingTo: 1 ].
				 anEvent consumed: true ]).
	infoPanel addChild: button.

	"Adding the 2 button"
	button := BlElement new.
	button background: Color gray.
	button size: 25 @ 20.
	button relocate: MASimulationManager simulationWidth / 10 + 230 @ 50.
	button addChild:
		((BlTextElement new relocate: 10 @ 5) text: '2' asRopedText).
	button addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button isVisible ifTrue: [ self setRefreshingTo: 2 ].
				 anEvent consumed: true ]).
	infoPanel addChild: button.

	"Adding the 5 button"
	button := BlElement new.
	button background: Color gray.
	button size: 25 @ 20.
	button relocate: MASimulationManager simulationWidth / 10 + 260 @ 50.
	button addChild:
		((BlTextElement new relocate: 10 @ 5) text: '5' asRopedText).
	button addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button isVisible ifTrue: [ self setRefreshingTo: 5 ].
				 anEvent consumed: true ]).
	infoPanel addChild: button.

	"Adding the 10 button"
	button := BlElement new.
	button background: Color gray.
	button size: 35 @ 20.
	button relocate: MASimulationManager simulationWidth / 10 + 290 @ 50.
	button addChild:
		((BlTextElement new relocate: 10 @ 5) text: '10' asRopedText).
	button addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button isVisible ifTrue: [ self setRefreshingTo: 10 ].
				 anEvent consumed: true ]).
	infoPanel addChild: button.

	"Adding the 20 button"
	button := BlElement new.
	button background: Color gray.
	button size: 35 @ 20.
	button relocate: MASimulationManager simulationWidth / 10 + 330 @ 50.
	button addChild:
		((BlTextElement new relocate: 10 @ 5) text: '20' asRopedText).
	button addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button isVisible ifTrue: [ self setRefreshingTo: 20 ].
				 anEvent consumed: true ]).
	infoPanel addChild: button.

	"steps text"
	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 + 370 @ 55;
			  background: Color transparent) text: 'steps.' asRopedText).

	"Ajout de l'heure à l'interface."
	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 @ 80;
			  background: Color transparent) text: 'Step :' asRopedText).
	stepView := BlTextElement new
		            relocate: MASimulationManager simulationWidth / 10 @ 100;
		            background: Color transparent;
		            text: '000' asRopedText.
	infoPanel addChild: stepView.

	"Ajout du nombre de proies à l'interface."
	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 @ 130;
			  background: Color transparent) text:
			 'Number of insects :' asRopedText).
	nbInsectsView := BlTextElement new
		                 relocate:
			                 MASimulationManager simulationWidth / 10 @ 150;
		                 background: Color transparent;
		                 text: '000' asRopedText.
	infoPanel addChild: nbInsectsView.

	"Ajout du nombre de proies ramenées à l'interface."
	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 @ 180;
			  background: Color transparent) text:
			 'Number of insects delivered :' asRopedText).
	nbDeliveredView := BlTextElement new
		                   relocate:
			                   MASimulationManager simulationWidth / 10 @ 200;
		                   background: Color transparent;
		                   text: '000' asRopedText.
	infoPanel addChild: nbDeliveredView.

	"Ajout du nombre de pheromones à l'interface."
	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 * 5 @ 130;
			  background: Color transparent) text:
			 'Number of pheromones :' asRopedText).
	nbPheromonesView := BlTextElement new
		                    relocate:
			                    MASimulationManager simulationWidth / 10 * 5
			                    @ 150;
		                    background: Color transparent;
		                    text: '000' asRopedText.
	infoPanel addChild: nbPheromonesView.


	"Ajout du nombre de feedingPoints à l'interface."
	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 * 5 @ 180;
			  background: Color transparent) text:
			 'Number of feeding points :' asRopedText).
	nbFeedingPointView := BlTextElement new
		                      relocate:
			                      MASimulationManager simulationWidth / 10 * 5
			                      @ 200;
		                      background: Color transparent;
		                      text: '000' asRopedText.
	infoPanel addChild: nbFeedingPointView.


	"Ajout du nombre de fourmis à l'interface."
	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 * 5 @ 80;
			  background: Color transparent) text:
			 'Number of ants :' asRopedText).

	infoPanel addChild: ((BlTextElement new
			  relocate: MASimulationManager simulationWidth / 10 * 5 @ 100;
			  background: Color transparent) text: 'Eggs : ' asRopedText).
	nbEggsView := BlTextElement new
		              relocate:
			              MASimulationManager simulationWidth / 10 * 5 + 55
			              @ 100;
		              background: Color transparent;
		              text: '000' asRopedText.
	infoPanel addChild: nbEggsView.

	infoPanel addChild: ((BlTextElement new
			  relocate:
				  MASimulationManager simulationWidth / 10 * 5 + 100 @ 100;
			  background: Color transparent) text: 'Adults : ' asRopedText).
	nbAntsView := BlTextElement new
		              relocate:
			              MASimulationManager simulationWidth / 10 * 5 + 165
			              @ 100;
		              background: Color transparent;
		              text: '000' asRopedText.
	infoPanel addChild: nbAntsView
]

{ #category : #drawing }
MAGround >> drawOnSpartaCanvas: aCanvas [

	"Re writing this method here, in order to directly draw inside the canvas all the elements of the system. Tihs permit to keep good performances even if there is a lot of elements to draw."

	super drawOnSpartaCanvas: aCanvas.

	aCanvas figure
		path: (Rectangle
				 origin: MASimulationManager simulationAntHillPosition - (20 @ 20)
				 extent: 40 @ 40);
		background: Color white;
		draw.

	self getTMAPheromoneServicesProvider getPheromonesDict ifNotNil: [ 
		self getTMAPheromoneServicesProvider getPheromonesDict 
			keysAndValuesDo: [ :k :v | 
				aCanvas figure
					path: (aCanvas shape circleAt: k radius: 2);
					background: Color blue;
					backgroundAlpha:
						v value / self getTMAPheromoneServicesProvider getMaxIntensity;
					draw ] ].

	self getTMAPheromoneServicesProvider getPheromonesReturnDict 
		ifNotNil: [ 
			self getTMAPheromoneServicesProvider getPheromonesReturnDict 
				keysAndValuesDo: [ :k :v | 
					aCanvas figure
						path: (aCanvas shape circleAt: k radius: 2);
						background: Color cyan;
						backgroundAlpha:
							v / self getTMAPheromoneServicesProvider getMaxIntensity;
						draw ] ].

	self getInsects ifNotNil: [ 
		self getInsects keysAndValuesDo: [ :k :v | 
			aCanvas figure
				path: (aCanvas shape circleAt: k radius: 2);
				background: Color black;
				backgroundAlpha: 1;
				draw ] ].


	self getFeedingPoints ifNotNil: [ 
		self getFeedingPoints keysAndValuesDo: [ :k :v | 
			aCanvas figure
				path: (aCanvas shape circleAt: k radius: 10);
				background: Color purple;
				backgroundAlpha: 1;
				draw ] ].

	self getAnts ifNotNil: [ 
		self getAnts do: [ :ant | 
			ant ifNotNil: [ 
				ant getPosition ifNotNil: [ 
					ant getStageName ~= #egg
						ifTrue: [ 
							ant getRoleName = #queen ifTrue: [ 
								aCanvas figure
									path: (aCanvas shape circleAt: ant getPosition radius: 5);
									background: Color pink;
									backgroundAlpha: 1;
									draw ].
							ant getRoleName = #worker ifTrue: [ 
								aCanvas figure
									path: (aCanvas shape circleAt: ant getPosition radius: 3);
									background: Color orange;
									backgroundAlpha: 1;
									draw ].
							ant getRoleName = #fighter ifTrue: [ 
								aCanvas figure
									path: (aCanvas shape circleAt: ant getPosition radius: 3);
									background: Color green;
									backgroundAlpha: 1;
									draw ] ]
						ifFalse: [ 
							aCanvas figure
								path: (aCanvas shape circleAt: ant getPosition radius: 2);
								background: Color gray;
								backgroundAlpha: 1;
								draw ] ] ] ] ]
]

{ #category : #services }
MAGround >> getAnts [

	"Get all the MAAnt instances, in order to draw them on the canvas."

	^ self getTMASimulationServicesProvider getAnts
]

{ #category : #services }
MAGround >> getFeedingPoints [

	"Get all the MAFeedingPoint instances, in order to draw them on the canvas."

	^ self getTMASimulationServicesProvider getFeedingPoints
]

{ #category : #services }
MAGround >> getInsects [

	"Get all the MAInesct instances, in order to draw them on the canvas."

	^ self getTMASimulationServicesProvider getInsects
]

{ #category : #'component accessing' }
MAGround >> getTMAPheromoneServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TMAPheromoneServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TMAPheromoneServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #'component accessing' }
MAGround >> getTMASimulationServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TMASimulationServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TMASimulationServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #'component accessing' }
MAGround >> getTMASimulationToGlobalEventsSubscriber [
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
MAGround >> getTMATimeTravelEventsSubscriber [
	| eventsSymbol eventsSubscriber itf |
	itf := TMATimeTravelEvents.
	eventsSymbol := self eventsSubscribers at: itf ifAbsent: [^MolNotFoundEventsSubscriber new interface: itf name: nil].
	eventsSymbol isCollection
	 	ifTrue: 
			[eventsSubscriber := MolComponentManager default locatorServices 
						searchEventsSubscriberFor: TMATimeTravelEvents named: eventsSymbol ]. 
	^eventsSubscriber
]

{ #category : #'component accessing' }
MAGround >> getTMATimeTravelServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TMATimeTravelServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TMATimeTravelServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #initialization }
MAGround >> initialize [

	"Initialization of the ground"
	super initialize.
	self size: MASimulationManager simulationWidth
		@ MASimulationManager simulationHeight.
	self background: (Color fromHexString: 'c7baae')
]

{ #category : #services }
MAGround >> isRunning [

	^ self getTMASimulationServicesProvider isRunning. 
]

{ #category : #initialization }
MAGround >> setRefreshingTo: anInteger [

	"Changing the frequence of the view actualization."

	refreshing := anInteger
]

{ #category : #'events - lifecycle' }
MAGround >> simulationStepSent: aStep [


]

{ #category : #testing }
MAGround >> startViewLoop [

	"Starting the view loop."

	viewLoop := [ 
	            [ true ] whileTrue: [ 
		            | doUpdateView |
		            doUpdateView := true.
		            self getTMASimulationServicesProvider getStep
		            % refreshing = 0 ifFalse: [ doUpdateView := false ].

						
	(MolUtils instanceOf: MATimeTravel named: #TimeTravel) ifNotNil: [ 
		            self getTMATimeTravelServicesProvider isRestoring 
			            ifTrue: [ doUpdateView := true ]].

		            doUpdateView ifTrue: [ 
			            self updateView.
			            (Delay forMilliseconds:
				             MASimulationManager simulationStepDurationInMs) wait ] ] ] 
		            forkAt: Processor userBackgroundPriority.
	viewLoop name: 'Molecule ViewLoop Process'.
	viewLoop resume
]

{ #category : #'life cycle' }
MAGround >> stopViewLoop [

	viewLoop ifNil: [ ^ self ].
	viewLoop terminate.
	viewLoop := nil
]

{ #category : #initialization }
MAGround >> updateInfoPanel [

	"Modify each elements of the info panel. It permit to keep the view up to date with the simulation."

	| eggs |
	stepView text:
		self getTMASimulationServicesProvider getStep asRopedText.
	nbInsectsView text: self getInsects size asRopedText.
	nbDeliveredView text:
		self getTMASimulationServicesProvider getStorage asRopedText.
	nbPheromonesView text:
		(self getTMAPheromoneServicesProvider getPheromonesDict size
		 + self getTMAPheromoneServicesProvider getPheromonesReturnDict size)
			asRopedText.

	nbFeedingPointView text: self getFeedingPoints size asRopedText.

	eggs := 0.
	self getAnts do: [ :ant | 
		ant getStageName = #egg ifTrue: [ eggs := eggs + 1 ] ].
	nbEggsView text: eggs asRopedText.
	nbAntsView text: (self getAnts size - eggs) asRopedText.


	self getTMASimulationServicesProvider isRunning
		ifTrue: [ 
			buttonPlay background: Color gray.
			buttonPause background: Color orange ]
		ifFalse: [ 
			buttonPause background: Color gray.
	(MolUtils instanceOf: MATimeTravel named: #TimeTravel) ifNotNil: [ 
			self getTMATimeTravelServicesProvider isRestoring
				ifTrue: [ buttonPlay background: Color gray ]
				ifFalse: [ buttonPlay background: Color green ]]ifNil:[buttonPlay background: Color green.] ]
]

{ #category : #events }
MAGround >> updateView [

	self updateInfoPanel.
]