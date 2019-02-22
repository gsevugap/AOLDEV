@isTest
private class QRCodeServiceWorkerCtrTest {

	private static testMethod void test() {
        QRCodeServiceWorkerCtr ctrl = new QRCodeServiceWorkerCtr();
        System.assertNotEquals(ctrl.js, '');
	}

}