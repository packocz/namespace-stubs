@IsTest
public class ControllerTest {
	@IsTest
	static void mockNamespacedServiceWithProviderFromSameNamespaceStubHere() {
		packocz2.UniversalMocker mockService = packocz2.UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('packocz2.UniversalMocker.Service');
		packocz2.Factory.setMock(Service.class, mockService.createStub());

		String result = Controller.callNamespacedService();
		Assert.areEqual('packocz2.UniversalMocker.Service', result);
	}

	@IsTest
	static void mockNamespacedServiceWithProviderSameNamespaceStubInSameNamespace() {
		packocz2.UniversalMocker mockService = packocz2.UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('packocz2.UniversalMocker.Service');
		packocz2.Factory.stubAndSetMock(Service.class, mockService);

		String result = Controller.callNamespacedService();
		Assert.areEqual('packocz2.UniversalMocker.Service', result);
	}

	@IsTest
	static void mockLocalServiceWithProviderFromOtherNamespaceStubHere() {
		packocz2.UniversalMocker mockService = packocz2.UniversalMocker.mock(Service.class);
		mockService.when('method').thenReturn('packocz2.UniversalMocker.Service');
		packocz2.Factory.setMock(Service.class, Test.createStub(Service.class, mockService));

		String result = Controller.callLocalService();
		Assert.areEqual('packocz2.UniversalMocker.Service', result);
	}

	@IsTest
	static void mockLocalServiceWithProviderOtherNamespaceStubInSameOtherNamespace() {
		packocz2.UniversalMocker mockService = packocz2.UniversalMocker.mock(Service.class);
		mockService.when('method').thenReturn('packocz2.UniversalMocker.Service');
		packocz2.Factory.stubAndSetMock(Service.class, mockService);

		String result = Controller.callLocalService();
		Assert.areEqual('packocz2.UniversalMocker.Service', result);
	}

	@IsTest
	static void mockLocalServiceWithLocalProviderStubHere() {
		UniversalMocker mockService = UniversalMocker.mock(Service.class);
		mockService.when('method').thenReturn('UniversalMocker.Service');
		packocz2.Factory.setMock(Service.class, mockService.createStub());

		String result = Controller.callLocalService();
		Assert.areEqual('UniversalMocker.Service', result);
	}

	@IsTest
	static void mockLocalServiceWithLocalProviderStubInOtherNamespace() {
		UniversalMocker mockService = UniversalMocker.mock(Service.class);
		mockService.when('method').thenReturn('packocz.ServiceMock');
		packocz2.Factory.stubAndSetMock(Service.class, mockService);

		String result = Controller.callLocalService();
		Assert.areEqual('packocz.ServiceMock', result);
	}

	@IsTest
	static void mockNamespacedServiceWithLocalProviderStubHere() {
		UniversalMocker mockService = UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('UniversalMocker.Service');
		packocz2.Factory.setMock(Service.class, mockService.createStub());

		String result = Controller.callNamespacedService();
		Assert.areEqual('packocz.ServiceMock', result);
	}

	@IsTest
	static void mockNamespacedServiceWithLocalProviderStubInServiceNamespace() {
		UniversalMocker mockService = UniversalMocker.mock(packocz2.Service.class);
		mockService.when('method').thenReturn('packocz.ServiceMock');
		packocz2.Factory.stubAndSetMock(packocz2.Service.class, mockService);

		String result = Controller.callNamespacedService();
		Assert.areEqual('packocz.ServiceMock', result);
	}
}
