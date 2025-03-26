/**
 * Simple class factory to allow mocking in tests. In order for a class to be
 * mockable it must delegate all object creation to this factory and provide
 * a default (empty) contstructor.
 *
 * <code>
 * public class MyClass {
 *     public static MyClass newInstance() {
 *         return (MyClass) Factory.newInstanceOf(MyClass.class);
 *     }
 *     public MyClass() {
 *         //custom init logic
 *     }
 * }
 * </code>
 *
 * Any unit test can then mock the class:
 *
 * <code>
 * @IsTest
 * static void myClassGetsMocked() {
 *     MyClass myClassMock = // build a stub object for your class;
 *     Factory.setMock(MyClass.class, myClassMock);
 *
 *     MyClass myClassInstance = MyClass.newInstance();
 *     //myClassInstance is now the stub instead
 * }
 * </code>
 */
global inherited sharing class Factory {
	private static Map<Type, Object> typeToMockImplementation = new Map<Type, Object>();

	/**
	 * @return new instance of the given type or a Stub/Mock instance if one of previously registered
	 */
	global static Object newInstanceOf(Type requestedType) {
		if (typeToMockImplementation.containsKey(requestedType)) {
			return typeToMockImplementation.get(requestedType);
		}

		return requestedType.newInstance();
	}

	/**
	 * Register stub/mock object for a given Type. Any calls to Factory.newInstance()
	 * with the same type will return this stub/mock instead of creating a new instance of
	 * the given type.
	 * @throws FactoryException when called outside of unit test context
	 */
	global static void setMock(Type mockedType, Object mockImplementation) {
		if (!Test.isRunningTest()) {
			//private cannot be namesapce accessible, this is alternative safecheck for use only in test
			throw new FactoryException('Cannot set mock outside of @IsTest');
		}
		typeToMockImplementation.put(mockedType, mockImplementation);
	}

	/**
	 * Register stob/mock object for a given Type. Any calls to Factory.newInstance()
	 * with the same type will return this stub/mock instead of creating a new instance of
	 * the given type.
	 * @throws FactoryException when called outside of unit test context
	 */
	global static void stubAndSetMock(Type mockedType, System.StubProvider stubProviderImplementation) {
		if (!Test.isRunningTest()) {
			//private cannot be namesapce accessible, this is alternative safecheck for use only in test
			throw new FactoryException('Cannot set mock outside of @IsTest');
		}
		Object stubObject = Test.createStub(mockedType, stubProviderImplementation);
		setMock(mockedType, stubObject);
	}

	private class FactoryException extends Exception {
	}
}
