@IsTest
public class ControllerTest {
	@IsTest
	static void mockNamespacedServiceWithProviderFromSameNamespaceStubInTheSameNamespace() {
		packocz2.UniversalMocker mockService = packocz2.UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.setMock(packocz2.Service.class, mockService.createStub());

		String result = Controller.callNamespace1Service();
		Assert.areEqual('mocked service', result);
	}

	@IsTest
	static void cannotMockNamespacedServiceWithProviderFromSameNamespaceStubLocally() {
		packocz2.UniversalMocker mockService = packocz2.UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.setMock(packocz2.Service.class, Test.createStub(packocz2.Service.class, mockService));

		String result = Controller.callNamespace1Service();
		Assert.areEqual('mocked service', result);
	}

	@IsTest
	static void mockNamespacedServiceWithProviderFromAnotherNamespaceStubInTheSameNamespace() {
		packocz.UniversalMocker mockService = packocz.UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.stubAndSetMock(packocz2.Service.class, mockService);

		String result = Controller.callNamespace1Service();
		Assert.areEqual('mocked service', result);
	}

	@IsTest
	static void cannotMockNamespacedServiceWithProviderFromAnotherNamespaceStubLocally() {
		packocz.UniversalMocker mockService = packocz.UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.setMock(packocz2.Service.class, Test.createStub(packocz2.Service.class, mockService));

		String result = Controller.callNamespace1Service();
		Assert.areEqual('mocked service', result);
	}

	@IsTest
	static void cannotMockNamespacedServiceWithProviderFromAnotherNamespaceStubInProviderNamespace() {
		packocz.UniversalMocker mockService = packocz.UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.setMock(packocz2.Service.class, packocz.Stubber.stub(packocz2.Service.class, mockService));

		String result = Controller.callNamespace1Service();
		Assert.areEqual('mocked service', result);
	}

	@IsTest
	static void cannotMockNamespacedServiceWithLocalProviderStubAnotherNamespace() {
		UniversalMocker mockService = UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.setMock(packocz2.Service.class, packocz.Stubber.stub(packocz2.Service.class, mockService));

		String result = Controller.callNamespace1Service();
		Assert.areEqual('mocked service', result);
	}

	@IsTest
	static void mockLocalServiceWithLocalProviderStubLocally() {
		UniversalMocker mockService = UniversalMocker.mock(Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.setMock(Service.class, Test.createStub(Service.class, mockService));

		String result = Controller.callLocalService();
		Assert.areEqual('mocked service', result);
	}

	@IsTest
	static void mockLocalServiceWithProviderFromNamespaceStubLocally() {
		packocz2.UniversalMocker mockService = packocz2.UniversalMocker.mock(Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.setMock(Service.class, Test.createStub(Service.class, mockService));

		String result = Controller.callLocalService();
		Assert.areEqual('mocked service', result);
	}

	@IsTest
	static void cannotMockLocalServiceWithProviderFromNamespaceStubInAnotherNamespace() {
		packocz2.UniversalMocker mockService = packocz2.UniversalMocker.mock(Service.class);
		mockService.when('method').thenReturn('mocked service');
		packocz2.Factory.setMock(Service.class, packocz.Stubber.stub(Service.class, mockService));

		String result = Controller.callLocalService();
		Assert.areEqual('mocked service', result);
	}
}
