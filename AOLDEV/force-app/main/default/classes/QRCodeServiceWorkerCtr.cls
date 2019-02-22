public class QRCodeServiceWorkerCtr {
    public String js {get;set;}
    public QRCodeServiceWorkerCtr() {
        StaticResource static_resource = [SELECT Id, SystemModStamp, Name
                                  FROM StaticResource 
                                  WHERE Name = 'qrcode'
                                  LIMIT 1];
        String url_file_ref = '/resource/'
                            + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                            + '/' 
                            + static_resource.get('Name')
                            + '/qr-scanner-worker.min.js';
        PageReference file_ref = new PageReference(url_file_ref);
        String res_json_body = Test.isRunningTest() ? 'Unit.Test' : file_ref.getContent().toString();
        js = res_json_body;
    }
}