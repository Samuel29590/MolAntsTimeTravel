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
	#traits : 'MolComponentImpl + TMAGroundType + TMASimulationToGlobalEvents + TimeTravelEvents',
	#classTraits : 'MolComponentImpl classTrait + TMAGroundType classTrait + TMASimulationToGlobalEvents classTrait + TimeTravelEvents classTrait',
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
		'buttonPause',
		'mainScreen',
		'buttonStop',
		'button1',
		'button2',
		'button5',
		'button10',
		'button20',
		'stepsText',
		'refreshingText',
		'stepText',
		'nbInsectsText',
		'nbDeliveredText',
		'nbPheromonesText',
		'nbFeedingPointText',
		'nbAntsText',
		'nbOfAntsText',
		'eggText'
	],
	#category : #MolAntsTimeTravel
}

{ #category : #'life cycle' }
MAGround >> componentActivate [

	"Activation of the MAGround component."

	self getTMASimulationToGlobalEventsSubscriber subscribe: self.

	"--------------------------Time Travel--------------------------"
	"Subscription to the Time Travel event"
	self getTimeTravelEventsSubscriber subscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAGround >> componentInitialize [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ "Connection to the TimeTravel service."
		self forServices: TimeTravelServices useProvider: #default.
		"Subscription to the Time Travel event"
		self getTimeTravelEventsSubscriber subscribe: self.
		self getTimeTravelServicesProvider isRestoring ifFalse: [ "Component notifies its creation" 
			self getTimeTravelServicesProvider creationOf: self ] ].
	"---------------------------------------------------------------"

	"Initialization of the MAGround component."

	self forServices: TMASimulationServices useProvider: #default.
	self forServices: TMAPheromoneServices useProvider: #Pheromones.

	refreshing := 1.

	self createGround.

	self createInfoPanel.

	self startViewLoop.

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [
		self getTimeTravelServicesProvider isRestoring ifFalse: [ "Component saves its state." 
			self saveForTimeTravel ] ]
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAGround >> componentPassivate [

	"Passivating the MAGround component."

	self getTMASimulationToGlobalEventsSubscriber unsubscribe: self.
	
	"--------------------------Time Travel--------------------------"
	"Unsubscribe from the Time Travel event"
	self getTimeTravelEventsSubscriber unsubscribe: self.
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MAGround >> componentRemove [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifFalse: [
			"Component saves its state."
			self saveForTimeTravel.
			"Component notifies its deletion"
			self getTimeTravelServicesProvider deletionOf: self ] ].
	"---------------------------------------------------------------"

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
MAGround >> createGround [

	"Initialize the info panel of the view. It initialize each item of the panel (buttons, texts ...)."

	mySpace := BlSpace new
		           title: 'MolAnts Simulation';
		           extent: MASimulationManager simulationWidth
			           @ (MASimulationManager simulationHeight + 250);
		           show.
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	mainScreen := BlElement new
		              background: Color white;
		              constraintsDo: [ :c | 
			              c horizontal matchParent.
			              c vertical matchParent ];
		              zIndex: 1.
	mySpace addChild: mainScreen.
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	self
		background: (Color fromHexString: 'c7baae');
		margin: (BlInsets bottom: 250);
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ];
		zIndex: 2.
	mainScreen addChild: self
]

{ #category : #initialization }
MAGround >> createInfoPanel [

	"Initialize the info panel of the view. It initialize each item of the panel (buttons, texts ...)."

	| infoPanel labelText label |
	infoPanel := BlElement new
		             background: Color lightGray;
		             size: MASimulationManager simulationWidth @ 2150;
		             relocate: 0 @ MASimulationManager simulationHeight;
		             constraintsDo: [ :c | 
			             c maxHeight: 250.
			             c horizontal matchParent ];
		             zIndex: 3.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ infoPanel relocate: 0 @ (mainScreen size y - 250) ].
	mainScreen addChild: infoPanel.

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
		               addEventHandler: (BlEventHandler
				                on: BlClickEvent
				                do: [ :anEvent | 
					                buttonPause isVisible ifTrue: [ 
							                self getTMASimulationServicesProvider
								                pauseSimulation ].
					                anEvent consumed: true ]).
	labelText := 'Pause' asRopedText
		             foreground: Color black;
		             fontSize: 16;
		             thin.
	label := BlTextElement new.
	label text: labelText.
	buttonPause addChild: label.
	mainScreen addEventHandlerOn: BlElementExtentChangedEvent do: [ 
		buttonPause relocate:
			mainScreen size x / 3 - (buttonPause width / 2) @ 10 ].
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
		              relocate: mainScreen size x / 2 @ 10;
		              addEventHandler: (BlEventHandler
				               on: BlClickEvent
				               do: [ :anEvent | 
					               buttonPlay isVisible ifTrue: [ 
							               self getTMASimulationServicesProvider
								               playSimulation ].

					               anEvent consumed: true ]).
	labelText := 'Play' asRopedText
		             foreground: Color black;
		             fontSize: 16;
		             thin.
	label := BlTextElement new.
	label text: labelText.
	buttonPlay addChild: label.
	mainScreen addEventHandlerOn: BlElementExtentChangedEvent do: [ 
		buttonPlay relocate:
			mainScreen size x / 2 - (buttonPlay width / 2) @ 10 ].
	infoPanel addChild: buttonPlay.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding Stop button"
	buttonStop := BlElement new
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
		              relocate: mainScreen size x / 3 * 2 @ 10;
		              addEventHandler: (BlEventHandler
				               on: BlClickEvent
				               do: [ :anEvent | 
					               buttonStop isVisible ifTrue: [ 
							               MASimulationManager stopSimulation ].
					               anEvent consumed: true ]).
	labelText := 'Stop' asRopedText
		             foreground: Color black;
		             fontSize: 16;
		             thin.
	label := BlTextElement new.
	label text: labelText.
	buttonStop addChild: label.
	mainScreen addEventHandlerOn: BlElementExtentChangedEvent do: [ 
		buttonStop relocate:
			mainScreen size x / 3 * 2 - (buttonStop width / 2) @ 10 ].
	infoPanel addChild: buttonStop.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"

	"Adding the text for refreshing."
	refreshingText := (BlTextElement new
		                   relocate:
			                   MASimulationManager simulationWidth / 10 @ 55;
		                   background: Color transparent) text:
		                  'Refreshing the view every ' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ refreshingText relocate: mainScreen size x / 10 @ 55 ].
	infoPanel addChild: refreshingText.

	"Adding the 1 button"
	button1 := BlElement new.
	button1 background: Color gray.
	button1 size: 25 @ 20.
	button1 addChild:
		((BlTextElement new relocate: 10 @ 5) text: '1' asRopedText).
	button1 addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button1 isVisible ifTrue: [ self setRefreshingTo: 1 ].
				 anEvent consumed: true ]).
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button1 relocate: mainScreen size x / 10 + 200 @ 50 ].
	infoPanel addChild: button1.

	"Adding the 2 button"
	button2 := BlElement new.
	button2 background: Color gray.
	button2 size: 25 @ 20.
	button2 addChild:
		((BlTextElement new relocate: 10 @ 5) text: '2' asRopedText).
	button2 addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button2 isVisible ifTrue: [ self setRefreshingTo: 2 ].
				 anEvent consumed: true ]).
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button2 relocate: mainScreen size x / 10 + 230 @ 50 ].
	infoPanel addChild: button2.

	"Adding the 5 button"
	button5 := BlElement new.
	button5 background: Color gray.
	button5 size: 25 @ 20.
	button5 addChild:
		((BlTextElement new relocate: 10 @ 5) text: '5' asRopedText).
	button5 addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button5 isVisible ifTrue: [ self setRefreshingTo: 5 ].
				 anEvent consumed: true ]).
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button5 relocate: mainScreen size x / 10 + 260 @ 50 ].
	infoPanel addChild: button5.

	"Adding the 10 button"
	button10 := BlElement new.
	button10 background: Color gray.
	button10 size: 35 @ 20.
	button10 addChild:
		((BlTextElement new relocate: 10 @ 5) text: '10' asRopedText).
	button10 addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button10 isVisible ifTrue: [ self setRefreshingTo: 10 ].
				 anEvent consumed: true ]).
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button10 relocate: mainScreen size x / 10 + 290 @ 50 ].
	infoPanel addChild: button10.

	"Adding the 20 button"
	button20 := BlElement new.
	button20 background: Color gray.
	button20 size: 35 @ 20.
	button20 addChild:
		((BlTextElement new relocate: 10 @ 5) text: '20' asRopedText).
	button20 addEventHandler: (BlEventHandler
			 on: BlClickEvent
			 do: [ :anEvent | 
				 button20 isVisible ifTrue: [ self setRefreshingTo: 20 ].
				 anEvent consumed: true ]).
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button20 relocate: mainScreen size x / 10 + 330 @ 50 ].
	infoPanel addChild: button20.

	"steps text"
	stepsText := (BlTextElement new background: Color transparent) text:
		             'steps.' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ stepsText relocate: mainScreen size x / 10 + 370 @ 55 ].
	infoPanel addChild: stepsText.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"

	"Ajout de l'heure à l'interface."
	stepText := (BlTextElement new background: Color transparent) text:
		            'Step :' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ stepText relocate: mainScreen size x / 10 @ 80 ].
	infoPanel addChild: stepText.
	stepView := BlTextElement new
		            relocate: MASimulationManager simulationWidth / 10 @ 100;
		            background: Color transparent;
		            text: '000' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ stepView relocate: mainScreen size x / 10 @ 100 ].
	infoPanel addChild: stepView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"

	"Ajout du nombre de proies à l'interface."
	nbInsectsText := (BlTextElement new
		                  relocate:
			                  MASimulationManager simulationWidth / 10 @ 130;
		                  background: Color transparent) text:
		                 'Number of insects :' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbInsectsText relocate: mainScreen size x / 10 @ 130 ].
	infoPanel addChild: nbInsectsText.
	nbInsectsView := BlTextElement new
		                 relocate:
			                 MASimulationManager simulationWidth / 10 @ 150;
		                 background: Color transparent;
		                 text: '000' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbInsectsView relocate: mainScreen size x / 10 @ 150 ].
	infoPanel addChild: nbInsectsView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"

	"Ajout du nombre de proies ramenées à l'interface."
	nbDeliveredText := (BlTextElement new
		                    relocate:
			                    MASimulationManager simulationWidth / 10 @ 180;
		                    background: Color transparent) text:
		                   'Number of insects delivered :' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbDeliveredText relocate: mainScreen size x / 10 @ 180 ].
	infoPanel addChild: nbDeliveredText.
	nbDeliveredView := BlTextElement new
		                   relocate:
			                   MASimulationManager simulationWidth / 10 @ 200;
		                   background: Color transparent;
		                   text: '000' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbDeliveredView relocate: mainScreen size x / 10 @ 200 ].
	infoPanel addChild: nbDeliveredView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"

	"Ajout du nombre de pheromones à l'interface."
	nbPheromonesText := (BlTextElement new
		                     relocate:
			                     MASimulationManager simulationWidth / 10 * 5
			                     @ 130;
		                     background: Color transparent) text:
		                    'Number of pheromones :' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbPheromonesText relocate: mainScreen size x / 10 * 5 @ 130 ].
	infoPanel addChild: nbPheromonesText.
	nbPheromonesView := BlTextElement new
		                    relocate:
			                    MASimulationManager simulationWidth / 10 * 5
			                    @ 150;
		                    background: Color transparent;
		                    text: '000' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbPheromonesView relocate: mainScreen size x / 10 * 5 @ 150 ].
	infoPanel addChild: nbPheromonesView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"

	"Ajout du nombre de feedingPoints à l'interface."
	nbFeedingPointText := (BlTextElement new
		                       relocate:
			                       MASimulationManager simulationWidth / 10 * 5
			                       @ 180;
		                       background: Color transparent) text:
		                      'Number of feeding points :' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbFeedingPointText relocate: mainScreen size x / 10 * 5 @ 180 ].
	infoPanel addChild: nbFeedingPointText.
	nbFeedingPointView := BlTextElement new
		                      relocate:
			                      MASimulationManager simulationWidth / 10 * 5
			                      @ 200;
		                      background: Color transparent;
		                      text: '000' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbFeedingPointView relocate: mainScreen size x / 10 * 5 @ 200 ].
	infoPanel addChild: nbFeedingPointView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"

	"Ajout du nombre de fourmis à l'interface."
	nbOfAntsText := (BlTextElement new
		                 relocate:
			                 MASimulationManager simulationWidth / 10 * 5 @ 80;
		                 background: Color transparent) text:
		                'Number of ants :' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbOfAntsText relocate: mainScreen size x / 10 * 5 @ 80 ].
	infoPanel addChild: nbOfAntsText.

	eggText := BlTextElement new
		           relocate:
			           MASimulationManager simulationWidth / 10 * 5 @ 100;
		           background: Color transparent;
		           text: 'Eggs : ' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ eggText relocate: mainScreen size x / 10 * 5 @ 100 ].
	infoPanel addChild: eggText.
	nbEggsView := BlTextElement new
		              relocate:
			              MASimulationManager simulationWidth / 10 * 5 + 55
			              @ 100;
		              background: Color transparent;
		              text: '000' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbEggsView relocate: mainScreen size x / 10 * 5 + 55 @ 100 ].
	infoPanel addChild: nbEggsView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"

	nbAntsText := (BlTextElement new
		               relocate:
			               MASimulationManager simulationWidth / 10 * 5 + 100
			               @ 100;
		               background: Color transparent) text:
		              'Adults : ' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbAntsText relocate: mainScreen size x / 10 * 5 + 100 @ 100 ].
	infoPanel addChild: nbAntsText.
	nbAntsView := BlTextElement new
		              relocate:
			              MASimulationManager simulationWidth / 10 * 5 + 165
			              @ 100;
		              background: Color transparent;
		              text: '000' asRopedText.
	mainScreen
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ nbAntsView relocate: mainScreen size x / 10 * 5 + 165 @ 100 ].
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
		self getTMAPheromoneServicesProvider getPheromonesDict keysAndValuesDo: [ :k :v | 
			aCanvas figure
				path: (aCanvas shape circleAt: k radius: 2);
				background: Color blue;
				backgroundAlpha: v value / 100;
				draw ] ].

	self getTMAPheromoneServicesProvider getPheromonesReturnDict 
		ifNotNil: [ 
			self getTMAPheromoneServicesProvider getPheromonesReturnDict 
				keysAndValuesDo: [ :k :v | 
					aCanvas figure
						path: (aCanvas shape circleAt: k radius: 2);
						background: Color cyan;
						backgroundAlpha: v / 100;
						draw ] ].

	self getInsects ifNotNil: [ 
		self getInsects keysAndValuesDo: [ :k :v | 
			aCanvas figure
				path: (aCanvas shape circleAt: k radius: 2);
				background: Color black;
				draw ] ].

	self getFeedingPoints ifNotNil: [ 
		self getFeedingPoints keysAndValuesDo: [ :k :v | 
			aCanvas figure
				path: (aCanvas shape circleAt: k radius: 10);
				background: Color purple;
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
									draw ].
							ant getRoleName = #worker ifTrue: [ 
								aCanvas figure
									path: (aCanvas shape circleAt: ant getPosition radius: 3);
									background: Color orange;
									draw ].
							ant getRoleName = #fighter ifTrue: [ 
								aCanvas figure
									path: (aCanvas shape circleAt: ant getPosition radius: 3);
									background: Color green;
									draw ] ]
						ifFalse: [ 
							aCanvas figure
								path: (aCanvas shape circleAt: ant getPosition radius: 2);
								background: Color gray;
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
MAGround >> getTimeTravelEventsSubscriber [
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
MAGround >> getTimeTravelServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TimeTravelServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TimeTravelServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #services }
MAGround >> isRunning [

	^ self getTMASimulationServicesProvider isRunning. 
]

{ #category : #events }
MAGround >> restoreFrom: aMemento [

	
]

{ #category : #events }
MAGround >> saveForTimeTravel [

	| memento |
	memento := MolGroundMemento new.

	self getTimeTravelServicesProvider
		save: (memento save: self)
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


		            (MolUtils instanceOf: MolTimeTravel named: #default) 
			            ifNotNil: [ 
				            self getTimeTravelServicesProvider isRestoring 
					            ifTrue: [ doUpdateView := true ] ].

		            doUpdateView ifTrue: [ 
			            self updateView.
			            (Delay forMilliseconds:
				             50) wait ] ] ] 
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

{ #category : #'events - control' }
MAGround >> stopped [

	self class stop: self componentName.
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

	self getTMAPheromoneServicesProvider getPheromonesDict
		ifNil: [ nbPheromonesView text: 0 asRopedText ]
		ifNotNil: [ 
			nbPheromonesView text:
				(self getTMAPheromoneServicesProvider getPheromonesDict size
				 +
				 self getTMAPheromoneServicesProvider getPheromonesReturnDict size)
					asRopedText ].

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
			(MolUtils instanceOf: MolTimeTravel named: #default)
				ifNotNil: [ 
					self getTimeTravelServicesProvider isRestoring
						ifTrue: [ buttonPlay background: Color gray ]
						ifFalse: [ buttonPlay background: Color green ] ]
				ifNil: [ buttonPlay background: Color green ] ]
]

{ #category : #'life cycle' }
MAGround >> updateView [

	self getTMASimulationServicesProvider getStep % refreshing = 0 ifTrue:[
		self updateInfoPanel ].
]
