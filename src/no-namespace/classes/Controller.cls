public with sharing class Controller {
	public static String callNamespace1Service() {
		String serviceName = packocz2.Service.newInstance().method();
		System.debug(serviceName);
		return serviceName;
	}

	public static String callNamespace2Service() {
		String serviceName = packocz.Service.newInstance().method();
		System.debug(serviceName);
		return serviceName;
	}

	public static String callLocalService() {
		String serviceName = Service.newInstance().method();
		System.debug(serviceName);
		return serviceName;
	}
}
