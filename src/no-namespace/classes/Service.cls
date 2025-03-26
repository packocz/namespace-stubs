public with sharing class Service {
	public static Service newInstance() {
		return (Service) packocz2.Factory.newInstanceOf(Service.class);
	}
	public String method() {
		return 'Local Service';
	}
}
