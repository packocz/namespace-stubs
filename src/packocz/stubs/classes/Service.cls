global with sharing class Service {
	global static Service newInstance() {
		return (Service) packocz2.Factory.newInstanceOf(Service.class);
	}
	global String method() {
		return 'packocz.Service';
	}
}
