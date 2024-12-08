## My coding / designing thoughts Part II


### Listeners, Threading, Channels

#### A few definitions of the things first

##### Listeners

Listeners per definition listen waiting for events of different kinds
In best case the listener runs in another thread when the code which fires the event.

One case where listeners can be used is testing:

Think about the following situation:

The Test runs in a JUNIT framework ok in a test different events can take place 
Lets have a look to a example test to see what I mean:

```Java

@BeforeEach
public void beforeEach() {
  /* do some init for the test that follows */
}

@AfterEach
public void afterEach() {
/* exit stuff */
}

@Test
public void myTest () {
/*
-record begin test (with clock) 
- test
-assertions
*/
-record end test (with clock)
}
```

And a assert 

```Java
try {
	assertThat("went wrong ",b, is(a));
	// record all ok
} catch (Throwable e) {
	// record went wrong
} finally {
	// record event checked
}

```

Ok now we write out or log events for example but the time it is logged the test will block eventually.

What we done was to write a GUI which had a progress bar and a test and assert ... counter if the record this things in the way above the whole GUI and the tests will block and it will be not possible to write a automation were more than one test runs in parallel there will all times be a blocking state at least in one thread.

So we have to think about a threaded listener concept:

##### Listener How TO: 

At first we have to think about how we define a listener

Here a thought abot that in Java code

- This may be a base interface

```Java

public interface ListenerBase {

	default void startProcess (TESTID testId) {
		System.out.println("Start test-run with testId: " + testId.testId() + " and type: " + testId.type());
	}

	default void endProcess (TESTID testId) {
		System.out.println("End test-run with testId: " + testId.testId() + " and type: " + testId.type());
	}

	public static class TESTRUNID {

		private final TESTTYPE type;

		private final UUID tesRuntId;

		private final String testRunName;

		public PID (String testRunName, TESTTYPE type) {
			this.testRunName = testRunName;
			this.pid = UUID.randomUUID(); 
			this.type = type;		
		}

		public UUID testId() {
			return this.testId;		
		} 

		public TESTTYPE type() {
			return this.type;
		}

	}

	public static class TESTID {

		private final TESTTYPE type;

		private final UUID testId;

		private final Class<?> testClass;

		private final Method testMethod;

		public PID (Class<?> testClass, Method testMethod, 
					TESTTYPE type) {
			this.testClass = testClass;
			this.testMethod = testMethod;
			this.testId = UUID.randomUUID(); 
			this.type = type;		
		}

		public UUID testId() {
			return this.testId;		
		} 

		public TESTTYPE type() {
			return this.type;
		}

	}




	public enum TESTTYPE {
		TESTRUN,
		TEST,
		FUN_TEST,
		UNIT_TEST,
		PERF_TEST,
		COMPONENT_TEST,;

	}
}
```


- and now for the test a listener Interface

```Java

public interface TestEventListener extends ListenerBase {

	void beforeAllEvent (TESTRUNID testId);

	void afterAllEvent (TESTRUNID testId);

	void beforeEachEvent (TESTID testId);

	void afterEachEvent (TESTID testId);

	void startTestEvent (TESTID testId);

	void finishTestEvent (TESTID testId);
/* and so on............. */

}
```  
**RESUME:**
This all is done in a way that we build up a registry for our listeners with the different listener types in the main thread and a listener of the specific type simply implements the listener interface for this type see above **_TestEventListener_** .

Now we can write a fire event submitting an event to our test listner engine running in one ore more separate threads.

##### The Threading

Now it is well done that we like to have a look at threads in that place:

One simple Thread:

```Java

public class AllINOne {

	public static AllINOne instance = null;

	private final Thread myThread;

	public AllINOne() {
		this.myThread = new Thread(
		new Runnable {
			public void run () {
				/* something is done */
			}
		});
	}

	public Thread myThread() {		
		return this.myThread; 
	}

	public static long startMe() {
		if (instance != null) {
			instance = new AllINOne();
		}
		instance.myThread().start();
		return instance.myThread().getId(); 
	}

		
	public static AllINOne instance() {
		if (instance != null) {
			instance = new AllINOne();
		}		
		return instance;
	}

	public static main(String[] args) {
		AllINOne singleInst = AllINOne.instance();
		Thread theThread = singleInst.myThread();
		long tid = AllINOne.startMe();
		theThread.join(); // do not stop until thread ends
	}

	
}
```


##### The channeling

At first a small definition of a ThreadLocal you will see

```Java
public class ThreadPipe {
    // Thread local variable containing each thread's ID
    private static final ThreadLocal<PipeReader> thePipeReader =
         new ThreadLocal<PipeReader>() {
             @Override protected PipeReader initialValue() {
                 return new PipeReader();
         }
     };

     // Returns the current thread's unique ID, assigning it if necessary
     public static PipeReader get() {
         return thePipeReader.get();
     }
 }
```

This PipeReader is used by the Thread to get Commands

```Java


public ChannelThread imnplements Runnable {

	public final PipeWriter pWriter = new PipeWriter(); 

	public ChannelThread() {}

	public PipeWriter pWriter() {
		return this.pWriter;
	}
	
	public void run() {
		PipeReader pReader = null;
		try {
			 pReader = ThreadPipe.get(); // get the pipe via threadLocal
			pReader.connect(pWriter);
			Integer readRes = pReader.read();
			while (readRes != -1) {
				/*process thing*/
				readRes = pReader.read();
			}
		} finally {
			if (pReader != null ) {
				pReader.close();
			}
		}
		
	}

}
```

More about threads and channels will follow in a later thoughts-report

- Harald G.P. IT-Consulting / Project Support
- 03.05.1966 Computer Sience since 1992

- &copy; Harald Glab-Plhak (2024)