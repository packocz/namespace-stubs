global with sharing class Service {
	global static Service newInstance() {
		return (Service) Factory.newInstanceOf(Service.class);
	}
	global String method() {
		return 'packocz2.Service';
	}
}
