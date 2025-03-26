global with sharing class Stubber {
	global static Object stub(Type stubbedType, System.StubProvider mockImplementation) {
		return Test.createStub(stubbedType, mockImplementation);
	}
}
