/*
  PureMVC AS3 Utility - StateMachine
  Copyright (c) 2008 Neil Manuell, Cliff Hall
  Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
 package org.puremvc.as3.multicore.utilities.statemachine
{
	import org.puremvc.as3.multicore.patterns.observer.Notifier;
	
	/**
	 * Creates and registers a StateMachine described in XML.
	 * 
	 * <P>
	 * This allows reconfiguration of the StateMachine 
	 * without changing any code, as well as making it 
	 * easier than creating all the <code>State</code> 
	 * instances and registering them with the 
	 * <code>StateMachine</code> at startup time.
	 * 
	 * @ see State
	 * @ see StateMachine
	 */
	public class FSMInjector extends Notifier
	{
		/**
		 * Constructor.
		 */
		public function FSMInjector( fsm:XML ) 
		{
			this.fsm = fsm;
		}
		
		/**
		 * Inject the <code>StateMachine</code> into the PureMVC apparatus.
		 * <P>
		 * Creates the <code>StateMachine</code> instance, registers all the states
		 * and registers the <code>StateMachine</code> with the <code>IFacade</code>.
		 */
		public function inject():void
		{
			// Create the StateMachine
			var stateMachine:StateMachine = new StateMachine();
			
			// Register all the states with the StateMachine
			for each ( var state:State in states )
			{ 
				stateMachine.registerState( state, isInitial( state.name ) );
			}				
			
			// Register the StateMachine with the facade
			facade.registerMediator( stateMachine );
		}

		
		/**
		 * Get the state definitions.
		 * <P>
		 * Creates and returns the array of State objects 
		 * from the FSM on first call, subsequently returns
		 * the existing array.</P>
		 */
		protected function get states():Array
		{
			if (stateList == null) {
				stateList = new Array();
				var stateDefs:XMLList = fsm..state;
				for (var i:int; i<stateDefs.length(); i++)
				{
					var stateDef:XML = stateDefs[i];
					var state:State = createState( stateDef );
					stateList.push(state);
				}
			} 
			return stateList;
		}

		/**
		 * Creates a <code>State</code> instance from its XML definition.
 		 */
		protected function createState( stateDef:XML ):State
		{
			// Create State object
			var name:String = stateDef.@name.toString();
			var exiting:String = stateDef.@exiting.toString();
			var entering:String = stateDef.@entering.toString();
			var state:State = new State( name, entering, exiting );
			
			// Create transitions
			var transitions:XMLList = stateDef..transition as XMLList;
			for (var i:int; i<transitions.length(); i++)
			{
				var transDef:XML = transitions[i];
				state.defineTrans( String(transDef.@action), String(transDef.@target) );
			}
			return state;
		}

		/**
		 * Is the given state the initial state?
		 */
		protected function isInitial( stateName:String ):Boolean
		{
			var initial:String = XML(fsm.@initial).toString();
			return (stateName == initial);
		}
		
		// The XML FSM definition
		protected var fsm:XML;
		
		// The List of State objects
		protected var stateList:Array;
	}
}