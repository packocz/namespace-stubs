/************************************************************

*** @author: Suraj Pillai
*** @group: Test Class
*** @date: 01/2020
*** @description: A universal class for mocking in tests. Contains a method for setting the return value for any method. Another method returns the number of times a method was called. https://github.com/surajp/universalmock

*/
@SuppressWarnings(
	'PMD.TooManyFields, PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.MethodNamingConventions, PMD.ApexDoc, PMD.ExcessiveParameterList'
)
@IsTest
global with sharing class UniversalMocker implements System.StubProvider {
	// Map of methodName+paramTypes -> map of (paramname,value) for each invocation
	private final Map<String, List<Map<String, Object>>> argumentsMap = new Map<String, List<Map<String, Object>>>();
	private final Type mockedClass;
	private final Map<String, Object> mocksMap = new Map<String, Object>();
	private final Map<String, List<Integer>> returnUntilMap = new Map<String, List<Integer>>();
	private final Map<String, Integer> callCountsMap = new Map<String, Integer>();

	public static final Map<String, UniversalMocker> MOCK_INSTANCES = new Map<String, UniversalMocker>();
	private static final String KEY_DELIMITER = '||';

	//even though the 'guid' we are generating is a long (using Crypto.getRandomLong), we keep this a string, to make it easier if we need to switch to an actual guid in the future, and it isn't really costing us anything
	private String guidString;

	private String currentMethodName;
	private String currentParamTypesString;
	private Integer expectedCallCount;
	private Integer forInvocationNumber = 0;
	private Integer callCountToMock = null;

	//Map for storing mutators
	Map<String, List<Mutator>> mutatorMap = new Map<String, List<Mutator>>();

	// Inner class instances
	private InitialSetupState setupAInstance;
	private InitialValidationState assertAInstance;
	private IntermediateValidationState assertBInstance;
	private InitialParamValidationState getParamsAInstance;

	private enum Modes {
		SETUP,
		ASSERT,
		GETPARAMS
	}

	/* Begin Public Methods */

	global enum Times {
		OR_LESS,
		OR_MORE,
		EXACTLY
	}

	global static UniversalMocker mock(Type mockedClass) {
		UniversalMocker uMock = new UniversalMocker(mockedClass);
		MOCK_INSTANCES.put(uMock.guidString, uMock);
		return uMock;
	}

	global Object createStub() {
		return Test.createStub(this.mockedClass, this);
	}

	global class InitialSetupState extends IntermediateSetupState {
		private InitialSetupState(UniversalMocker parent) {
			super(parent);
		}
		global IntermediateSetupState withParamTypes(List<Type> paramTypes) {
			this.parent.withParamTypes(paramTypes);
			return (IntermediateSetupState) this;
		}
	}

	global virtual class IntermediateSetupState extends FinalSetupState {
		private IntermediateSetupState(UniversalMocker parent) {
			super(parent);
		}
		global FinalSetupState mutateWith(Mutator mutatorInstance) {
			this.parent.mutateWith(mutatorInstance);
			return (FinalSetupState) this;
		}
	}

	global virtual class FinalSetupState {
		private final UniversalMocker parent;
		private FinalSetupState(UniversalMocker parent) {
			this.parent = parent;
		}
		global void thenReturnVoid() {
			this.parent.thenReturnVoid();
		}
		global void thenReturn(Object returnObject) {
			this.parent.thenReturn(returnObject);
		}
		global void thenThrow(Exception exceptionToThrow) {
			this.parent.thenThrow(exceptionToThrow);
		}
		global FinalSetupState thenReturnUntil(Integer callCount, Object returnObject) {
			this.parent.thenReturnUntil(callCount, returnObject);
			return this;
		}
		global FinalSetupState thenThrowUntil(Integer callCount, Exception exceptionToThrow) {
			this.parent.thenThrowUntil(callCount, exceptionToThrow);
			return this;
		}
	}

	global class InitialValidationState {
		private final UniversalMocker parent;
		private InitialValidationState(UniversalMocker parent) {
			this.parent = parent;
		}
		global IntermediateValidationState method(String methodName) {
			parent.method(methodName);
			return parent.assertBInstance;
		}
	}

	global class IntermediateValidationState extends FinalValidationState {
		private IntermediateValidationState(UniversalMocker parent) {
			super(parent);
		}
		global FinalValidationState withParamTypes(List<Type> paramTypes) {
			parent.withParamTypes(paramTypes);
			return (FinalValidationState) this;
		}
	}

	global virtual class FinalValidationState {
		private final UniversalMocker parent;
		private FinalValidationState(UniversalMocker parent) {
			this.parent = parent;
		}
		global void wasCalled(Integer expectedCallCount, Times assertTypeValue) {
			parent.wasCalled(expectedCallCount, assertTypeValue);
		}
		global void wasCalled(Integer expectedCallCount) {
			parent.wasCalled(expectedCallCount);
		}
		global void wasNeverCalled() {
			parent.wasNeverCalled();
		}
	}

	global class InitialParamValidationState extends IntermediateParamValidationState {
		private InitialParamValidationState(UniversalMocker parent) {
			super(parent);
		}
		global IntermediateParamValidationState withParamTypes(List<Type> paramTypes) {
			parent.withParamTypes(paramTypes);
			return (IntermediateParamValidationState) this;
		}
	}

	global virtual class IntermediateParamValidationState extends FinalParamValidationState {
		private IntermediateParamValidationState(UniversalMocker parent) {
			super(parent);
		}
		global FinalParamValidationState andInvocationNumber(Integer invocation) {
			parent.andInvocationNumber(invocation);
			return (FinalParamValidationState) this;
		}
	}

	global virtual class FinalParamValidationState {
		private final UniversalMocker parent;
		private FinalParamValidationState(UniversalMocker parent) {
			this.parent = parent;
		}
		global Object getValueOf(String paramName) {
			return parent.getValueOf(paramName);
		}
		global Map<String, Object> getArgumentsMap() {
			return parent.getArgumentsMap();
		}
	}

	global InitialSetupState when(String stubbedMethodName) {
		this.reset();
		this.currentMethodName = stubbedMethodName;
		return this.setupAInstance;
	}

	global Object handleMethodCall(
		Object stubbedObject,
		String stubbedMethodName,
		Type returnType, //currently unused
		List<Type> listOfParamTypes,
		List<String> listOfParamNames,
		List<Object> listOfArgs
	) {
		String keyInUse = this.determineKeyToUseForCurrentStubbedMethod(stubbedMethodName, listOfParamTypes);
		this.incrementCallCount(keyInUse);
		this.saveArguments(listOfParamNames, listOfArgs, keyInUse);

		if (this.mutatorMap.containsKey(keyInUse)) {
			for (Mutator m : this.mutatorMap.get(keyInUse)) {
				m.mutate(stubbedObject, stubbedMethodName, listOfParamTypes, listOfArgs);
			}
		}

		Object returnValue = this.getMockValue(keyInUse);
		if (returnValue instanceof Exception) {
			throw (Exception) returnValue;
		}
		this.copyState(); //for async calls, we store the current object instance in a static map so the state is preserved even after leaving the async context
		return returnValue;
	}

	global InitialValidationState assertThat() {
		this.reset();
		return this.assertAInstance;
	}

	global InitialParamValidationState forMethod(String stubbedMethodName) {
		this.reset();
		this.currentMethodName = stubbedMethodName;
		return this.getParamsAInstance;
	}

	public class InvalidOperationException extends Exception {
	}

	global interface Mutator {
		void mutate(Object stubbedObject, String stubbedMethodName, List<Type> listOfParamTypes, List<Object> listOfArgs);
	}

	/* End Public methods */

	/* Begin Private methods */

	private void withParamTypes(List<Type> paramTypes) {
		this.currentParamTypesString = this.getParamTypesString(paramTypes);
	}

	private void mutateWith(Mutator mutatorInstance) {
		String key = this.getCurrentKey();
		if (this.mutatorMap.containsKey(key)) {
			this.mutatorMap.get(key).add(mutatorInstance);
		} else {
			this.mutatorMap.put(key, new List<Mutator>{ mutatorInstance });
		}
		if (!this.callCountsMap.containsKey(key)) {
			this.callCountsMap.put(key, 0);
		}
	}

	private void thenReturnVoid() {
		this.thenReturn(null);
	}

	private void thenReturn(Object returnObject) {
		String key = this.getCurrentKey();
		this.putMockValue(key, returnObject);
		if (!this.callCountsMap.containsKey(key)) {
			this.callCountsMap.put(key, 0);
		}
		if (this.callCountToMock != null) {
			this.callCountToMock = null;
		}
	}

	private void thenReturnUntil(Integer callCount, Object returnObject) {
		this.callCountToMock = callCount;
		this.thenReturn(returnObject);
	}

	private void thenThrowUntil(Integer callCount, Exception exceptionToThrow) {
		this.callCountToMock = callCount;
		this.thenReturn(exceptionToThrow);
	}

	private void thenThrow(Exception exceptionToThrow) {
		this.thenReturn(exceptionToThrow);
	}

	private void method(String methodName) {
		this.currentMethodName = methodName;
	}

	private void wasCalled(Integer expectedCallCount) {
		wasCalled(expectedCallCount, UniversalMocker.Times.EXACTLY);
	}

	private void wasCalled(Integer expectedCallCount, Times assertTypeValue) {
		this.expectedCallCount = expectedCallCount;
		String currentKey = this.getCurrentKey();

		Integer actualCallCount = this.getCallCountsMapInternal().get(currentKey);
		String methodName = this.currentMethodName;
		switch on assertTypeValue {
			when OR_LESS {
				system.assert(
					this.expectedCallCount >= actualCallCount,
					this.getMethodCallCountAssertMessage(methodName, 'less than or equal')
				);
			}
			when OR_MORE {
				system.assert(
					this.expectedCallCount <= actualCallCount,
					this.getMethodCallCountAssertMessage(methodName, 'more than or equal')
				);
			}
			when else {
				system.assertEquals(this.expectedCallCount, actualCallCount, this.getMethodCallCountAssertMessage(methodName, 'equal'));
			}
		}
	}

	private void wasNeverCalled() {
		String currentKey = this.getCurrentKey();
		Integer actualCallCount = this.getCallCountsMapInternal().get(currentKey);
		String methodName = this.currentMethodName;
		if (actualCallCount != null) {
			this.expectedCallCount = 0;
			System.assertEquals(
				this.expectedCallCount,
				actualCallCount,
				String.format('Method {0} was called 1 or more times', new List<String>{ methodName })
			);
		}
	}

	private void andInvocationNumber(Integer invocation) {
		this.forInvocationNumber = invocation;
	}

	private Object getValueOf(String paramName) {
		String theKey = this.getCurrentKey();
		Map<String, Object> paramsMap = this.getArgumentsMapInternal().get(theKey).get(this.forInvocationNumber);
		if (!paramsMap.containsKey(paramName.toLowerCase())) {
			throw new IllegalArgumentException(
				String.format('Param name {0} not found for the method {1}', new List<Object>{ paramName, this.currentMethodName })
			);
		}
		Object returnValue = paramsMap.get(paramName.toLowerCase());
		return returnValue;
	}

	private Map<String, Object> getArgumentsMap() {
		String theKey = this.getCurrentKey();
		Map<String, Object> returnValue = this.getArgumentsMapInternal().get(theKey).get(this.forInvocationNumber);
		return returnValue;
	}

	private String getCurrentKey() {
		String retVal = this.currentMethodName;
		if (!String.isEmpty(this.currentParamTypesString)) {
			retVal += KEY_DELIMITER + this.currentParamTypesString;
		}
		return retVal.toLowerCase();
	}

	private String getKey(String methodName, List<Type> paramTypes) {
		return (methodName + KEY_DELIMITER + this.getParamTypesString(paramTypes)).toLowerCase();
	}

	private Object getMockValue(String key) {
		if (this.returnUntilMap.containsKey(key)) {
			Integer callCount = this.callCountsMap.get(key);
			List<Integer> returnUntilList = this.returnUntilMap.get(key);
			returnUntilList.sort();
			for (Integer returnUntil : returnUntilList) {
				if (returnUntil >= callCount) {
					return this.mocksMap.get(key + '-' + returnUntil);
				}
			}
		}
		return this.mocksMap.get(key);
	}

	private void putMockValue(String key, Object value) {
		if (this.callCountToMock != null) {
			if (!this.returnUntilMap.containsKey(key)) {
				this.returnUntilMap.put(key, new List<Integer>{});
			}
			this.returnUntilMap.get(key).add(this.callCountToMock);
			this.mocksMap.put(key + '-' + this.callCountToMock, value);
		} else {
			this.mocksMap.put(key, value);
		}
	}

	private String getParamTypesString(List<Type> paramTypes) {
		String[] classNames = new List<String>{};
		for (Type paramType : paramTypes) {
			classNames.add(paramType.getName());
		}
		return String.join(classNames, '-');
	}

	private String determineKeyToUseForCurrentStubbedMethod(String stubbedMethodName, List<Type> listOfParamTypes) {
		String keyWithParamTypes = this.getKey(stubbedMethodName, listOfParamTypes);
		return this.callCountsMap.containsKey(keyWithParamTypes) ? keyWithParamTypes : stubbedMethodName.toLowerCase();
	}

	private void incrementCallCount(String key) {
		Integer count = this.callCountsMap.containsKey(key) ? this.callCountsMap.get(key) : 0;
		this.callCountsMap.put(key, count + 1);
	}

	private void saveArguments(List<String> listOfParamNames, List<Object> listOfArgs, String key) {
		Map<String, Object> currentArgsMap = new Map<String, Object>();
		if (!this.argumentsMap.containsKey(key)) {
			this.argumentsMap.put(key, new List<Map<String, Object>>{ currentArgsMap });
		} else {
			this.argumentsMap.get(key).add(currentArgsMap);
		}

		for (Integer i = 0; i < listOfParamNames.size(); i++) {
			currentArgsMap.put(listOfParamNames[i].toLowerCase(), listOfArgs[i]);
		}
	}

	private String getMethodCallCountAssertMessage(String methodName, String comparison) {
		return String.format(
			'Expected call count for method {0} is not {1} to the actual count',
			new List<String>{ methodName, comparison }
		);
	}

	private Map<String, Integer> getCallCountsMapInternal() {
		return MOCK_INSTANCES.get(this.guidString).callCountsMap;
	}

	private Map<String, List<Map<String, Object>>> getArgumentsMapInternal() {
		return MOCK_INSTANCES.get(this.guidString).argumentsMap;
	}

	private void copyState() {
		MOCK_INSTANCES.put(this.guidString, this);
	}

	private UniversalMocker(Type mockedClass) {
		this.mockedClass = mockedClass;
		this.guidString = this.getGUID();
		this.initInnerClassInstances();
	}

	private String getGUID() {
		String guidString = Crypto.getRandomLong() + ''; // since guid generation is expensive, we "settle" for this, as it generates unique values and is performant
		return guidString;
	}

	private void initInnerClassInstances() {
		this.setupAInstance = new InitialSetupState(this);
		this.assertAInstance = new InitialValidationState(this);
		this.assertBInstance = new IntermediateValidationState(this);
		this.getParamsAInstance = new InitialParamValidationState(this);
	}

	private void reset() {
		this.currentParamTypesString = '';
		this.currentMethodName = '';
		this.forInvocationNumber = 0;
	}

	/* End  Private Methods */
}
