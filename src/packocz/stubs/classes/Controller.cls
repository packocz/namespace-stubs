public with sharing class Controller {
	public static String callNamespacedService() {
		String serviceName = packocz2.Service.newInstance().method();
		System.debug(serviceName);
		return serviceName;
	}

	public static String callLocalService() {
		String serviceName = Service.newInstance().method();
		System.debug(serviceName);
		return serviceName;
	}
}
